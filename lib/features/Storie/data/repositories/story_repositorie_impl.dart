import 'dart:io';
import 'package:natify/features/Storie/data/datasources/local/data_source_story.dart';
import 'package:natify/features/Storie/domaine/repositories/storie_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorieRepositoryImpl implements StorieRepository {
  final DataSourceStorie dataSourceStorie;
  StorieRepositoryImpl({required this.dataSourceStorie});

  @override
  Future<void> DeleteStory(String photoUrl, String statusId) {
    return dataSourceStorie.DeleteStory(photoUrl, statusId);
  }

  @override
  Future<void> ReactStory(
      String userIdVisiteur, int indexEmoji, String urlPhotoReact) {
    return dataSourceStorie.ReactStory(
        userIdVisiteur, indexEmoji, urlPhotoReact);
  }

  @override
  Future<void> ViewStory(String uidUser, String photoUrl) {
    return dataSourceStorie.ViewStory(uidUser, photoUrl);
  }

  @override
  Future<void> createStory(List<File> statusImage, String type) {
    return dataSourceStorie.createStory(statusImage, type);
  }

  @override
  Future<Map<String, dynamic>> getAllStory(
    DocumentSnapshot? lastDocument,
    int limit,
  ) {
    return dataSourceStorie.getAllStory(
      lastDocument,
      limit,
    );
  }

  @override
  Future<void> ReplyStory(
      String text, String recieverUserId, String messageReply, String type) {
    return dataSourceStorie.ReplyStory(
        text, recieverUserId, messageReply, type);
  }

  @override
  Future<void> sendNotificationToFollowers() {
    return dataSourceStorie.sendNotificationToFollowers();
  }
}
