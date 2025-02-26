import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseDebloqueMessage {
  final ChatRepository chatRepository;
  UseCaseDebloqueMessage({required this.chatRepository});

  Future<void> call(String userUid) async {
    return chatRepository.DebloquerPersonne(userUid);
  }
}
