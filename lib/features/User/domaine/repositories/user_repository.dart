import 'dart:io';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/entities/user_entities.dart';

abstract class UserRepository {
  Future<void> SignIn(String uidUser); // s'authentifier
  Future<void> SignUp(String uid, String name, String photoURL); // s'inscrire
  Future<void> SignOut(); // se deconnecter
  Future<void> DeleteAccount(String userId); // supprimer compte
  Future<void> UpdateInfoInAccount(String userId, String champsName,
      var dataUpdate, String flag); // mise a jour information au compte
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
    List<Map<String, dynamic>> emploi,
  ); // mise a jour tout information au compte au data source
  Future<String?> getUserTokenNotification(); // recuperer token Notification
  Future<Map<String, dynamic>>
      isFillCheck(); // verification information completer apres inscription
  Future<List<UserModel>> getInfoUser(
      String uid); // recuperer le donner utilisateur
  Future<List<Map<String, dynamic>>> getAllPhotoProfileByUser(String uid,
      int limit); // recuperer tout les photo de profiles de utilisateur
  Future<List<Map<String, dynamic>>> getPartOfPhotoProfileByUser(
      String uid); // recuperer 5 premier photo de profiles de utilisateur
  Future<void> visiteProfile(String name, String profilePic, String uid,
      String uidVisiteur, UserEntity userDat, String nationalite, String flag);
  Future<List<Map<String, dynamic>>> getPhotoProfile(String uid);
  Future<void> InsertCollection(
    List<File> images,
    String titre,
    String profilePic,
    String type,
  );
  Future<void> VoirCollection(List viewerActually, String uidVisiteur,
      String collectionId, String photoUrl);
  Future<void> SupprimerCollection(List dataActually, String uidVisiteur,
      String collectionId, int index, int createdAt, String titre);
  Future<void> EditerCollection(List<File> images, String profilePic,
      String titre, String collectionId, List dataActually, int createdAt);
  Future<void> Desabonner(String uidUser, String uidNotification);
  Future<void> Abonner(String uidUser, String uidNotification);
  Future<void> removeToReceiveNotificationFollowerByUser(
      String uidUser, String uidNotification);
  Future<void> addToReceiveNotificationFollowerByUser(
      String uidUser, String uidNotification);
  Future<void> updateStatusUser(bool isOnline, String uid);
  Future<void> updateStatusDistancePosition(bool status);
  Future<void> updateStatusAutorisation(bool status, String fieldNameUpdate);
  Future<Map<String, dynamic>> checkifHasStorie(String uid);
  Future<Map<String, dynamic>> myDataInfo();
  Future<void> updateStatusOnSeeNotification(bool status);
  Future<void> sendNotificationToFollowers(); // send Notification
  Future<void> signalProfileUser(String uidUserSignal, String raison,
      String description); // signal profile user
  Future<void> saveVersionUse(String versionNumero);
  Future<void> SuprrimerPhotoProfile(String uidUser, String urlPhoto);
  Future<void> ModifierPhotoProfile(String uidUser, List<File> profilePic);
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
      String nameProduit);
  Future<void> addCommentVente(
      String venteId, String userId, String text, String parentId);
}
