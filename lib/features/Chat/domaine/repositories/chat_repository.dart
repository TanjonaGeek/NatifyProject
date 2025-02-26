import 'dart:io';

import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/User/data/models/user_model.dart';

abstract class ChatRepository {
  Future<void> BloquePersonne(String uidUser); // bloquer personne
  Future<void> DebloquerPersonne(String uidUser); // debloquer personne
  Future<void> activeTyping(
      String uidUser, bool status); // activer le typing indicator de clavier
  Stream<bool> getStatusTyping(
      String
          uidUser); // recuperer le typing indicator de clavier de utilisateur
  Stream<List<UserModel>> getStatusOnline(
      String uidUser); // recuperer le status enligne de utilisateur
  Future<void> DeleteMessage(String messageUid, String userUid, int timesent,
      bool checkDeleteOption); // supprimer message
  Future<void> SendMessage(
      String text,
      String recieverUserId,
      String messageReply,
      MessageEnum messageReplyType,
      MessageEnum messageEnum,
      List<File> file,
      String urlGif); // envoyer message
  Future<void> unreadMessage(String recieverUserId);
  Stream<bool> getStatusBlock(
      String
          uidUser); // recuperer le typing indicator de clavier de utilisateur
  Stream<bool> getStatusBlockOnChat(
      String
          uidUser); // recuperer le typing indicator de clavier de utilisateur
  Future<void> desappearMessageInList(String recieverUserId);
  Future<void> ReactMessage(String reaction, String messageUid, String userUid,
      bool isReplyMessage); // react message
  Future<void> ChangeThemeMessage(List<Map<String, String>> dataThemeMessage,
      String uidSendMessage); // envoyer message
}
