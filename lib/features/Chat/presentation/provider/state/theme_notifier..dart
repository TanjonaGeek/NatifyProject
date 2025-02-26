import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Chat/presentation/provider/state/theme_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ThemeChatNotifier extends StateNotifier<ThemeState> {
  ThemeChatNotifier() : super(ThemeState.initial());
  Future<void> updateThemeMessage() async {
    try {
      var tokenUpdateTheme = const Uuid().v1();
      state = state.copyWith(tokenUpdateTheme: tokenUpdateTheme);
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }
}
