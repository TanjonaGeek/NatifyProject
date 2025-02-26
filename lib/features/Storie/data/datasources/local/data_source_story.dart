import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DataSourceStorie {
  Future<void> createStory(List<File> statusImage, String type); // creer story
  Future<void> ViewStory(String uidUser, String photoUrl); // view story
  Future<void> DeleteStory(String photoUrl, String statusId); // supprimer story
  Future<void> ReactStory(String userIdVisiteur, int indexEmoji,
      String urlPhotoReact); // reagir story
  Future<Map<String, dynamic>> getAllStory(
    DocumentSnapshot? lastDocument,
    int limit,
  ); // recuperer tout les story
  Future<void> ReplyStory(String text, String recieverUserId,
      String messageReply, String type); // reply story
  Future<void> sendNotificationToFollowers(); // send Notification
}
