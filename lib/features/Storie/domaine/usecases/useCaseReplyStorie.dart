import 'package:natify/features/Storie/domaine/repositories/storie_repository.dart';

class UseCaseReplyStorie {
  final StorieRepository storieRepository;
  UseCaseReplyStorie({required this.storieRepository});

  Future<void> call(String text, String recieverUserId, String messageReply,
      String type) async {
    return storieRepository.ReplyStory(
        text, recieverUserId, messageReply, type);
  }
}
