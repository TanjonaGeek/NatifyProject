import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/core/utils/widget/show_loading_dialog.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:natify/features/Storie/presentation/provider/storie_provider.dart';
import 'package:natify/features/User/presentation/pages/auth/AuthUserPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';

class AccountDeletionService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Timer? _debounce;
  Future<void> deleteAccount(
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      Navigator.pop(context);
      final user = auth.currentUser;
      final useruid = auth.currentUser!.uid;
      if (user == null) {
        throw Exception("Aucun utilisateur connecté");
      }
      await reAuthentified(ref, context, useruid);
      // // Déconnexion et suppression immédiate de l'utilisateur
      // await user.delete();
      // await Future.delayed(const Duration(milliseconds: 300));
      // await FirebaseAuth.instance.signOut();
      // await GoogleSignIn().signOut();
      // // Redirection vers la page de connexion après déconnexion
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(
      //     builder: (context) => AuthUserPage(),
      //   ),
      //   (Route<dynamic> route) => false,
      // );

      // Lancer la suppression des sous-collections en arrière-plan
      // _deleteUserDataInBackground(useruid);
    } catch (e) {
      // Si une erreur se produit, l'afficher
      print("Erreur de suppression du compte : $e");
    }
  }

  Future<void> reAuthentified(
      WidgetRef ref, BuildContext context, String userUid) async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    try {
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print("Pas de connexion Internet.");
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      // Annuler le debounce si actif
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      // Démarrer la connexion Google
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Vérification si l'utilisateur Google est valide
      if (googleUser == null) {
        print(
            'Erreur : L\'utilisateur Google est nul ou l\'utilisateur a annulé la connexion.');
        return;
      }

      // Authentification Google
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      // Utilisation du debounce pour temporiser l'exécution
      _debounce = Timer(const Duration(milliseconds: 100), () async {
        try {
          // Création des credentials pour Firebase
          AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          try {
            await FirebaseAuth.instance.currentUser!
                .reauthenticateWithCredential(credential);
          } catch (e) {
            if (FirebaseAuth.instance.currentUser != null) {
              showLoadingDialog(
                  context: context, message: 'deconnexion_en_cours');

              // Mise à jour de l'état de l'utilisateur (si nécessaire)
              // ref.read(authControllerProvider).setUserState(false);
              // ZegoUIKitPrebuiltCallInvitationService().uninit();
              ref.read(userAuthStateNotifier.notifier).signOut(true);
              // Déconnexion de Firebase et Google Sign-In, en attente de leur fin
              await Future.wait([
                FirebaseAuth.instance.currentUser!.delete(),
                FirebaseAuth.instance.signOut(),
                GoogleSignIn().signOut(),
              ]).then((value) {
                ref
                    .read(infoUserStateNotifier.notifier)
                    .updateStatusUser(false, userUid);
              });
              // Ajout d'un délai pour améliorer la fluidité de l'expérience utilisateur
              await Future.delayed(const Duration(milliseconds: 1000));
              // Remettre à jour l'état de déconnexion dans le StateNotifier
              ref.read(userAuthStateNotifier.notifier).signOut(false);
              // Naviguer après la déconnexion
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AuthUserPage()),
                (Route<dynamic> route) => false,
              );

              // Après navigation, invalider les Providers
              WidgetsBinding.instance.addPostFrameCallback((_) {
                invalidateAllProviders(ref);
                _deleteUserDataInBackground(userUid);
              });
              print("Déconnexion réussie.");
            } else {
              showCustomSnackBar(
                  "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
            }
          }
        } catch (e) {
          if (FirebaseAuth.instance.currentUser != null) {
            showLoadingDialog(
                context: context, message: 'deconnexion_en_cours');

            // Mise à jour de l'état de l'utilisateur (si nécessaire)
            // ref.read(authControllerProvider).setUserState(false);
            // ZegoUIKitPrebuiltCallInvitationService().uninit();
            ref.read(userAuthStateNotifier.notifier).signOut(true);
            // Déconnexion de Firebase et Google Sign-In, en attente de leur fin
            await Future.wait([
              FirebaseAuth.instance.currentUser!.delete(),
              FirebaseAuth.instance.signOut(),
              GoogleSignIn().signOut(),
            ]).then((value) {
              ref
                  .read(infoUserStateNotifier.notifier)
                  .updateStatusUser(false, userUid);
            });
            // Ajout d'un délai pour améliorer la fluidité de l'expérience utilisateur
            await Future.delayed(const Duration(milliseconds: 1000));
            // Remettre à jour l'état de déconnexion dans le StateNotifier
            ref.read(userAuthStateNotifier.notifier).signOut(false);
            // Naviguer après la déconnexion
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => AuthUserPage()),
              (Route<dynamic> route) => false,
            );

            // Après navigation, invalider les Providers
            WidgetsBinding.instance.addPostFrameCallback((_) {
              invalidateAllProviders(ref);
              _deleteUserDataInBackground(userUid);
            });
            print("Déconnexion réussie.");
          } else {
            showCustomSnackBar(
                "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
          }
        }
      });
    } catch (e) {
      if (FirebaseAuth.instance.currentUser != null) {
        showLoadingDialog(context: context, message: 'deconnexion_en_cours');

        // Mise à jour de l'état de l'utilisateur (si nécessaire)
        // ref.read(authControllerProvider).setUserState(false);
        // ZegoUIKitPrebuiltCallInvitationService().uninit();
        ref.read(userAuthStateNotifier.notifier).signOut(true);
        // Déconnexion de Firebase et Google Sign-In, en attente de leur fin
        await Future.wait([
          FirebaseAuth.instance.currentUser!.delete(),
          FirebaseAuth.instance.signOut(),
          GoogleSignIn().signOut(),
        ]).then((value) {
          ref
              .read(infoUserStateNotifier.notifier)
              .updateStatusUser(false, userUid);
        });
        // Ajout d'un délai pour améliorer la fluidité de l'expérience utilisateur
        await Future.delayed(const Duration(milliseconds: 1000));
        // Remettre à jour l'état de déconnexion dans le StateNotifier
        ref.read(userAuthStateNotifier.notifier).signOut(false);
        // Naviguer après la déconnexion
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthUserPage()),
          (Route<dynamic> route) => false,
        );

        // Après navigation, invalider les Providers
        WidgetsBinding.instance.addPostFrameCallback((_) {
          invalidateAllProviders(ref);
          _deleteUserDataInBackground(userUid);
        });
        print("Déconnexion réussie.");
      } else {
        showCustomSnackBar(
            "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
      }
    }
  }

  void invalidateAllProviders(WidgetRef ref) {
    ref.invalidate(chatStateNotifier);
    ref.invalidate(userAuthStateNotifier);
    ref.invalidate(allUserListStateNotifier);
    ref.invalidate(infoUserStateNotifier);
    ref.invalidate(mapsUserStateNotifier);
    ref.invalidate(storieStateNotifier);
  }

  Future<void> _deleteUserDataInBackground(String uid) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      // Supprimer les sous-collections de l'utilisateur
      await _deleteSubcollections(userDocRef);
      await _deleteChatsAndMessages(userDocRef);
      await _deleteUserStories(userDocRef);
      // Supprimer le document principal de l'utilisateur
      await userDocRef.delete();
    } catch (e) {
      print("Erreur lors de la suppression des données utilisateur : $e");
    }
  }

  Future<void> _deleteUserStories(DocumentReference userDocRef) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      final storiesRef = FirebaseFirestore.instance.collection('status');

      // Récupérer les stories qui appartiennent à l'utilisateur
      final querySnapshot =
          await storiesRef.where('uid', isEqualTo: userDocRef.id).get();

      for (var doc in querySnapshot.docs) {
        batch.delete(
            doc.reference); // Ajouter chaque story au batch pour suppression
      }

      // Exécuter la suppression en lot
      await batch.commit();

      print("Suppression des stories terminée.");
    } catch (e) {
      print("Erreur lors de la suppression des stories : $e");
    }
  }

  Future<void> _deleteSubcollections(DocumentReference userDocRef) async {
    // Liste des sous-collections à supprimer
    List<String> subCollections = [
      'Notification',
      'photoProfile',
      'HighLight',
      'signalements'
    ];

    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      for (String subCollection in subCollections) {
        final subCollectionRef = userDocRef.collection(subCollection);

        // Récupérer tous les documents dans la sous-collection
        final subCollectionSnapshot = await subCollectionRef.get();
        for (var doc in subCollectionSnapshot.docs) {
          // Ajouter la suppression du document au batch
          batch.delete(doc.reference);
        }
      }

      // Exécuter le batch de suppression
      await batch.commit();
      print("Suppression des sous-collections terminée.");
    } catch (e) {
      print("Erreur générale lors de la suppression des sous-collections: $e");
    }
  }

  // Nouvelle méthode pour supprimer la collection 'chats' et ses sous-collections 'messages'
  Future<void> _deleteChatsAndMessages(DocumentReference userDocRef) async {
    WriteBatch batch = FirebaseFirestore.instance
        .batch(); // Créer un batch pour la suppression

    try {
      final chatsRef = userDocRef.collection('chats');

      // Récupérer tous les documents dans la collection 'chats'
      final chatsSnapshot = await chatsRef.get();

      for (var chatDoc in chatsSnapshot.docs) {
        // Récupérer tous les messages dans la sous-collection 'messages' de chaque chat
        final messagesRef = chatDoc.reference.collection('messages');
        final messagesSnapshot = await messagesRef.get();

        for (var messageDoc in messagesSnapshot.docs) {
          // Ajouter la suppression de chaque message au batch
          batch.delete(messageDoc.reference);
        }

        // Ajouter la suppression du document du chat au batch
        batch.delete(chatDoc.reference);
      }

      // Exécuter le batch de suppression
      await batch.commit();

      print("Suppression des chats et messages terminée.");
    } catch (e) {
      print("Erreur lors de la suppression des chats et messages : $e");
    }
  }
}
