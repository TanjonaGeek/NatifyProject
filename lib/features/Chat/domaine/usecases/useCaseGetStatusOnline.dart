import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';
import 'package:natify/features/User/data/models/user_model.dart';

class UseCaseStatusOnline {
  final ChatRepository chatRepository;
  UseCaseStatusOnline({required this.chatRepository});

  Stream<List<UserModel>> call(String uidUser) {
    return chatRepository.getStatusOnline(uidUser);
  }
}
