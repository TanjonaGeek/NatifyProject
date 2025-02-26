import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  final String apiKey = dotenv.env['MESSAGERIE_EMAIL_API_KEY'] ?? '';
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

  Future<String> getDeviceModel(BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceDetails = "Inconnu";
    String marqueDetails = "Inconnu";

    // Récupérer les informations spécifiques selon la plateforme (Android ou iOS)
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceDetails = androidInfo.model; // Exemple: "Pixel 5"
      marqueDetails = androidInfo.brand; // Exemple: "Pixel 5"
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceDetails = iosInfo.model; // Exemple: "iPhone 12"
      marqueDetails = iosInfo.name; // Exemple: "Pixel 5"
    }
    return "$marqueDetails $deviceDetails";
  }

  Future<String> _getAddressLogin(Position position) async {
    String adresse = ''; // Déclare la variable à l'extérieur du bloc if
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String codePostal =
            place.postalCode ?? ''; // Utilisation de `??` pour un fallback
        String locality = place.subLocality ??
            ''; // `??` est suffisant pour éviter une chaîne vide
        String administrativeArea =
            place.administrativeArea ?? ''; // `??` pour fallback

        // Crée l'adresse complète
        adresse = "$codePostal $locality $administrativeArea";
      }
    } catch (e) {
      print(
          "Erreur lors de la récupération de l'adresse: $e"); // Optionnel pour le debugging
    }
    return adresse;
  }

  Future<void> sendLoginNotification(
      String userEmail, String userName, BuildContext context) async {
    print('sfsfsfsfsfsfsf');
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');
    Position? position = await getUserPosition();
    String deviceModel = await getDeviceModel(context);
    String adresse = await _getAddressLogin(position!);
    String message =
        "Hello $userName,\n\nA new login has been detected on your account from the device : $deviceModel, at $adresse.\n\nIf this wasn't you, please secure your account immediately .";
    final payload = {
      'personalizations': [
        {
          'to': [
            {'email': userEmail}
          ],
          'subject': 'New login detected',
        }
      ],
      'from': {'email': 'natifyteam@gmail.com', 'name': 'Natify Team'},
      'content': [
        {'type': 'text/plain', 'value': message}
      ]
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 202) {
      print('Notification envoyée avec succès.');
    } else {
      print('Erreur lors de l\'envoi de l\'e-mail : ${response.body}');
    }
  }
}
