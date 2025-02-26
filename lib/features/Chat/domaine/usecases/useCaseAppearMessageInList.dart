import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseDesappearMessageInlist {
  final ChatRepository chatRepository;
  UseCaseDesappearMessageInlist({required this.chatRepository});

  Future<void> call(String recieverUserId) async {
    return chatRepository.desappearMessageInList(recieverUserId);
  }
}
