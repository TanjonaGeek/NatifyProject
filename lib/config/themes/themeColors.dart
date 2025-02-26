import 'package:flutter/material.dart';

// Mode clair
ThemeData lightTheme = ThemeData(
  fontFamily: 'Montserrat',
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white, // Fond de page clair
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white, // Couleur de l'AppBar en mode clair
    iconTheme:
        IconThemeData(color: Colors.black), // Couleur des icônes en mode clair
    titleTextStyle: TextStyle(
      // Style du texte de l'AppBar
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFF2596be), // Couleur des boutons en mode clair
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
        foregroundColor: Colors.black), // Couleur du texte des boutons
  ),
  textTheme: TextTheme(
    headlineMedium:
        TextStyle(color: Colors.black), // Couleur du texte dans l'AppBar
    headlineLarge:
        TextStyle(color: Colors.black), // Couleur du texte dans l'AppBar
    headlineSmall:
        TextStyle(color: Colors.black), // Couleur du texte dans l'AppBar
    bodyMedium: TextStyle(
        color: Colors.black), // Couleur du texte principal en mode clair
    bodySmall: TextStyle(color: Colors.black54), // Couleur du texte secondaire
    bodyLarge: TextStyle(color: Colors.black), // Couleur du texte secondaire
  ),
  iconTheme:
      IconThemeData(color: Colors.black), // Couleur des icônes en mode clair
);

// Mode sombre
ThemeData darkTheme = ThemeData(
  fontFamily: 'Montserrat',
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.black, // Fond de page sombre
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black, // Couleur de l'AppBar en mode sombre
    iconTheme:
        IconThemeData(color: Colors.white), // Couleur des icônes en mode sombre
    titleTextStyle: TextStyle(
      // Style du texte de l'AppBar
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFF2596be), // Couleur des boutons en mode sombre
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
        foregroundColor: Colors.white), // Texte des boutons en mode sombre
  ),
  textTheme: TextTheme(
    headlineMedium:
        TextStyle(color: Colors.white), // Couleur du texte dans l'AppBar
    headlineLarge:
        TextStyle(color: Colors.white), // Couleur du texte dans l'AppBar
    headlineSmall:
        TextStyle(color: Colors.white), // Couleur du texte dans l'AppBar
    bodyMedium: TextStyle(
        color: Colors.white), // Couleur du texte principal en mode clair
    bodySmall: TextStyle(color: Colors.white54), // Couleur du texte secondaire
    bodyLarge: TextStyle(color: Colors.white), // Couleur du texte secondaire
  ),
  iconTheme:
      IconThemeData(color: Colors.white), // Couleur des icônes en mode sombre
);
