import 'dart:io';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';

class UseCaseSendMessage {
  final ChatRepository chatRepository;
  UseCaseSendMessage({required this.chatRepository});

  Future<void> call(
      String text,
      String recieverUserId,
      String messageReply,
      MessageEnum messageReplyType,
      MessageEnum messageEnum,
      List<File> file,
      String urlGif) async {
    return chatRepository.SendMessage(text, recieverUserId, messageReply,
        messageReplyType, messageEnum, file, urlGif);
  }
}
