import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseGetStatusBloque {
  final ChatRepository chatRepository;
  UseCaseGetStatusBloque({required this.chatRepository});

  Stream<bool> call(String userUid) {
    return chatRepository.getStatusBlock(userUid);
  }
}
