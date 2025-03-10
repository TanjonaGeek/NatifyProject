import 'dart:async';
import 'dart:io';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Chat/data/datasources/local/data_sources_chat_impl..dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:natify/features/User/domaine/usecases/useCasUpdateStatusAutorisation.dart';
import 'package:natify/features/User/domaine/usecases/useCaseAbonner.dart';
import 'package:natify/features/User/domaine/usecases/useCaseAddReceiveNotificatonByUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseCreateHighLight.dart';
import 'package:natify/features/User/domaine/usecases/useCaseDesabonner.dart';
import 'package:natify/features/User/domaine/usecases/useCaseEditerHiglight.dart';
import 'package:natify/features/User/domaine/usecases/useCaseGetInfoUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseIsFillUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseModifierPhotoProfile.dart';
import 'package:natify/features/User/domaine/usecases/useCaseMyInfoData.dart';
import 'package:natify/features/User/domaine/usecases/useCaseRemoveReceiveNotificatonByUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSaveVersionAppUseByUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSendNotificationHighLightFollowers.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSignalProfile.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSupprimerHighLight.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSuprrimerPhotoProfiles.dart';
import 'package:natify/features/User/domaine/usecases/useCaseUpdateAllInfoUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseUpdateDistancePosition.dart';
import 'package:natify/features/User/domaine/usecases/useCaseUpdateInfoInAccount.dart';
import 'package:natify/features/User/domaine/usecases/useCaseUpdateStatusUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseVoirHighLight.dart';
import 'package:natify/features/User/domaine/usecases/useCasesGetAllPhotoProfile.dart';
import 'package:natify/features/User/domaine/usecases/useCasesGetPartPhotoProfile.dart';
import 'package:natify/features/User/domaine/usecases/useCasesGetPhotoPrrofile.dart';
import 'package:natify/features/User/domaine/usecases/useCasesVisiteProfile.dart';
import 'package:natify/features/User/presentation/provider/state/info_state_user.dart';
import 'package:natify/injector.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class InfoNotifierUser extends StateNotifier<InfoStateUser> {
  final UseCaseIsFillUser _isFillUseCase = injector.get<UseCaseIsFillUser>();
  final UseCaseUpdateInfoUser _updateInfoUseCase =
      injector.get<UseCaseUpdateInfoUser>();
  final UseCaseGetInfoUser _getInfoUseCase = injector.get<UseCaseGetInfoUser>();
  final UseCaseGetAllPhotoProfile _getAllPhotoProfileUseCase =
      injector.get<UseCaseGetAllPhotoProfile>();
  final UseCaseGetPartPhotoProfile _getPartPhotoProfileUseCase =
      injector.get<UseCaseGetPartPhotoProfile>();
  final UseCaseUpdateAllInfoUser _updateAllInfoUseCase =
      injector.get<UseCaseUpdateAllInfoUser>();
  final UseCaseVisiteProfileUser _addNewVisiteurUseCase =
      injector.get<UseCaseVisiteProfileUser>();
  final UseCaseGetPhotoProfile _getPhotoProfileUseCase =
      injector.get<UseCaseGetPhotoProfile>();
  final UseCaseCreateHighLight _createHighLightUseCase =
      injector.get<UseCaseCreateHighLight>();
  final UseCaseVoirHighLight _voirCollectionUseCase =
      injector.get<UseCaseVoirHighLight>();
  final UseCaseSupprimerHighLight _supprimerCollectionUseCase =
      injector.get<UseCaseSupprimerHighLight>();
  final UseCaseEditereHighLight _editerHighLightUseCase =
      injector.get<UseCaseEditereHighLight>();
  final UseCaseAbonner _abonnerUseCase = injector.get<UseCaseAbonner>();
  final UseCaseDesabonner _desabonnerUseCase =
      injector.get<UseCaseDesabonner>();
  final UseCaseMyInfoData _myInfoDataUseCase =
      injector.get<UseCaseMyInfoData>();
  final UseCaseUpdateStatusUser _updateStatusUseCase =
      injector.get<UseCaseUpdateStatusUser>();
  final UseCaseUpdateDistancePosition _updateDistancePositionUseCase =
      injector.get<UseCaseUpdateDistancePosition>();
  final UseCaseUpdateStatusAutorisation _updateStatusAutorizationUseCase =
      injector.get<UseCaseUpdateStatusAutorisation>();
  final UseCaseSendNotificationHighLightFollowers
      _sendNotificationFollowersUseCase =
      injector.get<UseCaseSendNotificationHighLightFollowers>();
  final UseCaseSignalProfile _signalProfileUseCase =
      injector.get<UseCaseSignalProfile>();
  final useCaseAddReceiveNotificatonByUser _addReceiveNotificationUseCase =
      injector.get<useCaseAddReceiveNotificatonByUser>();
  final useCaseRemoveReceiveNotificatonByUser
      _removeReceiveNotificationUseCase =
      injector.get<useCaseRemoveReceiveNotificatonByUser>();
  final useCaseSaveVersionUseByUser _saveVersionAppUseCase =
      injector.get<useCaseSaveVersionUseByUser>();
  final UseCaseSupprimerPhotoProfiles _deletePhotoUserUseCase =
      injector.get<UseCaseSupprimerPhotoProfiles>();
  final UseCaseModifierPhotoProfiles _editPhotoUserUseCase =
      injector.get<UseCaseModifierPhotoProfiles>();
  InfoNotifierUser() : super(const InfoStateUser.initial());
  bool get isFetching => state.state != InfoUserConcreteState.loading;

  Future<void> updatePhotoProfileUser(
      String userId, List<File> profilePic) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      await _editPhotoUserUseCase.call(
        userId,
        profilePic,
      );
      await refreshProfile();
      showCustomSnackBar("profil_enregistre");
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> addNewVisiter(
      String name,
      String profilePic,
      String uid,
      String uidVisiteur,
      UserEntity userDat,
      String nationalite,
      String flag) async {
    try {
      _addNewVisiteurUseCase.call(
          name, profilePic, uid, uidVisiteur, userDat, nationalite, flag);
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> saveVersionApp(String versionNumero) async {
    try {
      _saveVersionAppUseCase.call(versionNumero);
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> deletePhotProfile(String uidUser, String urlPhoto) async {
    try {
      await _deletePhotoUserUseCase
          .call(uidUser, urlPhoto)
          .then((onValue) async {
        if (urlPhoto.isEmpty) {
          await refreshProfile();
        }
      });
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> signalProfile(
      String uidUserSignal, String raison, String description) async {
    try {
      _signalProfileUseCase.call(uidUserSignal, raison, description);
      showCustomSnackBar("Votre_signalement");
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> sendNotificationFollowers() async {
    try {
      await _sendNotificationFollowersUseCase.call();
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> updateStatusUser(bool isOnline, String uid) async {
    _updateStatusUseCase.call(isOnline, uid);
  }

  Future<void> updateDistancePosition(bool status) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      _updateDistancePositionUseCase.call(status);
      await getMyInfoUser(auth.currentUser!.uid);
      showCustomSnackBar("profil_enregistre");
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> updateStatusAutorize(bool status, String fieldNameUpdate) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      _updateStatusAutorizationUseCase.call(status, fieldNameUpdate);
      await getMyInfoUser(auth.currentUser!.uid);
      showCustomSnackBar("profil_enregistre");
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> refreshProfile() async {
    var response = _isFillUseCase.call();
    await response.then((value) async {
      state = state.copyWith(
        MydataPersiste: value['dataUser'],
      );
    });
    print(
        'le nouveau donneer est ${state.MydataPersiste!.friendBlocked!.length}');
  }

  Future<String> isFilled() async {
    try {
      var response = await _isFillUseCase
          .call(); // Assurez-vous que c'est une fonction async
      if (response['isFilled'] == "FillCompleted") {
        updateStatusUser(true, auth.currentUser!.uid);
        state = state.copyWith(
          MydataPersiste: response['dataUser'],
        );
        return response['isFilled']; // Retourner vrai
      } else {
        state = state.copyWith(
          MydataPersiste: response['dataUser'],
        );
        return response['isFilled']; // Retourner faux
      }
    } catch (e) {
      // Gérer les erreurs si nécessaire
      return ''; // Retourner faux
    }
  }

  Future<void> updateInfoUser(
      String userId, String champsName, var dataUpdate, String flag) async {
    await _updateInfoUseCase.call(userId, champsName, dataUpdate, flag);
  }

  Future<void> resetInfo() async {
    state = state.copyWith(
        IsFilled: '', isCompletedCheck: false, MydataPersiste: UserModel());
  }

  Future<void> updateAllInfoUser(
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
      List<Map<String, dynamic>> emploi) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      await _updateAllInfoUseCase.call(
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
      await refreshProfile();
      showCustomSnackBar("profil_enregistre");
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<List<UserEntity>> getInfoUser(String uid) async {
    try {
      final List<UserEntity> result = await _getInfoUseCase.call(uid);
      return result;
    } catch (e) {
      return []; // Retourne une liste vide en cas d'erreur
    }
  }

  Future<void> getMyInfoUser(String uid) async {
    try {
      if (isFetching) {
        var response = _myInfoDataUseCase.call();
        await response.then((value) async {
          state = state.copyWith(
            MydataPersiste: value['dataUser'],
          );
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getAllPhotoProfile(String uid, int limit) async {
    try {
      final response = await _getAllPhotoProfileUseCase.call(uid, 5);
      final result = response;
      state = state.copyWith(
        photoProfile: result,
      );
    } catch (e) {
      print('erreru sueveneue notifier $e');
    }
  }

  Future<void> getPartPhotoProfile(String uid) async {
    try {
      final response = await _getPartPhotoProfileUseCase.call(uid);
      final result = response;

      state = state.copyWith(
        partphotoProfile: result,
        state: InfoUserConcreteState.loaded,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        state: InfoUserConcreteState.loaded,
        isLoading: false,
      );
    }
  }

  Future<void> getFiveFirstPhotoProfile(String uid) async {
    try {
      final response = await _getPhotoProfileUseCase.call(uid);
      final result = response;

      state = state.copyWith(
        partphotoProfile: result,
        state: InfoUserConcreteState.loaded,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        state: InfoUserConcreteState.loaded,
        isLoading: false,
      );
    }
  }

  Future<void> createHighLigth(List<File> images, String titre,
      String profilePic, String type, BuildContext context) async {
    try {
      String messages = "Votre highlight a été créée avec succès.".tr;
      UserModel? myCurrentData = state.MydataPersiste;
      Future.delayed(Duration(seconds: 1), () {
        showCustomSnackBar("Votre highlight est en cours d'importation…");
      });
      await _createHighLightUseCase
          .call(images, titre, profilePic, type)
          .then((onValue) {
        notificationService.sendNotification(
            myCurrentData!, messages, myCurrentData.name.toString());
      });
      Future.delayed(Duration(seconds: 1), () {
        sendNotificationFollowers();
      });
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> editerHighLigth(
      List<File> images,
      String profilePic,
      String titre,
      String collectionId,
      List dataActually,
      int createdAt,
      BuildContext context) async {
    try {
      String messages = "Votre highlight a été editée avec succès.".tr;
      UserModel? myCurrentData = state.MydataPersiste;
      Future.delayed(Duration(seconds: 1), () {
        showCustomSnackBar("Votre highlight est en cours d'importation…");
      });
      await _editerHighLightUseCase
          .call(
              images, profilePic, titre, collectionId, dataActually, createdAt)
          .then((onValue) {
        notificationService.sendNotification(
            myCurrentData!, messages, myCurrentData.name.toString());
      });
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<List<dynamic>> decompresseListHighLight(List<dynamic> data) async {
    List highlightData = [];
    for (var highlight in data) {
      highlightData.add(highlight);
    }
    return highlightData;
  }

  Future<void> voirCollection(List viewerActually, String uidVisiteur,
      String collectionId, String photoUrl) async {
    await _voirCollectionUseCase.call(
        viewerActually, uidVisiteur, collectionId, photoUrl);
  }

  Future<void> suprrimerCollection(List dataActually, String uidVisiteur,
      String collectionId, int index, int createdAt, String titre) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      showCustomSnackBar("Highlight supprimée avec succès.");
      await _supprimerCollectionUseCase.call(
          dataActually, uidVisiteur, collectionId, index, createdAt, titre);
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> abonner(String uidUser, String uidNotification) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if (mounted) {
          showCustomSnackBar("Pas de connexion internet");
        }
        return;
      }
      if (mounted) {
        showCustomSnackBar(
            "Vous suivez cette personne. Restez connecté à ses actualités.");
      }
      await _abonnerUseCase.call(uidUser, uidNotification);
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
            "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
      }
    }
  }

  Future<void> desabonner(String uidUser, String uidNotification) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if (mounted) {
          showCustomSnackBar("Pas de connexion internet");
        }
        return;
      }
      if (mounted) {
        showCustomSnackBar("Vous ne suivez plus cette personne.");
      }
      await _desabonnerUseCase.call(uidUser, uidNotification);
      //  await getMyInfoUser(uidUser);
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
            "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
      }
    }
  }

  Future<void> addReceiveNotification(
      String uidUser, String uidNotification) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if (mounted) {
          showCustomSnackBar("Pas de connexion internet");
        }
        return;
      }
      if (mounted) {
        showCustomSnackBar(
            "Vous recevez toutes les notifications liées à cet utilisateur.");
      }
      await _addReceiveNotificationUseCase.call(uidUser, uidNotification);
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
            "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
      }
    }
  }

  Future<void> removeReceiveNotification(
      String uidUser, String uidNotification) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if (mounted) {
          showCustomSnackBar("Pas de connexion internet");
        }
        return;
      }
      if (mounted) {
        showCustomSnackBar(
            "Vous avez désactiver toutes les notifications pour cet utilisateur.");
      }
      await _removeReceiveNotificationUseCase.call(uidUser, uidNotification);
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
            "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
      }
    }
  }
}
