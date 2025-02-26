import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseTypingIndicator {
  final ChatRepository chatRepository;
  UseCaseTypingIndicator({required this.chatRepository});

  Future<void> call(String uidUser, bool status) async {
    return chatRepository.activeTyping(uidUser, status);
  }
}
