import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseReactMessage {
  final ChatRepository chatRepository;
  UseCaseReactMessage({required this.chatRepository});

  Future<void> call(String reaction, String messageUid, String userUid,
      bool isReplyMessage) async {
    return chatRepository.ReactMessage(
        reaction, messageUid, userUid, isReplyMessage);
  }
}
