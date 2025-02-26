import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseDeleteMessage {
  final ChatRepository chatRepository;
  UseCaseDeleteMessage({required this.chatRepository});

  Future<void> call(String messageUid, String userUid, int timesent,
      bool checkDeleteOption) async {
    return chatRepository.DeleteMessage(
        messageUid, userUid, timesent, checkDeleteOption);
  }
}
