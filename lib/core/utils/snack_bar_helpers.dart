import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:get/get.dart'; // Si tu utilises la localisation avec GetX

/// Affiche un toast personnalisé sans besoin de contexte
void showCustomSnackBar(String message) {
  showToast(
    message.tr, // Utilise GetX pour la localisation si nécessaire
    duration: Duration(seconds: 2),
    position: ToastPosition.bottom,
    backgroundColor: Colors.grey.shade500,
    radius: 20.0,
    textStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    textPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  );
}
