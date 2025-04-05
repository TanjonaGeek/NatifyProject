import 'dart:io';

import 'package:natify/features/User/data/datasources/local/data_source_user.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final DataSourceUser dataSourceUser;
  UserRepositoryImpl({required this.dataSourceUser});

  @override
  Future<void> DeleteAccount(String userId) {
    // TODO: implement DeleteAccount
    throw UnimplementedError();
  }

  @override
  Future<void> SignIn(String uidUser) {
    return dataSourceUser.SignIn(uidUser);
  }

  @override
  Future<void> SignOut() {
    return dataSourceUser.SignOut();
  }

  @override
  Future<void> SignUp(String uid, String name, String photoURL) {
    return dataSourceUser.SignUp(uid, name, photoURL);
  }

  @override
  Future<void> UpdateInfoInAccount(
      String userId, String champsName, var dataUpdate, String flag) {
    return dataSourceUser.UpdateInfoInAccount(
        userId, champsName, dataUpdate, flag);
  }

  @override
  Future<String?> getUserTokenNotification() {
    return dataSourceUser.getUserTokenNotification();
  }

  @override
  Future<Map<String, dynamic>> isFillCheck() {
    return dataSourceUser.isFillCheck();
  }

  @override
  Future<List<UserModel>> getInfoUser(String uid) {
    return dataSourceUser.getInfoUser(uid);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPhotoProfileByUser(
      String uid, int limit) {
    return dataSourceUser.getAllPhotoProfileByUser(uid, limit);
  }

  @override
  Future<List<Map<String, dynamic>>> getPartOfPhotoProfileByUser(String uid) {
    return dataSourceUser.getPartOfPhotoProfileByUser(uid);
  }

  @override
  Future<void> UpdateAllInAccount(
      String userId,
      String name,
      String nom,
      String prenom,
      String flag,
      String pays,
      String nationalite,
      List<File> profilePic,
      List<Map<String, dynamic>> age,
      String sexe,
      String bio,
      List<Map<String, dynamic>> situationamoureux,
      List<Map<String, dynamic>> universite,
      List<Map<String, dynamic>> college,
      List<Map<String, dynamic>> emploi) {
    return dataSourceUser.UpdateAllInAccount(
        userId,
        name,
        nom,
        prenom,
        flag,
        pays,
        nationalite,
        profilePic,
        age,
        sexe,
        bio,
        situationamoureux,
        universite,
        college,
        emploi);
  }

  @override
  Future<void> visiteProfile(String name, String profilePic, String uid,
      String uidVisiteur, UserEntity userDat, String nationalite, String flag) {
    return dataSourceUser.visiteProfile(
        name, profilePic, uid, uidVisiteur, userDat, nationalite, flag);
  }

  @override
  Future<List<Map<String, dynamic>>> getPhotoProfile(String uid) {
    return dataSourceUser.getPhotoProfile(uid);
  }

  @override
  Future<void> InsertCollection(
      List<File> images, String titre, String profilePic, String type) {
    return dataSourceUser.InsertCollection(images, titre, profilePic, type);
  }

  @override
  Future<void> VoirCollection(List viewerActually, String uidVisiteur,
      String collectionId, String photoUrl) {
    return dataSourceUser.VoirCollection(
        viewerActually, uidVisiteur, collectionId, photoUrl);
  }

  @override
  Future<void> SupprimerCollection(List dataActually, String uidVisiteur,
      String collectionId, int index, int createdAt, String titre) {
    return dataSourceUser.SupprimerCollection(
        dataActually, uidVisiteur, collectionId, index, createdAt, titre);
  }

  @override
  Future<void> EditerCollection(List<File> images, String profilePic,
      String titre, String collectionId, List dataActually, int createdAt) {
    return dataSourceUser.EditerCollection(
        images, profilePic, titre, collectionId, dataActually, createdAt);
  }

  @override
  Future<void> Abonner(String uidUser, String uidNotification) {
    return dataSourceUser.Abonner(uidUser, uidNotification);
  }

  @override
  Future<void> Desabonner(String uidUser, String uidNotification) {
    return dataSourceUser.Desabonner(uidUser, uidNotification);
  }

  @override
  Future<Map<String, dynamic>> myDataInfo() {
    return dataSourceUser.myDataInfo();
  }

  @override
  Future<void> updateStatusUser(bool isOnline, String uid) {
    return dataSourceUser.updateStatusUser(isOnline, uid);
  }

  @override
  Future<void> updateStatusDistancePosition(bool status) {
    return dataSourceUser.updateStatusDistancePosition(status);
  }

  @override
  Future<Map<String, dynamic>> checkifHasStorie(String uid) {
    return dataSourceUser.checkifHasStorie(uid);
  }

  @override
  Future<void> updateStatusOnSeeNotification(bool status) {
    return dataSourceUser.updateStatusOnSeeNotification(status);
  }

  @override
  Future<void> updateStatusAutorisation(bool status, String fieldNameUpdate) {
    return dataSourceUser.updateStatusAutorisation(status, fieldNameUpdate);
  }

  @override
  Future<void> sendNotificationToFollowers() {
    return dataSourceUser.sendNotificationToFollowers();
  }

  @override
  Future<void> signalProfileUser(
      String uidUserSignal, String raison, String description) {
    return dataSourceUser.signalProfileUser(uidUserSignal, raison, description);
  }

  @override
  Future<void> addToReceiveNotificationFollowerByUser(
      String uidUser, String uidNotification) {
    return dataSourceUser.addToReceiveNotificationFollowerByUser(
        uidUser, uidNotification);
  }

  @override
  Future<void> removeToReceiveNotificationFollowerByUser(
      String uidUser, String uidNotification) {
    return dataSourceUser.removeToReceiveNotificationFollowerByUser(
        uidUser, uidNotification);
  }

  @override
  Future<void> saveVersionUse(String versionNumero) {
    return dataSourceUser.saveVersionUse(versionNumero);
  }

  @override
  Future<void> SuprrimerPhotoProfile(String uidUser, String urlPhoto) {
    return dataSourceUser.SuprrimerPhotoProfile(uidUser, urlPhoto);
  }

  @override
  Future<void> ModifierPhotoProfile(String uidUser, List<File> profilePic) {
    return dataSourceUser.ModifierPhotoProfile(uidUser, profilePic);
  }

  @override
  Future<void> publierVente(
      UserModel users,
      String title,
      String description,
      double latitude,
      double longitude,
      List<File> images,
      List<String> jaime,
      List<String> commentaire,
      int prix,
      String categorie,
      String currency,
      String nameProduit) {
    return dataSourceUser.publierVente(
        users,
        title,
        description,
        latitude,
        longitude,
        images,
        jaime,
        commentaire,
        prix,
        categorie,
        currency,
        nameProduit);
  }

  @override
  Future<void> addCommentVente(
      String venteId, String userId, String text, String parentId) {
    return dataSourceUser.addCommentVente(venteId, userId, text, parentId);
  }

  @override
  Future<void> editerVente(
      UserModel users,
      String title,
      String description,
      double latitude,
      double longitude,
      List<File> images,
      List<String> imagesOld,
      List<String> jaime,
      List<String> commentaire,
      int prix,
      String categorie,
      String currency,
      String nameProduit,
      String uidVente,
      bool status) {
    return dataSourceUser.editerVente(
        users,
        title,
        description,
        latitude,
        longitude,
        images,
        imagesOld,
        jaime,
        commentaire,
        prix,
        categorie,
        currency,
        nameProduit,
        uidVente,
        status);
  }

  @override
  Future<void> Defavorier(
      String uidUser, String uidNotification, String uidVente) {
    return dataSourceUser.Defavorier(uidUser, uidNotification, uidVente);
  }

  @override
  Future<void> Favoriser(
      String uidUser, String uidNotification, String uidVente) {
    return dataSourceUser.Favoriser(uidUser, uidNotification, uidVente);
  }

  @override
  Future<void> VueVente(
      String uidUser, String uidNotification, String uidVente) {
    return dataSourceUser.VueVente(uidUser, uidNotification, uidVente);
  }
}
