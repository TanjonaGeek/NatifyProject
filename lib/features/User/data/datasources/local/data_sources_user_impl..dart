import 'dart:io';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:natify/core/Services/NotificationService.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/features/Storie/data/models/story_model.dart';
import 'package:natify/features/User/data/datasources/local/data_source_user.dart';
import 'package:natify/features/User/data/models/highlight_model.dart';
import 'package:natify/features/User/data/models/notification_model.dart';
import 'package:natify/features/User/data/models/signal_model.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/data/models/userphoto_model.dart';
import 'package:natify/features/User/data/models/version_app_model.dart';
import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:characters/characters.dart';

class DataSourceUserImpl implements DataSourceUser {
  NotificationService notificationService = NotificationService();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final GeoFlutterFire geo = GeoFlutterFire();
  @override
  Future DeleteAccount(String userId) {
    // TODO: implement DeleteAccount
    throw UnimplementedError();
  }

  @override
  Future SignOut() {
    // TODO: implement SignOut
    throw UnimplementedError();
  }

  @override
  Future<void> SignUp(
    String uid,
    String name,
    String photoURL,
  ) async {
    // Validation des paramètres
    if (uid.isEmpty) {
      print('Erreur: L\'ID utilisateur ne peut pas être vide');
      return;
    }
    if (name.isEmpty) {
      print('Erreur: Le nom ne peut pas être vide');
      return;
    }
    if (photoURL.isEmpty) {
      print('Erreur: L\'URL de la photo de profil ne peut pas être vide');
      return;
    }

    try {
      // Récupération du token de notification
      final String? tokenNotification = await getUserTokenNotification();

      // Création du modèle utilisateur
      final UserModel user = UserModel(
          uid: uid,
          name: name,
          nameParts: generateAllSubstrings(name),
          nom: '',
          prenom: '',
          flag: '',
          pays: '',
          nationalite: '',
          codeCountry: '',
          profilePic: photoURL,
          isOnline: true,
          groupId: [],
          tokenNotification: tokenNotification,
          age: [],
          sexe: '',
          bio: '',
          situationamoureux: [],
          universite: [],
          college: [],
          emploi: [],
          LastActivetime: DateTime.now().millisecondsSinceEpoch.toString(),
          ageReel: 0,
          abonnee: [],
          abonnement: [],
          invitation: [],
          friendBlocked: [],
          position: null,
          hiddenPosition: false,
          alertLocation: false,
          alertPublication: true,
          partageMedia: true,
          availableSendNotification: []);

      // Enregistrement de l'utilisateur dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(user.toMap());

      // Ajout de la photo de profil à une collection dédiée
      await addPhotoProfilePicToCollection(photoURL, 'photo');

      print('Utilisateur enregistré avec succès : étape 1 complétée');
    } catch (e, stackTrace) {
      // Utilisation de print ou un outil de journalisation (ex : Sentry, Firebase Crashlytics) pour mieux suivre les erreurs
      print('Erreur lors de l\'inscription de l\'utilisateur : $e');
      print('Trace : $stackTrace');
      // Optionnel : vous pouvez remonter l'erreur ou afficher un message utilisateur
    }
  }

  @override
  Future<void> UpdateInfoInAccount(
    String userId,
    String fieldName,
    dynamic dataUpdate,
    String flag,
  ) async {
    // Validation des paramètres
    if (userId.isEmpty) {
      print('L\'ID utilisateur ne peut pas être vide');
      return;
    }
    if (fieldName.isEmpty) {
      print('Le nom du champ ne peut pas être vide');
      return;
    }

    try {
      // Mise à jour du document utilisateur avec les nouvelles données
      if (fieldName == "age") {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          fieldName: dataUpdate,
          'ageReel': int.parse(dataUpdate[0]['age'])
        });
      } else if (fieldName == "nationalite") {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({fieldName: dataUpdate, 'flag': flag});
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          fieldName: dataUpdate,
        });
      }

      print(
          'Informations mises à jour avec succès pour l\'utilisateur $userId');
    } catch (e) {
      print('Erreur lors de la mise à jour des informations : $e');
    }
  }

  @override
  Future<Map<String, dynamic>> SignIn(String uidUser) async {
    if (uidUser.isEmpty) {
      return {'error': 'L\'ID utilisateur ne peut pas être vide'};
    }

    try {
      // Obtention du token de notification
      final String? token = await getUserTokenNotification();

      // Récupération des données utilisateur depuis Firestore
      final getUserData = await FirebaseFirestore.instance
          .collection('users')
          .doc(uidUser)
          .get();

      if (!getUserData.exists || getUserData.data() == null) {
        return {'error': 'Utilisateur avec l\'ID $uidUser non trouvé'};
      }

      // Création du modèle utilisateur à partir des données récupérées
      final user = UserModel.fromJson(getUserData.data()!);
      print('token est $token');
      // Mise à jour du token de notification
      await FirebaseFirestore.instance.collection('users').doc(uidUser).update({
        'tokenNotification': token,
      });

      print(
          'Étape 2 : Token de notification mis à jour avec succès pour l\'utilisateur $uidUser');

      // Retour du modèle utilisateur et d'autres informations si nécessaire
      return {
        'user': user,
        'message': 'Connexion réussie et token mis à jour',
      };
    } catch (e, stackTrace) {
      // Retourne une carte contenant l'erreur et les informations de débogage
      print(
          'Erreur lors de la mise à jour du token de notification pour l\'utilisateur $uidUser : $e');
      print('Trace : $stackTrace');
      return {'error': 'Erreur lors de la connexion : $e'};
    }
  }

  @override
  Future<String?> getUserTokenNotification() async {
    try {
      // Obtention du token de notification via le service de notification
      final token = await notificationService.getDeviceToken();
      return token;
    } catch (e) {
      print('Erreur lors de l\'obtention du token de notification : $e');
      return ''; // Retourne une chaîne vide en cas d'erreur
    }
  }

  @override
  Future<Map<String, dynamic>> isFillCheck() async {
    try {
      String isFilled = "FillPageSexe";
      final userId = auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Récupérer le document utilisateur depuis Firestore
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      // Extraire les données de l'utilisateur
      final userData = userDoc.data();
      if (userData == null) {
        throw Exception('User data is null');
      }

      // Convertir les données en modèle UserModel
      final myOwnData = UserModel.fromJson(userData);

      // Vérifier si certains champs sont remplis ou non
      if (myOwnData.sexe?.isEmpty ?? true) {
        isFilled = "FillPageSexe";
      } else if (myOwnData.age!.isEmpty) {
        // Si ageReel est un entier, il ne peut pas être null
        isFilled = "FillPageAge";
      } else if (myOwnData.nationalite?.isEmpty ?? true) {
        isFilled = "FillPageNationalite";
      } else if (myOwnData.pays?.isEmpty ?? true) {
        isFilled = "FillPagePays";
      } else {
        isFilled = "FillCompleted";
      }

      // Retourner les données de l'utilisateur et le statut de remplissage
      return {
        'dataUser': myOwnData, // Renvoie le modèle UserModel
        'isFilled': isFilled, // Renvoie le statut
      };
    } catch (e) {
      print('Error checking user profile completeness: $e');
      rethrow; // Relancer l'erreur pour qu'elle soit gérée ailleurs
    }
  }

  @override
  Future<Map<String, dynamic>> myDataInfo() async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Récupérer le document utilisateur depuis Firestore
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      // Extraire les données de l'utilisateur
      final userData = userDoc.data();
      if (userData == null) {
        throw Exception('User data is null');
      }

      // Convertir les données en modèle UserModel
      final myOwnData = UserModel.fromJson(userData);
      // Retourner les données de l'utilisateur et le statut de remplissage
      return {
        'dataUser':
            myOwnData, // Renvoie le modèle UserModel  // Renvoie le statut
      };
    } catch (e) {
      print('Error checking user profile completeness: $e');
      rethrow; // Relancer l'erreur pour qu'elle soit gérée ailleurs
    }
  }

  @override
  Future<List<UserModel>> getInfoUser(String uid) async {
    // TODO: implement getInfoUser
    try {
      List<UserModel> UserData = [];
      final dataUser = await firestore.collection('users').doc(uid).get();
      UserModel UserDataget = UserModel.fromJson(dataUser.data()!);
      UserData.add(UserDataget);
      return UserData;
    } catch (e) {
      throw UnimplementedError();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPhotoProfileByUser(
      String uid, int limit) async {
    List<Map<String, dynamic>> ImageUpload = [];

    try {
      // Récupérer tous les fichiers du répertoire Firebase Storage
      final ListResult result =
          await FirebaseStorage.instance.ref().child('profilePic/$uid').list();
      final List<Reference> allFiles = result.items;

      // Limiter le nombre de téléchargements simultanés à `limit`
      final List<Future<void>> futures = [];
      for (int i = 0; i < allFiles.length; i += limit) {
        final List<Reference> batch = allFiles.skip(i).take(limit).toList();

        futures.addAll(batch.map((file) async {
          try {
            final String fileUrl = await file.getDownloadURL();
            final FullMetadata fileMeta = await file.getMetadata();

            ImageUpload.add({
              'url': fileUrl,
              'path': file.fullPath,
              'createdAt': fileMeta.timeCreated,
              'updatedAt': fileMeta.updated,
              'contentType': fileMeta.contentType,
            });
          } catch (e) {
            print('Error fetching file: $e');
          }
        }).toList());

        // Attendre que les téléchargements du batch soient terminés
        await Future.wait(futures);
      }

      return ImageUpload;
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPartOfPhotoProfileByUser(
      String uid) async {
    try {
      List<Map<String, dynamic>> imageUpload = [];
      final ListResult result =
          await FirebaseStorage.instance.ref().child('profilePic/$uid').list();
      final List<Reference> allFiles = result.items;
      // Traiter les fichiers en lots
      const int batchSize = 5;
      for (int i = 0; i < 5; i += batchSize) {
        final batch =
            allFiles.sublist(i, i + batchSize > 5 ? 5 : i + batchSize);
        // Télécharger les informations pour le lot courant
        final batchResults = await Future.wait(batch.map((file) async {
          final String fileUrl = await file.getDownloadURL();
          final FullMetadata fileMeta = await file.getMetadata();
          return {
            'url': fileUrl,
            'path': file.fullPath,
            'createdAt': fileMeta.timeCreated,
            'updatedAt': fileMeta.updated,
            'contentType': fileMeta.contentType
          };
        }));
        imageUpload.addAll(batchResults);
      }
      return imageUpload;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> storeFileToFirebase(
      String ref, List<File> files, String title) async {
    if (files.isEmpty) {
      throw Exception('Aucun fichier à télécharger.');
    }

    String downloadUrl = "";
    final file = files.first;
    final fileExtension = p.extension(file.path);

    // Définition des types MIME pour certains types de fichiers
    final mimeTypeMap = {
      '.jpg': 'image/jpeg',
      '.png': 'image/png',
      '.mp4': 'video/mp4',
      '.pdf': 'application/pdf',
      // Ajoutez d'autres types MIME si nécessaire
    };

    final contentType =
        mimeTypeMap[fileExtension] ?? 'application/octet-stream';

    try {
      // Préparation de l'upload
      UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(
            file,
            SettableMetadata(contentType: contentType),
          );

      print('Importation en cours ...');

      // Écoute de la progression de l'upload
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnap) {
        double progress =
            100.0 * (taskSnap.bytesTransferred / taskSnap.totalBytes);
        print('Importation ${progress.toStringAsFixed(0)} %');
        // Implémentez ici la logique de notification si nécessaire
      });

      // Attendre la complétion de l'upload
      await uploadTask.whenComplete(() async {
        downloadUrl = await uploadTask.snapshot.ref.getDownloadURL();
        print('Importation terminée');
      });
    } catch (e) {
      print('Erreur lors de l\'importation: $e');
      throw Exception('Échec de l\'importation du fichier');
    }

    // Retourne l'URL avec l'extension
    String urlWithExtension = "$downloadUrl$fileExtension";
    return urlWithExtension;
  }

  Future<String> storeFileHighLigthToFirebase(
      String ref, File file, String title) async {
    String downloadUrl = "";
    final fileExtension = p.extension(file.path);

    // Définition des types MIME pour certains types de fichiers
    final mimeTypeMap = {
      '.jpg': 'image/jpeg',
      '.png': 'image/png',
      '.mp4': 'video/mp4',
      '.pdf': 'application/pdf',
    };

    final contentType =
        mimeTypeMap[fileExtension] ?? 'application/octet-stream';

    try {
      // Générer un chemin unique pour chaque fichier en ajoutant un identifiant unique
      String uniqueFileName = const Uuid().v1() + fileExtension;
      String fullPath = "$ref/$uniqueFileName"; // Chemin unique

      // Préparation de l'upload avec le chemin unique
      UploadTask uploadTask = firebaseStorage.ref().child(fullPath).putFile(
            file,
            SettableMetadata(contentType: contentType),
          );

      print('Importation en cours ...');

      // Écoute de la progression de l'upload
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnap) {
        double progress =
            100.0 * (taskSnap.bytesTransferred / taskSnap.totalBytes);
        print('Progression: ${progress.toStringAsFixed(0)} %');
      });

      // Attendre la complétion de l'upload
      await uploadTask.whenComplete(() async {
        downloadUrl = await uploadTask.snapshot.ref.getDownloadURL();
        print('Importation terminée');
      });
    } catch (e) {
      print('Erreur lors de l\'importation : $e');
      throw Exception('Échec de l\'importation du fichier');
    }

    return downloadUrl;
  }

  List<String> generateKeywords(String title, String currentLanguage) {
    // Vérifier si la langue est supportée, sinon utiliser l'anglais par défaut
    if (!Helpers.stopWordsByLanguage.containsKey(currentLanguage)) {
      currentLanguage = 'en';
    }

    // Récupérer les stopwords sous forme de Set pour accélérer les recherches
    Set<String> stopWords =
        Helpers.stopWordsByLanguage[currentLanguage]!.toSet();

    // Nettoyer et normaliser le titre
    String normalizedTitle = removeDiacritics(title.toLowerCase());

    List<String> words = normalizedTitle
        .replaceAll(RegExp(r'[^\w\s]'), '') // Supprime la ponctuation
        .split(RegExp(r'\s+')) // Divise en mots par espace ou tabulation
        .where((word) =>
            word.isNotEmpty &&
            !stopWords.contains(word)) // Filtre les stopwords
        .toList();

    Set<String> uniqueKeywords = {};

    // Générer des combinaisons de mots-clés
    for (int i = 0; i < words.length; i++) {
      String phrase = '';
      for (int j = i; j < words.length; j++) {
        phrase = phrase.isEmpty ? words[j] : '$phrase ${words[j]}';
        uniqueKeywords.add(phrase);
      }
    }

    return uniqueKeywords.toList(growable: false);
  }

  // Fonction pour supprimer les accents
  String removeDiacritics(String input) {
    const Map<String, String> diacriticsMap = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'ã': 'a',
      'å': 'a',
      'ā': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ē': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ī': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ø': 'o',
      'ō': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ū': 'u',
      'ç': 'c',
      'ñ': 'n',
      'ý': 'y',
      'ÿ': 'y'
    };

    return input.split('').map((char) => diacriticsMap[char] ?? char).join();
  }

  List<String> generateAllSubstrings(String name) {
    List<String> substrings = [];
    String lowerCaseName = name.toLowerCase();

    // Divise le nom en mots
    List<String> words = lowerCaseName.split(' ');

    // Générer toutes les sous-chaînes pour chaque mot
    for (String word in words) {
      for (int i = 0; i < word.length; i++) {
        for (int j = i + 1; j <= word.length; j++) {
          substrings
              .add(word.substring(i, j)); // Ajoute toutes les sous-chaînes
        }
      }
    }

    return substrings.toSet().toList(); // Retirer les doublons
  }

  @override
  Future<void> UpdateAllInAccount(
      String userId,
      String name,
      String nom,
      String prenom,
      String flag,
      String pays,
      String nationalite,
      List<File> profilePic,
      List<Map<String, dynamic>> age,
      String sexe,
      String bio,
      List<Map<String, dynamic>> situationamoureux,
      List<Map<String, dynamic>> universite,
      List<Map<String, dynamic>> college,
      List<Map<String, dynamic>> emploi) async {
    try {
      // Mise à jour du document utilisateur avec les nouvelles données
      if (profilePic.isNotEmpty) {
        var namefileGenerate = const Uuid().v1();
        String ref = "profilePic/$userId/$namefileGenerate";
        String title = "Importation story";
        String imageUrl = await storeFileToFirebase(ref, profilePic, title);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          "name": name,
          "nameParts": generateAllSubstrings(name),
          "profilePic": imageUrl,
          "nom": nom,
          "prenom": prenom,
          "flag": flag,
          "pays": pays,
          "nationalite": nationalite,
          "age": age,
          'ageReel': int.parse(age[0]['age']),
          "sexe": sexe,
          "bio": bio,
          "situationamoureux": situationamoureux,
          "universite": universite,
          "college": college,
          "emploi": emploi,
        }).then((onValue) {
          addPhotoProfilePicToCollection(imageUrl, 'photo');
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          "name": name,
          "nameParts": generateAllSubstrings(name),
          "nom": nom,
          "prenom": prenom,
          "flag": flag,
          "pays": pays,
          "nationalite": nationalite,
          "age": age,
          'ageReel': int.parse(age[0]['age']),
          "sexe": sexe,
          "bio": bio,
          "situationamoureux": situationamoureux,
          "universite": universite,
          "college": college,
          "emploi": emploi,
        });
      }
    } catch (e) {
      print('le erreur est $e');
    }
  }

  @override
  Future<void> visiteProfile(
      String name,
      String profilePic,
      String uid,
      String uidVisiteur,
      UserEntity userDat,
      String nationalite,
      String flag) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final yesterday = DateTime.now()
          .subtract(const Duration(hours: 24))
          .millisecondsSinceEpoch;
      // Rechercher une notification dans les dernières 24 heures avec le même uid et nationalité
      final querySnapshot = await firestore
          .collection('users')
          .doc(uidVisiteur)
          .collection('Notification')
          .where('timeSent', isGreaterThan: yesterday)
          .where('nationalite', isEqualTo: nationalite)
          .where('type', isEqualTo: 'visite')
          .limit(1) // Optimisation: Limiter à 1 résultat
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Si une notification existe, on l'update pour incrémenter le nombre de visiteurs
        final existingDoc = querySnapshot.docs.first;
        final currentVisiteurs = existingDoc.data()['nombreVisiteurs'] ?? 1;
        List<dynamic> currentUidUser =
            existingDoc.data()['uidUserVisite'] ?? [];

        // Si le uid du visiteur n'est pas déjà dans la liste, l'ajouter
        if (!currentUidUser.contains(uid)) {
          currentUidUser.add(uid);
          await existingDoc.reference.update({
            'nombreVisiteurs': currentVisiteurs + 1,
            'uidUserVisite': currentUidUser, // Mettre à jour le tableau uidUser
          });
        }
      } else {
        // Si aucune notification n'existe, on crée une nouvelle notification
        final IdNotification = const Uuid().v1();
        final dataNotification = NotificationModel(
            name: name,
            profilePic: profilePic,
            contactId: uid,
            timeSent: now,
            MessageNotification: "$name a visité votre profil",
            statusRead: false,
            nationalite: nationalite,
            nombreVisiteurs: 1, // Initialiser avec 1 visiteur
            type: 'visite',
            flag: flag,
            uidUserVisite: [uid], // Initialiser avec le uid du visiteur actuel
            statusOnSee: false);
        await firestore
            .collection('users')
            .doc(uidVisiteur)
            .collection('Notification')
            .doc(IdNotification)
            .set(dataNotification.toMap());
      }

      // Envoyer la notification push après avoir inséré ou mis à jour Firestore
      // await notificationService.sendNotification(
      //   userDat,
      //   "Quelqu'un de nationalité $nationalite a visité votre profil",
      //   'Notification'
      // );
    } catch (e) {
      // Gestion des erreurs
      print("Erreur lors de l'ajout du visiteur : $e");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPhotoProfile(String uid) async {
    try {
      // Exécute la requête Firestore avec une limite de 5 documents
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('photoProfile')
          .doc(uid)
          .collection('IdPhoto')
          .orderBy('timeCreated',
              descending: true) // Utilise un champ pour trier
          .limit(5) // Limite les résultats à 5 documents
          .get();
      // Récupère les documents de la requête
      final List<QueryDocumentSnapshot> docs = querySnapshot.docs;

      // Mappe chaque document pour récupérer ses données sous forme de Map
      List<Map<String, dynamic>> photoProfile = docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      return photoProfile; // Retourne la liste d'utilisateurs
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs : $e');
      return []; // Retourne une liste vide en cas d'erreur
    }
  }

  Future<void> addPhotoProfilePicToCollection(
      String urlPhoto, String type) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final IdPhoto = const Uuid().v1();
      final dataPhoto =
          UserPhotoModel(urlPhoto: urlPhoto, timeCreated: now, type: type);
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('photoProfile')
          .doc(IdPhoto)
          .set(dataPhoto.toMap());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> InsertCollection(
    List<File> images, // Liste d'images
    String titre,
    String profilePic,
    String type,
  ) async {
    if (images.isEmpty) {
      print('Aucune image à importer.');
      return;
    }

    try {
      var collectionId = DateTime.now().millisecondsSinceEpoch.toString();
      String uid = auth.currentUser!.uid;
      List<Map<String, dynamic>> collectionData = [];
      List<Map<String, dynamic>> collectionImagePath = [];
      String ref = "/CollectionImage/$collectionId$uid/";
      String title = "Importation collection";

      // Utilisation de Future.wait pour uploader toutes les images
      await Future.wait(images.map((image) async {
        // Appel de la fonction d'upload pour chaque image
        String imageUrl = await storeFileHighLigthToFirebase(ref, image, title);
        collectionImagePath.add({
          'path': imageUrl,
        });
      }));

      // Ajout des données après l'upload
      collectionData.add({
        'titre': titre,
        'collectionId': collectionId,
        'ImagePath': collectionImagePath,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Création du modèle et ajout dans Firestore
      HighLightModel collImg = HighLightModel(
        data: collectionData,
        profilePic: profilePic,
        QuivoirCollection: [],
        type: type,
      );

      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('HighLight')
          .doc(collectionId)
          .set(collImg.toMap());

      print('Collection insérée avec succès.');
    } catch (e) {
      print('Erreur lors de l\'insertion de la collection : $e');
      throw Exception('Échec de l\'insertion de la collection');
    }
  }

  @override
  Future<void> VoirCollection(List viewerActually, String uidVisiteur,
      String collectionId, String photoUrl) async {
    try {
      print(
          'le donner est viewerActually : $viewerActually , uidVisiteur : $uidVisiteur collectionId : $collectionId photoUrl : $photoUrl');
      String uidMe = auth.currentUser!.uid;
      List collectionDataViewer = viewerActually;
      if (uidMe != uidVisiteur) {
        bool alreadySeen = collectionDataViewer.any(
            (item) => item['uid'] == uidMe && item['photoUrl'] == photoUrl);
        if (!alreadySeen) {
          collectionDataViewer.add({'uid': uidMe, 'photoUrl': photoUrl});
          await firestore
              .collection('users')
              .doc(uidVisiteur)
              .collection('HighLight')
              .doc(collectionId)
              .update({'QuivoirCollection': collectionDataViewer});
        }
      }
    } catch (e) {
      print('le erreur est $e');
    }
  }

  @override
  Future<void> SupprimerCollection(List dataActually, String uidVisiteur,
      String collectionId, int index, int createdAt, String titre) async {
    if (dataActually.length > 1) {
      try {
        List<Map<String, dynamic>> collectionData = [];
        List<dynamic> dataImageCollection = dataActually;
        dataImageCollection.removeAt(index);
        collectionData.add({
          'titre': titre,
          'collectionId': collectionId,
          'ImagePath': dataImageCollection,
          'createdAt': createdAt,
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uidVisiteur)
            .collection('HighLight')
            .doc(collectionId)
            .update({
          'data': collectionData,
        });
      } catch (e) {
        print(e.toString());
      }
    } else {
      try {
        DocumentReference docRef1 = FirebaseFirestore.instance
            .collection('users')
            .doc(uidVisiteur)
            .collection('HighLight')
            .doc(collectionId);
        docRef1.delete();
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Future<void> EditerCollection(
      List<File> images,
      String profilePic,
      String titre,
      String collectionId,
      List dataActually,
      int createdAt) async {
    try {
      String uid = auth.currentUser!.uid;
      List<Map<String, dynamic>> collectionData = [];
      List collectionImagePath = dataActually;
      String ref = "/CollectionImage/$collectionId$uid/";
      String title = "Importation collection";

      if (images.isNotEmpty) {
        // Utilisation de Future.wait pour uploader toutes les images
        await Future.wait(images.map((image) async {
          // Appel de la fonction d'upload pour chaque image
          String imageUrl =
              await storeFileHighLigthToFirebase(ref, image, title);
          collectionImagePath.add({
            'path': imageUrl,
          });
        }));
      }
      // Ajout des données après l'upload
      collectionData.add({
        'titre': titre,
        'collectionId': collectionId,
        'ImagePath': collectionImagePath,
        'createdAt': createdAt,
      });

      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('HighLight')
          .doc(collectionId)
          .update({'data': collectionData, 'profilePic': profilePic});

      print('Collection insérée avec succès.');
    } catch (e) {
      print('Erreur lors de l\'insertion de la collection : $e');
      throw Exception('Échec de l\'insertion de la collection');
    }
  }

  @override
  Future<void> Desabonner(String uidUser, String uidNotification) async {
    try {
      String uidMe = auth.currentUser!.uid;
      if (uidUser.isEmpty) {
        throw Exception('User not authenticated');
      }
      final userSnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: uidMe)
          .limit(1) // Limitation à un seul document
          .get();

      final userSnapshot2 = await firestore
          .collection('users')
          .where('uid', isEqualTo: uidUser)
          .limit(1) // Limitation à un seul document
          .get();

      if (userSnapshot.docs.isEmpty || userSnapshot2.docs.isEmpty) {
        print('No stories found for user $uidMe');
        return;
      }

      // Get the first document
      final userDoc = userSnapshot.docs.first;
      final userDoc2 = userSnapshot2.docs.first;
      final userData = userDoc.data();
      final userData2 = userDoc2.data();
      final List<dynamic> abonner = List.from(userData2['abonnee'] ?? []);
      final List<dynamic> abonnement2 = List.from(userData['abonnement'] ?? []);
      final List<dynamic> abonnement3 =
          List.from(userDoc2['availableSendNotification'] ?? []);

      final userAbonneeData = abonner.firstWhere(
        (element) => element == uidMe,
        orElse: () => null,
      );

      final userAbonnementData = abonnement2.firstWhere(
        (element) => element == uidUser,
        orElse: () => null,
      );

      final userAbonnementData3 = abonnement3.firstWhere(
        (element) => element == uidMe,
        orElse: () => null,
      );

      if (userAbonneeData != null) {
        // If no reaction data exists, create it
        abonner.remove(uidMe);
      }
      if (userAbonnementData != null) {
        // If no reaction data exists, create it
        abonnement2.remove(uidUser);
      }
      if (userAbonnementData3 != null) {
        // If no reaction data exists, create it
        abonnement3.remove(uidMe);
      }
      // Update the story document
      await firestore.collection('users').doc(uidUser).update(
          {'abonnee': abonner, "availableSendNotification": abonnement3});
      await firestore.collection('users').doc(uidMe).update({
        'abonnement': abonnement2,
      });
    } catch (e) {
      // Log the error properly
      print('Failed to desabonner: $e');
      // Optionally, handle specific error types (e.g., network issues)
    }
  }

  @override
  Future<void> removeToReceiveNotificationFollowerByUser(
      String uidUser, String uidNotification) async {
    try {
      String uidMe = auth.currentUser!.uid;
      if (uidUser.isEmpty) {
        throw Exception('User not authenticated');
      }
      final userSnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: uidUser)
          .limit(1) // Limitation à un seul document
          .get();
      if (userSnapshot.docs.isEmpty) {
        print('No stories found for user $uidUser');
        return;
      }

      // Get the first document
      final userDoc = userSnapshot.docs.first;
      final userData = userDoc.data();
      final List<dynamic> abonnement2 =
          List.from(userData['availableSendNotification'] ?? []);
      final userAbonnementData = abonnement2.firstWhere(
        (element) => element == uidMe,
        orElse: () => null,
      );
      if (userAbonnementData != null) {
        // If no reaction data exists, create it
        abonnement2.remove(uidMe);
      }
      // Update the story document
      await firestore
          .collection('users')
          .doc(uidUser)
          .update({'availableSendNotification': abonnement2});
    } catch (e) {
      // Log the error properly
      print('Failed to desabonner: $e');
      // Optionally, handle specific error types (e.g., network issues)
    }
  }

  @override
  Future<void> Abonner(String uidUser, String uidNotification) async {
    try {
      String uidMe = auth.currentUser!.uid;
      if (uidUser.isEmpty) {
        throw Exception('User not authenticated');
      }
      final userSnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: uidMe)
          .limit(1) // Limitation à un seul document
          .get();

      final userSnapshot2 = await firestore
          .collection('users')
          .where('uid', isEqualTo: uidUser)
          .limit(1) // Limitation à un seul document
          .get();

      if (userSnapshot.docs.isEmpty || userSnapshot2.docs.isEmpty) {
        print('No stories found for user $uidMe');
        return;
      }

      // Get the first document
      final userDoc = userSnapshot.docs.first;
      final userDoc2 = userSnapshot2.docs.first;
      final userData = userDoc.data();
      final userData2 = userDoc2.data();
      final List<dynamic> abonner = List.from(userData2['abonnee'] ?? []);
      final List<dynamic> abonnement2 = List.from(userData['abonnement'] ?? []);

      final userAbonneeData = abonner.firstWhere(
        (element) => element == uidMe,
        orElse: () => null,
      );

      final userAbonnementData = abonnement2.firstWhere(
        (element) => element == uidUser,
        orElse: () => null,
      );

      if (userAbonneeData == null) {
        // If no reaction data exists, create it
        abonner.add(uidMe);
      }
      if (userAbonnementData == null) {
        // If no reaction data exists, create it
        abonnement2.add(uidUser);
      }
      // Update the story document
      await firestore
          .collection('users')
          .doc(uidUser)
          .update({'abonnee': abonner});
      await firestore
          .collection('users')
          .doc(uidMe)
          .update({'abonnement': abonnement2});
      sendNotification(userData, userData2);
    } catch (e) {
      // Log the error properly
      print('Failed to abonner: $e');
      // Optionally, handle specific error types (e.g., network issues)
    }
  }

  @override
  Future<void> addToReceiveNotificationFollowerByUser(
      String uidUser, String uidNotification) async {
    try {
      String uidMe = auth.currentUser!.uid;
      if (uidUser.isEmpty) {
        throw Exception('User not authenticated');
      }
      final userSnapshot2 = await firestore
          .collection('users')
          .where('uid', isEqualTo: uidUser)
          .limit(1) // Limitation à un seul document
          .get();

      if (userSnapshot2.docs.isEmpty) {
        print('No stories found for user');
        return;
      }

      // Get the first document
      final userDoc = userSnapshot2.docs.first;
      final userData = userDoc.data();
      final List<dynamic> abonnement2 =
          List.from(userData['availableSendNotification'] ?? []);
      final userAbonnementData = abonnement2.firstWhere(
        (element) => element == uidMe,
        orElse: () => null,
      );
      if (userAbonnementData == null) {
        // If no reaction data exists, create it
        abonnement2.add(uidMe);
      }
      // Update the story document
      await firestore
          .collection('users')
          .doc(uidUser)
          .update({'availableSendNotification': abonnement2});
    } catch (e) {
      // Log the error properly
      print('Failed to abonner: $e');
      // Optionally, handle specific error types (e.g., network issues)
    }
  }

  Future<void> sendNotification(
      Map<String, dynamic> myData, Map<String, dynamic> otherData) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final myOwnData = UserModel.fromJson(myData);
      final OtherData = UserModel.fromJson(otherData);
      final IdNotification = const Uuid().v1();
      final dataNotification = NotificationModel(
          name: myOwnData.name,
          profilePic: myOwnData.profilePic,
          contactId: myOwnData.uid,
          timeSent: now,
          MessageNotification:
              "${myOwnData.name} de nationalité  ${myOwnData.nationalite} a commencé à suivre votre profil",
          statusRead: false,
          nationalite: myOwnData.nationalite,
          nombreVisiteurs: 1, // Initialiser avec 1 visiteur
          type: 'follower',
          flag: myOwnData.flag,
          uidUserVisite: [
            myOwnData.uid.toString()
          ], // Initialiser avec le uid du visiteur actuel
          statusOnSee: false);
      await firestore
          .collection('users')
          .doc(OtherData.uid.toString())
          .collection('Notification')
          .doc(IdNotification)
          .set(dataNotification.toMap());

      // Envoyer la notification push après avoir inséré ou mis à jour Firestore
      await notificationService.sendNotification(
          OtherData,
          "${myOwnData.name} de nationalité ${myOwnData.nationalite} a commencé à suivre votre profil. Découvrez qui s'intéresse à vous !",
          'Nouvel abonné à votre profil');
    } catch (e) {
      // Gestion des erreurs
      print("Erreur lors de l'ajout du visiteur : $e");
    }
  }

  @override
  Future updateStatusOnSeeNotification(bool status) async {
    try {
      await firestore
          .collection('Notification')
          .doc(auth.currentUser!.uid)
          .update({
        'statusOnSee': status,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Future updateStatusUser(bool isOnline, String uid) async {
    print('user deconnect avec succes lets man');
    await firestore.collection('users').doc(uid).update({
      'isOnline': isOnline,
      'LastActivetime': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  @override
  Future updateStatusDistancePosition(bool status) async {
    print('user deconnect');
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'hiddenPosition': status,
    });
  }

  @override
  Future updateStatusAutorisation(bool status, String fieldNameUpdate) async {
    print('user deconnect');
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      fieldNameUpdate: status,
    });
  }

  @override
  Future<Map<String, dynamic>> checkifHasStorie(String uid) async {
    try {
      // Calcul du cutoff time pour exclure les stories créées il y a plus de 24 heures
      int cutoffTime = DateTime.now()
          .subtract(const Duration(hours: 24))
          .millisecondsSinceEpoch;

      // Récupération d'un document de la collection "status" pour vérifier si l'utilisateur a une story récente
      final statusesSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: uid)
          .where('createdAt', isGreaterThanOrEqualTo: cutoffTime)
          .limit(1) // Limitation à un seul document pour optimisation
          .get();

      // Vérifie si un document a été trouvé
      if (statusesSnapshot.docs.isNotEmpty) {
        final data = statusesSnapshot.docs[0].data();

        // Convertit le document en StorieModel
        StorieModel status = StorieModel.fromJson(data);

        // Vérification de l'existence de `photoUrl` et de l'URL et du type de la dernière story
        if (status.photoUrl != null && status.photoUrl!.isNotEmpty) {
          return {'hasStorie': true, 'data': status};
        }
      }

      // Si aucun document trouvé ou pas de photoUrl
      return {'hasStorie': false};
    } catch (e) {
      print('Erreur lors de la vérification de story : $e');
      return {
        'hasStorie': false,
        'error': e.toString(),
      }; // Retourne un message d'erreur en cas d'exception
    }
  }

  @override
  @override
  Future<void> sendNotificationToFollowers() async {
    try {
      // Récupérer les données de l'utilisateur actuel
      var userData =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();
      UserModel currentUser = UserModel.fromJson(userData.data()!);

      // Vérifie s'il y a des abonnés
      if (currentUser.availableSendNotification != null &&
          currentUser.availableSendNotification!.isNotEmpty) {
        // Liste pour stocker les tokens FCM des abonnés
        List<String> tokens = [];

        // Récupérer les tokens FCM pour chaque abonné
        for (String followerUid in currentUser.availableSendNotification!) {
          var followerData =
              await firestore.collection('users').doc(followerUid).get();
          UserModel follower = UserModel.fromJson(followerData.data()!);

          if (follower.tokenNotification != null) {
            tokens.add(follower.tokenNotification!);
          }
        }
        String textMessageHighLight =
            "a ajouté un nouveau moment fort à ses highlights. Ne manquez pas ses dernières nouveautés !"
                .tr;
        String messageTitle = "Nouveau highlight".tr;
        String message = "${currentUser.name} $textMessageHighLight";
        // Envoyer la notification via FCM en utilisant les tokens récupérés
        await notificationService.sendNotificationForAll(
            currentUser, message, messageTitle, tokens);
        print("Notifications envoyées avec succès aux abonnés.");
      } else {
        print("Aucun abonné à notifier.");
      }
    } catch (e) {
      print("Erreur lors de l'envoi de la notification : $e");
    }
  }

  @override
  Future<void> signalProfileUser(
      String uidUserSignal, String raison, String description) async {
    try {
      String uid = auth.currentUser!.uid;

      // Obtenir le timestamp des dernières 24 heures
      var twentyFourHoursAgo =
          DateTime.now().subtract(Duration(hours: 24)).millisecondsSinceEpoch;

      // Vérifier si un signalement existe déjà pour ce `uid_user_signal` par cet utilisateur au cours des dernières 24 heures
      var existingSignal = await firestore
          .collection('signalements')
          .where('uid_user_who_signal',
              isEqualTo: uid) // Signalé par l'utilisateur actuel
          .where('uid_user_signaled',
              isEqualTo: uidUserSignal) // Utilisateur signalé
          .where('timeCreated',
              isGreaterThan: twentyFourHoursAgo) // Signalement récent
          .get();

      if (existingSignal.docs.isNotEmpty) {
        print("Vous avez déjà signalé cet utilisateur aujourd'hui.");
        return; // Empêcher la création d'un nouveau signalement
      }

      // Aucun signalement récent trouvé, créer un nouveau signalement
      var signalId = const Uuid().v1();
      var timeSignal = DateTime.now().millisecondsSinceEpoch;

      // Création du modèle et ajout dans Firestore
      SignalModel signalModel = SignalModel(
          uid_user_signaled: uidUserSignal,
          uid_user_who_signal: uid,
          raison_signal: raison,
          description: description,
          timeCreated: timeSignal,
          uid_signal: signalId,
          status_signal: 'en attente');

      // Ajouter dans la collection principale des signalements
      await firestore
          .collection('signalements')
          .doc(signalId)
          .set(signalModel.toMap());

      // Ajouter dans la sous-collection des signalements de l'utilisateur
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('signalements')
          .doc(signalId)
          .set(signalModel.toMap());

      print('Signalement créé avec succès.');
    } catch (e) {
      print("Erreur lors du signalement : $e");
    }
  }

  @override
  Future<void> saveVersionUse(String versionNumero) async {
    final packageInfo = await PackageInfo.fromPlatform();
    try {
      String appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      String uid = auth.currentUser!.uid;
      final prefs = await SharedPreferences.getInstance();
      // Récupérer la version stockée localement
      String? storedVersion = prefs.getString('app_version');
      if (storedVersion != appVersion) {
        var signalId = const Uuid().v1();
        // Création du modèle et ajout dans Firestore
        VersionAppModel versionModel = VersionAppModel(
          numeroVersion: appVersion,
        );

        // Ajouter dans la sous-collection des signalements de l'utilisateur
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('version_app_use')
            .doc(signalId)
            .set(versionModel.toMap());

        await prefs.setString('app_version', appVersion);
      }
    } catch (e) {
      print("Erreur lors du signalement : $e");
    }
  }

  @override
  Future<void> SuprrimerPhotoProfile(String uidUser, String urlPhoto) async {
    if (uidUser.isNotEmpty && urlPhoto.isEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(uidUser).update({
        "profilePic": "",
      });
    }
    if (uidUser.isNotEmpty && urlPhoto.isNotEmpty) {
      // Référence vers la collection des photos de profil
      final photoCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uidUser)
          .collection('photoProfile');

      // Chercher le document avec le `urlPhoto`
      final querySnapshot =
          await photoCollection.where('urlPhoto', isEqualTo: urlPhoto).get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete(); // Supprime le document
      }
    }
  }

  @override
  Future<void> ModifierPhotoProfile(
      String uidUser, List<File> profilePic) async {
    try {
      if (profilePic.isNotEmpty) {
        var namefileGenerate = const Uuid().v1();
        String ref = "profilePic/$uidUser/$namefileGenerate";
        String title = "Importation photo";
        String imageUrl = await storeFileToFirebase(ref, profilePic, title);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uidUser)
            .update({
          "profilePic": imageUrl,
        }).then((onValue) {
          addPhotoProfilePicToCollection(imageUrl, 'photo');
        });
      }
    } catch (e) {}
  }

  @override
  Future<void> publierVente(
      UserModel users,
      String title,
      String description,
      double latitude,
      double longitude,
      List<File> images,
      List<String> jaime,
      List<String> commentaire,
      int prix,
      String categorie,
      String currency,
      String nameProduit) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser;
      var venteUidGenerate = const Uuid().v1();
      var timeCreated = DateTime.now().millisecondsSinceEpoch;
      if (userUid == null) {
        return;
      }
      if (users.name!.isEmpty ||
          users.profilePic!.isEmpty ||
          users.uid!.isEmpty ||
          title.isEmpty ||
          description.isEmpty ||
          prix < 1) {
        return;
      }

      if (images.isEmpty) {
        return;
      }
      GeoFirePoint geoPoint =
          geo.point(latitude: latitude, longitude: longitude);
      final docRef = FirebaseFirestore.instance
          .collection('marketplace')
          .doc(venteUidGenerate);

      List<String> collectionImagePath = [];
      String ref = "/ProduitImage/$venteUidGenerate/";
      String titles = "Importation image";
      List<String> keywords = generateKeywords(title, 'en');
      // Utilisation de Future.wait pour uploader toutes les images
      await Future.wait(images.map((image) async {
        // Appel de la fonction d'upload pour chaque image
        String imageUrl =
            await storeFileHighLigthToFirebase(ref, image, titles);
        collectionImagePath.add(imageUrl);
      }));

      await docRef.set({
        "title": title.trim(),
        "description": description.trim(),
        "location": geoPoint.data,
        "latitude": latitude,
        "longitude": longitude,
        "images": collectionImagePath ?? [],
        "uidVente": venteUidGenerate,
        "organizerUid": users.uid,
        "organizerName": users.name ?? "",
        "organizerPhoto": users.profilePic ?? "",
        "createdAt": timeCreated,
        "jaime": jaime ?? [],
        "commentaire": commentaire ?? [],
        "prix": prix ?? "",
        "categorie": categorie ?? "",
        "currency": currency ?? "USD",
        "nameProduit": keywords,
        "status": true
      });

      // Ajouter les mots-clés dans la collection "suggestions"
      for (String keyword in keywords) {
        bool exists = await doesKeywordExist(
            keyword); // Vérifie si le mot-clé existe déjà

        if (!exists) {
          await FirebaseFirestore.instance
              .collection('suggestions')
              .doc(keyword)
              .set({
            'term': keyword,
            'category': categorie,
          });
          print('Mot-clé ajouté : $keyword');
        }
      }
    } catch (e) {
      rethrow; // Permet de remonter l'erreur si nécessaire
    }
  }

  Future<bool> doesKeywordExist(String keyword) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('suggestions')
        .doc(keyword)
        .get();

    return docSnapshot
        .exists; // Retourne true si le document existe, sinon false
  }

  @override
  Future<void> addCommentVente(
      String venteId, String userId, String text, String parentId) async {
    DocumentReference commentRef = firestore
        .collection('marketplace')
        .doc(venteId)
        .collection('comments')
        .doc();

    await commentRef.set({
      "commentaireId": commentRef.id,
      "venteId": venteId,
      "userId": userId,
      "text": text,
      "parentId": parentId ?? "", // Vide si c'est un commentaire principal
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> editerVente(
      UserModel users,
      String title,
      String description,
      double latitude,
      double longitude,
      List<File> images,
      List<String> imagesOld,
      List<String> jaime,
      List<String> commentaire,
      int prix,
      String categorie,
      String currency,
      String nameProduit,
      String uidVente,
      bool status) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser;
      var timeCreated = DateTime.now().millisecondsSinceEpoch;
      if (userUid == null) {
        return;
      }
      if (users.name!.isEmpty ||
          users.profilePic!.isEmpty ||
          users.uid!.isEmpty ||
          title.isEmpty ||
          description.isEmpty ||
          prix < 1) {
        return;
      }

      if (images.isNotEmpty || imagesOld.isNotEmpty) {
        GeoFirePoint geoPoint =
            geo.point(latitude: latitude, longitude: longitude);
        List<String> collectionImagePath = imagesOld;
        String ref = "/ProduitImage/$uidVente/";
        String titles = "Importation image";
        List<String> keywords = generateKeywords(title, 'en');
        // Utilisation de Future.wait pour uploader toutes les images
        await Future.wait(images.map((image) async {
          // Appel de la fonction d'upload pour chaque image
          String imageUrl =
              await storeFileHighLigthToFirebase(ref, image, titles);
          collectionImagePath.add(imageUrl);
        }));
        await firestore.collection('marketplace').doc(uidVente).update({
          "title": title.trim(),
          "description": description.trim(),
          "location": geoPoint.data,
          "latitude": latitude,
          "longitude": longitude,
          "images": collectionImagePath ?? [],
          "organizerUid": users.uid,
          "organizerName": users.name ?? "",
          "organizerPhoto": users.profilePic ?? "",
          "createdAt": timeCreated,
          "prix": prix ?? "",
          "categorie": categorie ?? "",
          "currency": currency ?? "USD",
          "nameProduit": keywords,
          "status": status
        });
        // Ajouter les mots-clés dans la collection "suggestions"
        for (String keyword in keywords) {
          bool exists = await doesKeywordExist(
              keyword); // Vérifie si le mot-clé existe déjà

          if (!exists) {
            await FirebaseFirestore.instance
                .collection('suggestions')
                .doc(keyword)
                .set({
              'term': keyword,
              'category': categorie,
            });
            print('Mot-clé ajouté : $keyword');
          }
        }
      }
    } catch (e) {}
  }
}
