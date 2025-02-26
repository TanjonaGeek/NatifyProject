import 'package:natify/core/Services/NotificationService.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/features/User/data/models/notification_model.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeoFlutterFire geo = GeoFlutterFire();
  NotificationService notificationService = NotificationService();

  // Vérifie et demande les permissions de localisation
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Service de localisation désactivé");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Permissions de localisation refusées");
        return false;
      }
    }
    return true;
  }

  // Récupère la position de l'utilisateur
  Future<Position?> getUserPosition() async {
    if (await _checkLocationPermission()) {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    }
    return null;
  }

  // Affiche une alerte pour confirmer la mise à jour de la position
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(
                "Mise à jour de votre emplacement".tr,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                "Nous avons détecté un changement".tr,
                style: TextStyle(fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Conserver".tr,
                      style: TextStyle(color: kPrimaryColor)),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    "Mettre à jour".tr,
                    style: TextStyle(color: kPrimaryColor),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Met à jour la position dans Firestore si elle a changé
  Future<void> updateUserLocation(BuildContext context) async {
    Position? position = await getUserPosition();
    if (position == null) return;
    User? user = _auth.currentUser;
    DocumentReference userRef = _firestore.collection('users').doc(user!.uid);
    GeoFirePoint geoPoint =
        geo.point(latitude: position.latitude, longitude: position.longitude);

    // Vérification de la dernière position enregistrée pour éviter les mises à jour inutiles
    DocumentSnapshot userDoc = await userRef.get();
    final userData = userDoc.data() as Map<String, dynamic>;
    bool alertLocation = userData['alertLocation'];
    // Si la liste de position est vide, on initialise une nouvelle liste
    if (userData['position'] == null) {
      await userRef.update({
        'position': geoPoint.data,
      });
    } else {
      GeoPoint lastPosition = userData['position']['geopoint'];
      // Calculer la distance entre la position actuelle et la dernière position
      double distanceInMeters = Geolocator.distanceBetween(
        lastPosition.latitude,
        lastPosition.longitude,
        position.latitude,
        position.longitude,
      );
      // getUserProximity(geoPoint,user.uid,userData);
      double distanceInKm = distanceInMeters / 1000;
      // Affichage pour vérifier la distance
      if ((lastPosition.latitude - position.latitude).abs() < 0.001 &&
          (lastPosition.longitude - position.longitude).abs() < 0.001) {
        // La position n'a pas changé de manière significative, donc on ne met pas à jour
        return;
      } else {
        if (alertLocation == true) {
          if (distanceInKm > 50) {
            // Demande de confirmation si la distance est supérieure à 50 km
            bool shouldUpdate = await _showConfirmationDialog(context);

            if (!shouldUpdate) {
              // Si l'utilisateur refuse, on ne met pas à jour
              return;
            } else {
              await userRef.update({
                'position': geoPoint.data,
              });
            }
          } else {
            // Mise à jour de la position avec la nouvelle position
            await userRef.update({
              'position': geoPoint.data,
            });
          }
        } else {
          await userRef.update({
            'position': geoPoint.data,
          });
        }
      }
    }
  }

  Future<void> getUserProximity(GeoFirePoint geoPoint, String currentUserId,
      Map<String, dynamic> myData) async {
    final prefs = await SharedPreferences.getInstance();
    // Récupérer les anciens UID enregistrés
    List<String> oldUidList = prefs.getStringList('nearbyUserUids') ?? [];

    // Rayon de recherche (en km)
    double radius = 1.0;
    final collectionReference = _firestore.collection('users');

    // Utiliser GeoFlutterFire pour récupérer les utilisateurs autour d'une position sans stream
    final stream = geo.collection(collectionRef: collectionReference).within(
          center: geoPoint,
          radius: radius,
          field: 'position',
          strictMode: true,
        );

    // Écoute des résultats
    stream.listen((List<DocumentSnapshot> documents) async {
      // Récupérer les UID détectés, en excluant le vôtre
      List<String> newUidList = documents
          .map((doc) => doc.id)
          .where((uid) => uid != currentUserId) // Exclure votre UID
          .toList();

      // Vérifier les nouveaux UID non présents dans l'ancienne liste
      List<String> newUsers =
          newUidList.where((uid) => !oldUidList.contains(uid)).toList();

      if (newUsers.isNotEmpty) {
        // Générer des notifications pour les nouveaux utilisateurs détectés
        sendNotification(myData, newUsers.length, newUsers);
      }

      // Mettre à jour la liste dans SharedPreferences
      await prefs.setStringList('nearbyUserUids', newUidList);
    });
  }

  Future<void> sendNotification(Map<String, dynamic> myData,
      int nbrUserProximity, List<String> listUserProxiity) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final myOwnData = UserModel.fromJson(myData);
      final IdNotification = const Uuid().v1();
      final dataNotification = NotificationModel(
          name: myOwnData.name,
          profilePic: myOwnData.profilePic,
          contactId: myOwnData.uid,
          timeSent: now,
          MessageNotification:
              "Un nouvel amie est à proximité ! Découvrez qui se trouve autour de vous.",
          statusRead: false,
          nationalite: '',
          nombreVisiteurs: nbrUserProximity, // Initialiser avec 1 visiteur
          type: 'proximity',
          flag: '',
          uidUserVisite:
              listUserProxiity, // Initialiser avec le uid du visiteur actuel
          statusOnSee: false);
      await _firestore
          .collection('users')
          .doc(myOwnData.uid.toString())
          .collection('Notification')
          .doc(IdNotification)
          .set(dataNotification.toMap());

      // Envoyer la notification push après avoir inséré ou mis à jour Firestore
      await notificationService.sendNotification(
          myOwnData,
          "Un nouvel amie est à proximité ! Découvrez qui se trouve autour de vous.",
          'Notification');
    } catch (e) {
      // Gestion des erreurs
      print("Erreur lors de l'ajout du visiteur : $e");
    }
  }
}
