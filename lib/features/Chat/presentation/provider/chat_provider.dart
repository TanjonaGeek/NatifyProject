import 'package:natify/features/Chat/presentation/provider/state/chat_notifier.dart';
import 'package:natify/features/Chat/presentation/provider/state/chat_state.dart';
import 'package:natify/features/Chat/presentation/provider/state/theme_notifier..dart';
import 'package:natify/features/Chat/presentation/provider/state/theme_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

final chatStateNotifier =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, uid) {
    final keyboardVisibilityController = KeyboardVisibilityController();
    return ChatNotifier(keyboardVisibilityController, uid);
  },
);
final themesStateNotifier =
    StateNotifierProvider<ThemeChatNotifier, ThemeState>(
        (ref) => ThemeChatNotifier());
