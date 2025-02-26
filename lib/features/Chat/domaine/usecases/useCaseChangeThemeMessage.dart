import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseChangeThemeMessage {
  final ChatRepository chatRepository;
  UseCaseChangeThemeMessage({required this.chatRepository});

  Future<void> call(
      List<Map<String, String>> dataThemeMessage, String uidSendMessage) {
    return chatRepository.ChangeThemeMessage(dataThemeMessage, uidSendMessage);
  }
}
