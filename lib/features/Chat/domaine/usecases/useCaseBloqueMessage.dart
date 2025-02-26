import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseBloqueMessage {
  final ChatRepository chatRepository;
  UseCaseBloqueMessage({required this.chatRepository});

  Future<void> call(String userUid) async {
    return chatRepository.BloquePersonne(userUid);
  }
}
