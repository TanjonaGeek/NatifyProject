import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseGetStatusBloqueOnChat {
  final ChatRepository chatRepository;
  UseCaseGetStatusBloqueOnChat({required this.chatRepository});

  Stream<bool> call(String userUid) {
    return chatRepository.getStatusBlockOnChat(userUid);
  }
}
