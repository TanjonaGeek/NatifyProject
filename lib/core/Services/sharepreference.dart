import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', userData['uid'] ?? '');
    await prefs.setString('name', userData['name'] ?? '');
    await prefs.setString('nationalite', userData['nationalite'] ?? '');
    await prefs.setString('pays', userData['pays'] ?? '');
    await prefs.setString('sexe', userData['sexe'] ?? '');
    await prefs.setInt('age', userData['age'] ?? 0);
    await prefs.setString('profilePic', userData['profilePic'] ?? '');
    await prefs.setString('flag', userData['flag'] ?? '');
    // Ajoute d'autres champs si nécessaire
    print('Données enregistrées: $userData');
  }

  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      'uid': prefs.getString('uid') ?? '',
      'name': prefs.getString('name') ?? '',
      'nationalite': prefs.getString('nationalite') ?? '',
      'pays': prefs.getString('pays') ?? '',
      'sexe': prefs.getString('sexe') ?? '',
      'age': prefs.getInt('age') ?? 0,
      'profilePic': prefs.getString('profilePic') ?? '',
      'flag': prefs.getString('flag') ?? '',
    };
  }

  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('name');
    await prefs.remove('nationalite');
    await prefs.remove('pays');
    await prefs.remove('sexe');
    await prefs.remove('age');
    await prefs.remove('profilePic');
    await prefs.remove('flag');
  }

  // Nouvelle méthode pour sauvegarder les préférences de langue
  Future<void> saveLanguagePreference(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lngPrefix', locale.languageCode);
    await prefs.setString('lngSuffix', locale.countryCode.toString());
  }

  // // Nouvelle méthode pour récupérer les préférences de langue
  // Future<Locale?> getLanguagePreference() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? languageCode = prefs.getString('lngPrefix') ?? 'en';
  //   String? countryCode = prefs.getString('lngSuffix') ?? 'US';
  //   return Locale(languageCode, countryCode);
  // }
  Future<Locale?> getLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode =
        prefs.getString('lngPrefix') ?? 'en'; // Langue par défaut : anglais
    String countryCode = prefs.getString('lngSuffix') ?? 'US';
    return Locale(languageCode, countryCode);
  }
}
