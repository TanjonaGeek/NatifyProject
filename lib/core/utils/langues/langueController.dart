import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:natify/core/Services/sharepreference.dart';

class LanguageController extends GetxController {
  var currentLocale = Locale('en', 'US').obs;

  Future<void> changeLanguage(Locale locale) async {
    currentLocale.value = locale;
    Get.updateLocale(locale);
    UserPreferences userPreferences = UserPreferences();
    await userPreferences.saveLanguagePreference(locale);
    print("Langue changée : ${locale.languageCode}_${locale.countryCode}");
  }
}
