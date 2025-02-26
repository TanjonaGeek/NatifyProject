import 'package:flutter/material.dart';

class GlobalFocusManager extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Fermer le clavier lorsque l'application est mise en pause
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus(); // Défocus global
  }
}
