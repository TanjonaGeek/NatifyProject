import 'dart:async';
import 'dart:io';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Storie/domaine/entities/storie_entities.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseCreateStorie.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseDeleteStory.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseListStory.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseReactStory.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseReplyStorie.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseSendNotificationFollowers.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseViewStorie.dart';
import 'package:natify/features/Storie/presentation/provider/state/storie_state.dart';
import 'package:natify/injector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorieNotifier extends StateNotifier<StorieState> {
  final UseCaseGetStorie _allStorieListUseCase =
      injector.get<UseCaseGetStorie>();
  final UseCaseReplyStorie _replyStoryUseCase =
      injector.get<UseCaseReplyStorie>();
  final UseCaseViewStorie _viewStoryUseCase = injector.get<UseCaseViewStorie>();
  final UseCaseReactStorie _reactStoryUseCase =
      injector.get<UseCaseReactStorie>();
  final UseCaseCreateStorie _createStoryUseCase =
      injector.get<UseCaseCreateStorie>();
  final UseCaseDeleteStorie _deleteStoryUseCase =
      injector.get<UseCaseDeleteStorie>();
  final UseCaseSendNotificationFollowers _sendNotificationFollowersUseCase =
      injector.get<UseCaseSendNotificationFollowers>();
  DocumentSnapshot? _lastDocument;

  StorieNotifier() : super(const StorieState.initial());

  bool get isFetching => state.state != StorieListConcreteState.loading;

  Future<void> sendNotificationFollowers() async {
    try {
      await _sendNotificationFollowersUseCase.call();
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> removeUidFromStory(String userId) async {
    try {
      int cutoffTime = DateTime.now()
          .subtract(const Duration(hours: 24))
          .millisecondsSinceEpoch;
      // Récupérer toutes les stories de l'utilisateur en question
      QuerySnapshot storiesSnapshot = await FirebaseFirestore.instance
          .collection('status')
          .where('uid',
              isEqualTo:
                  userId) // Récupère toutes les stories de cet utilisateur
          .where('createdAt', isGreaterThanOrEqualTo: cutoffTime)
          .get();

      // Prépare un WriteBatch pour regrouper toutes les mises à jour
      final batch = FirebaseFirestore.instance.batch();
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      bool hasUpdates = false;

      for (QueryDocumentSnapshot storyDoc in storiesSnapshot.docs) {
        final storyData = storyDoc.data() as Map<String, dynamic>;
        List<dynamic> storyAvailableForUser =
            storyData['storyAvailableForUser'] ?? [];

        // Si l'UID actuel est présent dans la liste, on le supprime
        if (storyAvailableForUser.contains(currentUserUid)) {
          storyAvailableForUser.remove(currentUserUid); // Retire l'UID
          DocumentReference docRef = FirebaseFirestore.instance
              .collection('status')
              .doc(storyData['statusId']);

          // Ajoute la mise à jour au batch
          batch.update(docRef, {
            'storyAvailableForUser': storyAvailableForUser,
          });
          hasUpdates = true;
        }
      }

      // Si des mises à jour ont été faites, on exécute le batch
      if (hasUpdates) {
        await batch.commit();
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'UID des stories: $e');
    }
  }

  Future<void> getAllStory(int limit, bool isLoadMore) async {
    try {
      if (isFetching) {
        final response = await _allStorieListUseCase.call(_lastDocument, limit);
        final newStorie = response[
            'storie']; // Assurez-vous que c'est une liste ou un tableau
        final lastDocument = response['lastDocument'] as DocumentSnapshot?;
        final hasMore = lastDocument != null && newStorie.isNotEmpty;
        _lastDocument = hasMore ? lastDocument : null;
        // Vérifiez si lastDocument est null ou si newStorie est vide
        if (lastDocument == null || newStorie == null || newStorie.isEmpty) {
          return; // Sortie précoce si lastDocument est null ou newStorie est vide
        }
        if (newStorie is List) {
          final batch = FirebaseFirestore.instance
              .batch(); // Crée un batch pour regrouper les mises à jour
          String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
          bool hasUpdates = false;

          for (var story in newStorie) {
            final userIdStory = story['uid'];
            if (userIdStory != currentUserUid) {
              final storyId = story['statusId'];

              // Assurez-vous que storyAvailableForUser est une liste valide
              List<dynamic> storyAvailableForUser =
                  (story['storyAvailableForUser'] ?? []).cast<String>();
              List<dynamic> photoUrls = story['photoUrl'];
              List<dynamic> photosNonVues = [];
              // Vérifiez chaque photo dans photoUrl
              for (var photo in photoUrls) {
                String photoUrl = photo[
                    'url']; // Supposons que 'url' est la clé dans chaque photo

                // Vérification si l'utilisateur a déjà vu cette photo
                bool vue = (story['QuivoirStorie'] as List).any((item) {
                  return item['uid'] == currentUserUid &&
                      item['photoUrl'] == photoUrl;
                });

                if (!vue) {
                  // Ajouter à la liste des photos non vues
                  photosNonVues.add(photo);
                }
              }
              if (photosNonVues.isNotEmpty) {
                if (!storyAvailableForUser.contains(currentUserUid)) {
                  storyAvailableForUser.add(
                      currentUserUid); // Ajouter l'UID s'il n'est pas déjà présent
                  DocumentReference docRef = FirebaseFirestore.instance
                      .collection('status')
                      .doc(storyId);
                  // Ajout de la mise à jour dans le batch
                  batch.update(docRef, {
                    'storyAvailableForUser': storyAvailableForUser,
                  });
                  hasUpdates = true;
                }
              }
            }
          }
          if (hasUpdates) {
            await batch.commit();
          }
        }
      }
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  void clickExplorezStorie() {
    state = state.copyWith(
      isDescoveryStorie: true,
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> decompresseListStorie(
      List<StorieEntity> stories) async {
    List<Map<String, dynamic>> AllStorie = [];

    stories.expand((story) {
      return story.photoUrl!.map((url) {
        return {
          'uid': story.uid,
          'username': story.username,
          'createdAt': story.createdAt,
          'profilePic': story.profilePic,
          'statusId': story.statusId,
          'urlPhoto': url,
          'QuivoirStorie': story.QuivoirStorie
        };
      });
    }).forEach((storyMap) {
      AllStorie.add(storyMap);
    });

    return {
      'AllStorie': AllStorie,
    };
  }

  Future<Map<String, List<Map<String, dynamic>>>> decompresseMyStorie(
      List<StorieEntity> stories) async {
    List<Map<String, dynamic>> MyOwnStorie = [];

    stories.expand((story) {
      return story.photoUrl!.map((url) {
        return {
          'uid': story.uid,
          'username': story.username,
          'createdAt': story.createdAt,
          'profilePic': story.profilePic,
          'statusId': story.statusId,
          'urlPhoto': url,
          'QuivoirStorie': story.QuivoirStorie
        };
      });
    }).forEach((storyMap) {
      MyOwnStorie.add(storyMap);
    });
    return {
      'MyOwnStorie': MyOwnStorie,
    };
  }

  Future<void> RepondreStory(String text, String recieverUserId,
      String messageReply, String type) async {
    try {
      await _replyStoryUseCase.call(text, recieverUserId, messageReply, type);
      showCustomSnackBar("Votre réponse a bien été envoyée avec succès 🎉");
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> ReactStory(
      String userIdVisiteur, int indexEmoji, String urlPhotoReact) async {
    try {
      await _reactStoryUseCase.call(userIdVisiteur, indexEmoji, urlPhotoReact);
      showCustomSnackBar("Votre réaction a bien été ajoutée ! 👍");
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> ViewStory(String uidHasStory, String urlPhotoView) async {
    if (uidHasStory != FirebaseAuth.instance.currentUser!.uid) {
      await _viewStoryUseCase.call(uidHasStory, urlPhotoView);
    }
  }

  Future<void> CreateStory(List<File> statusImage, String type) async {
    try {
      Future.delayed(Duration(seconds: 1), () {
        showCustomSnackBar("Votre story est en cours d'importation…");
      });
      await _createStoryUseCase.call(statusImage, type);
      Future.delayed(Duration(seconds: 2), () {
        sendNotificationFollowers();
      });
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> DeleteStory(String url, String statusId) async {
    try {
      await _deleteStoryUseCase.call(url, statusId);
      showCustomSnackBar("Story supprimée avec succès.");
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }
}
