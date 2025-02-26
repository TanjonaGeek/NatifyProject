import 'package:natify/features/User/presentation/pages/auth/AuthUserPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountDeletionService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        // Si l'utilisateur n'est pas connecté
        throw Exception("Aucun utilisateur connecté");
      }
      // showLoadingDialog(context: context, message: 'Déconnexion en cours');

      // Déconnexion et suppression immédiate de l'utilisateur
      await user.delete();
      await Future.delayed(const Duration(milliseconds: 300));
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      // Redirection vers la page de connexion après déconnexion
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => AuthUserPage(),
        ),
        (Route<dynamic> route) => false,
      );

      // Lancer la suppression des sous-collections en arrière-plan
      _deleteUserDataInBackground(user.uid);
    } catch (e) {
      // Si une erreur se produit, l'afficher
      print("Erreur de suppression du compte : $e");
    }
  }

  Future<void> _deleteUserDataInBackground(String uid) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      // Supprimer les sous-collections de l'utilisateur
      await _deleteSubcollections(userDocRef);
      await _deleteChatsAndMessages(userDocRef);
      // Supprimer le document principal de l'utilisateur
      await userDocRef.delete();
    } catch (e) {
      print("Erreur lors de la suppression des données utilisateur : $e");
    }
  }

  Future<void> _deleteSubcollections(DocumentReference userDocRef) async {
    // Liste des sous-collections à supprimer
    List<String> subCollections = ['Notification', 'photoProfile', 'HighLight'];

    for (String subCollection in subCollections) {
      final subCollectionRef = userDocRef.collection(subCollection);

      // Récupérer tous les documents dans la sous-collection
      final subCollectionSnapshot = await subCollectionRef.get();
      for (var doc in subCollectionSnapshot.docs) {
        // Supprimer chaque document dans la sous-collection
        await doc.reference.delete();
      }
    }
  }

  // Nouvelle méthode pour supprimer la collection 'chats' et ses sous-collections 'messages'
  Future<void> _deleteChatsAndMessages(DocumentReference userDocRef) async {
    try {
      final chatsRef = userDocRef.collection('chats');

      // Récupérer tous les documents dans la collection 'chats'
      final chatsSnapshot = await chatsRef.get();

      for (var chatDoc in chatsSnapshot.docs) {
        // Supprimer les messages dans la sous-collection 'messages' de chaque chat
        final messagesRef = chatDoc.reference.collection('messages');
        final messagesSnapshot = await messagesRef.get();

        for (var messageDoc in messagesSnapshot.docs) {
          // Supprimer chaque message dans la sous-collection 'messages'
          await messageDoc.reference.delete();
        }

        // Supprimer le document du chat après avoir supprimé ses messages
        await chatDoc.reference.delete();
      }
    } catch (e) {
      print("Erreur lors de la suppression des chats et messages : $e");
    }
  }
}
