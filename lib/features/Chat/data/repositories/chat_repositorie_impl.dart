import 'dart:io';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/data/datasources/local/data_source_chat.dart';
import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';
import 'package:natify/features/User/data/models/user_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final DataSourceChat dataSourceChat;
  ChatRepositoryImpl({required this.dataSourceChat});

  @override
  Future<void> BloquePersonne(String uidUser) {
    return dataSourceChat.BloquePersonne(uidUser);
  }

  @override
  Future<void> DebloquerPersonne(String uidUser) {
    return dataSourceChat.DebloquerPersonne(uidUser);
  }

  @override
  Future<void> DeleteMessage(
      String messageUid, String userUid, int timesent, bool checkDeleteOption) {
    return dataSourceChat.DeleteMessage(
        messageUid, userUid, timesent, checkDeleteOption);
  }

  @override
  Future<void> SendMessage(
      String text,
      String recieverUserId,
      String messageReply,
      MessageEnum messageReplyType,
      MessageEnum messageEnum,
      List<File> file,
      String urlGif) {
    return dataSourceChat.SendMessage(text, recieverUserId, messageReply,
        messageReplyType, messageEnum, file, urlGif);
  }

  @override
  Future<void> activeTyping(String uidUser, bool status) {
    return dataSourceChat.activeTyping(uidUser, status);
  }

  @override
  Stream<bool> getStatusTyping(String uidUser) {
    return dataSourceChat.getStatusTyping(uidUser);
  }

  @override
  Stream<List<UserModel>> getStatusOnline(String uidUser) {
    return dataSourceChat.getStatusOnline(uidUser);
  }

  @override
  Future<void> unreadMessage(String recieverUserId) {
    return dataSourceChat.unreadMessage(recieverUserId);
  }

  @override
  Stream<bool> getStatusBlock(String uidUser) {
    return dataSourceChat.getStatusBlock(uidUser);
  }

  @override
  Stream<bool> getStatusBlockOnChat(String uidUser) {
    return dataSourceChat.getStatusBlockOnChat(uidUser);
  }

  @override
  Future<void> desappearMessageInList(String recieverUserId) {
    return dataSourceChat.desappearMessageInList(recieverUserId);
  }

  @override
  Future<void> ReactMessage(
      String reaction, String messageUid, String userUid, bool isReplyMessage) {
    return dataSourceChat.ReactMessage(
        reaction, messageUid, userUid, isReplyMessage);
  }

  @override
  Future<void> ChangeThemeMessage(
      List<Map<String, String>> dataThemeMessage, String uidSendMessage) {
    return dataSourceChat.ChangeThemeMessage(dataThemeMessage, uidSendMessage);
  }
}
