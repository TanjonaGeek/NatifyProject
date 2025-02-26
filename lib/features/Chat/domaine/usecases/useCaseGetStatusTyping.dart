import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseStatusTyping {
  final ChatRepository chatRepository;
  UseCaseStatusTyping({required this.chatRepository});

  Stream<bool> call(String uidUser) {
    return chatRepository.getStatusTyping(uidUser);
  }
}
