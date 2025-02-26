import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseUnreadMessage {
  final ChatRepository chatRepository;
  UseCaseUnreadMessage({required this.chatRepository});

  Future<void> call(String recieverUserId) async {
    return chatRepository.unreadMessage(recieverUserId);
  }
}
