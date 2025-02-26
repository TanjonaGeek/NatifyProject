// Classe qui gère la transition de navigation par glissement
import 'package:flutter/material.dart';

class SlideNavigation {
  // Fonction statique pour appeler le slide navigation
  static void slideToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(_createRoute(page));
  }

  static void slideToPagePushRemplacement(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(_createRoute(page));
  }

  // Méthode privée pour créer une transition personnalisée
  static Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide de droite à gauche
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
