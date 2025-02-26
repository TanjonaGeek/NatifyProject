import 'dart:io';
import 'package:natify/core/Services/NotificationService.dart';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/data/models/chat_model.dart';
import 'package:natify/features/Chat/data/models/message_model.dart';
import 'package:natify/features/Storie/data/datasources/local/data_source_story.dart';
import 'package:natify/features/Storie/data/models/story_model.dart';
import 'package:natify/features/User/data/models/notification_model.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

NotificationService notificationService = NotificationService();
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseStorage firebaseStorage = FirebaseStorage.instance;

class DataSourceStorieImpl implements DataSourceStorie {
  @override
  Future<void> DeleteStory(String photoUrl, String statusId) async {
    if (photoUrl.isEmpty || statusId.isEmpty) {
      print('Paramètres invalides');
      return;
    }

    try {
      // Référence au document Firestore
      final statusRef =
          FirebaseFirestore.instance.collection('status').doc(statusId);

      // Récupérer le document contenant le champ photoUrl
      final snapshot = await statusRef.get();

      if (snapshot.exists) {
        List<dynamic> photoUrls = snapshot.data()?['photoUrl'] ?? [];

        // Trouver l'index où l'URL correspondante est présente
        int indexToRemove =
            photoUrls.indexWhere((photo) => photo['url'] == photoUrl);

        if (indexToRemove != -1) {
          // Supprimer l'URL correspondante
          photoUrls.removeAt(indexToRemove);

          if (photoUrls.isNotEmpty) {
            // Mettre à jour le document avec les URLs restantes
            await statusRef.update({'photoUrl': photoUrls});
            print('Photo supprimée et document mis à jour');
          } else {
            // Si le tableau est vide, supprimer le document
            await statusRef.delete();
            print('Document supprimé car aucune photo n\'est restante');
          }
        } else {
          print('URL non trouvée dans le document');
        }
      } else {
        print('Le document avec statusId $statusId n\'existe pas');
      }
    } catch (e) {
      print('Erreur lors de la suppression de la story : $e');
      // Optionnel : Implémenter une logique de réessai ou d'autres actions
    }
  }

  Future<void> sendNotification(Map<String, dynamic> myData,
      Map<String, dynamic> otherData, int indexReaction) async {
    try {
      final String reagirStorie = "réagi_votre_story".tr;
      final String decouvrezPartage = "Decouvrez_partage".tr;
      final now = DateTime.now().millisecondsSinceEpoch;
      final myOwnData = UserModel.fromJson(myData);
      final OtherData = UserModel.fromJson(otherData);
      final IdNotification = const Uuid().v1();
      final dataNotification = NotificationModel(
          name: myOwnData.name,
          profilePic: myOwnData.profilePic,
          contactId: myOwnData.uid,
          timeSent: now,
          MessageNotification: "${myOwnData.name} $reagirStorie",
          statusRead: false,
          nationalite: myOwnData.nationalite,
          nombreVisiteurs: indexReaction, // Initialiser avec 1 visiteur
          type: 'reagieStorie',
          flag: myOwnData.flag,
          uidUserVisite: [
            myOwnData.uid.toString()
          ], // Initialiser avec le uid du visiteur actuel
          statusOnSee: false);
      await firestore
          .collection('users')
          .doc(OtherData.uid.toString())
          .collection('Notification')
          .doc(IdNotification)
          .set(dataNotification.toMap());

      // Envoyer la notification push après avoir inséré ou mis à jour Firestore
      await notificationService.sendNotification(OtherData,
          "${myOwnData.name} $reagirStorie ! $decouvrezPartage", 'Storie');
    } catch (e) {
      // Gestion des erreurs
      print("Erreur lors de l'ajout du visiteur : $e");
    }
  }

  @override
  Future<void> ReactStory(
      String userIdVisiteur, int indexEmoji, String urlPhotoReact) async {
    try {
      String uidMe = auth.currentUser?.uid ?? '';
      final userSnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: uidMe)
          .limit(1) // Limitation à un seul document
          .get();

      final userSnapshot2 = await firestore
          .collection('users')
          .where('uid', isEqualTo: userIdVisiteur)
          .limit(1) // Limitation à un seul document
          .get();

      if (userSnapshot.docs.isEmpty || userSnapshot2.docs.isEmpty) {
        print('No stories found for user $uidMe');
        return;
      }
      if (uidMe.isEmpty) {
        throw Exception('User not authenticated');
      }

      final userDoc = userSnapshot.docs.first;
      final userDoc2 = userSnapshot2.docs.first;
      final userData = userDoc.data();
      final userData2 = userDoc2.data();

      // Calcule du cutoff time pour exclure les stories créées il y a plus de 24 heures
      int cutoffTime = DateTime.now()
          .subtract(const Duration(hours: 24))
          .millisecondsSinceEpoch;

      // Fetch the story document for the given user
      final statusesSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: userIdVisiteur)
          .where('createdAt', isGreaterThanOrEqualTo: cutoffTime)
          .limit(1) // Limitation à un seul document
          .get();

      if (statusesSnapshot.docs.isEmpty) {
        print('No stories found for user $userIdVisiteur');
        return;
      }

      // Get the first document
      final statusDoc = statusesSnapshot.docs.first;
      final statusData = statusDoc.data();
      final List<dynamic> uidWhoCanSee =
          List.from(statusData['QuivoirStorie'] ?? []);

      // Find or create the reaction data
      final userReactionData = uidWhoCanSee.firstWhere(
        (element) =>
            element['uid'] == uidMe && element['photoUrl'] == urlPhotoReact,
        orElse: () => null,
      );

      if (userReactionData == null) {
        // If no reaction data exists, create it
        uidWhoCanSee.add({
          'uid': uidMe,
          'photoUrl': urlPhotoReact,
          'reaction': [indexEmoji],
        });
      } else {
        // Update existing reaction data
        List<dynamic> listMyOwnReactionStatus =
            List.from(userReactionData['reaction'] ?? []);
        listMyOwnReactionStatus.add(indexEmoji);
        userReactionData['reaction'] = listMyOwnReactionStatus;
      }

      // Update the story document
      await firestore
          .collection('status')
          .doc(statusDoc.id)
          .update({'QuivoirStorie': uidWhoCanSee});

      await sendNotification(userData, userData2, indexEmoji);
    } catch (e) {
      // Log the error properly
      print('Failed to react to story: $e');
      // Optionally, handle specific error types (e.g., network issues)
    }
  }

  @override
  Future<void> ViewStory(String uidUser, String photoUrl) async {
    try {
      String uidMe = auth.currentUser?.uid ?? '';
      if (uidMe.isEmpty || uidUser.isEmpty || photoUrl.isEmpty) {
        throw Exception('Invalid parameters');
      }

      // Calcul du cutoff time pour exclure les stories créées il y a plus de 24 heures
      int cutoffTime = DateTime.now()
          .subtract(const Duration(hours: 24))
          .millisecondsSinceEpoch;

      // Récupération des stories récentes
      var statusesSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: uidUser)
          .where('createdAt', isGreaterThanOrEqualTo: cutoffTime)
          .limit(1) // Limite à un seul document pour optimiser
          .get();

      if (statusesSnapshot.docs.isNotEmpty) {
        StorieModel status =
            StorieModel.fromJson(statusesSnapshot.docs[0].data());
        List<Map<String, dynamic>> uidWhoCanSee =
            List.from(status.QuivoirStorie ?? []);

        // Vérifie si l'utilisateur a déjà vu cette story
        bool alreadySeen = uidWhoCanSee.any(
            (item) => item['uid'] == uidMe && item['photoUrl'] == photoUrl);

        if (!alreadySeen) {
          uidWhoCanSee.add({
            'uid': uidMe,
            'reaction': [],
            'photoUrl': photoUrl,
          });

          // Mise à jour du document Firestore
          await firestore
              .collection('status')
              .doc(statusesSnapshot.docs[0].id)
              .update({
            'QuivoirStorie': uidWhoCanSee,
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de QuivoirStorie: $e');
      // Utilisez un service de journalisation ou notifiez l'utilisateur
    }
  }

  Future<String> storeFileToFirebase(
      String ref, List<File> files, String title) async {
    if (files.isEmpty) {
      throw Exception('Aucun fichier à télécharger.');
    }

    String downloadUrl = "";
    final file = files.first;
    final fileExtension = p.extension(file.path);

    // Définition des types MIME pour certains types de fichiers
    final mimeTypeMap = {
      '.jpg': 'image/jpeg',
      '.png': 'image/png',
      '.mp4': 'video/mp4',
      '.pdf': 'application/pdf',
      // Ajoutez d'autres types MIME si nécessaire
    };

    final contentType =
        mimeTypeMap[fileExtension] ?? 'application/octet-stream';

    try {
      // Préparation de l'upload
      UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(
            file,
            SettableMetadata(contentType: contentType),
          );

      print('Importation en cours ...');

      // Écoute de la progression de l'upload
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnap) {
        double progress =
            100.0 * (taskSnap.bytesTransferred / taskSnap.totalBytes);
        print('Importation ${progress.toStringAsFixed(0)} %');
        // Implémentez ici la logique de notification si nécessaire
      });

      // Attendre la complétion de l'upload
      await uploadTask.whenComplete(() async {
        downloadUrl = await uploadTask.snapshot.ref.getDownloadURL();
        print('Importation terminée');
      });
    } catch (e) {
      print('Erreur lors de l\'importation: $e');
      throw Exception('Échec de l\'importation du fichier');
    }

    // Retourne l'URL avec l'extension
    String urlWithExtension = "$downloadUrl$fileExtension";
    return urlWithExtension;
  }

  @override
  Future<void> createStory(List<File> statusImages, String type) async {
    if (statusImages.isEmpty) {
      throw Exception('Aucune image sélectionnée');
    }

    try {
      var statusId = const Uuid().v1();
      var timeSent = DateTime.now().millisecondsSinceEpoch;
      String uid = auth.currentUser!.uid;
      String ref = "/status/$uid/$statusId$uid";
      String title = "Importation story";

      // Préparation des structures de données
      List<Map<String, dynamic>> uidWhoCanSee = [];
      List<Map<String, dynamic>> statusImageUrls = [];

      // Importer l'image vers Firebase Storage et récupérer l'URL
      String imageUrl = await storeFileToFirebase(ref, statusImages, title);

      // Récupérer les données de l'utilisateur
      var userData = await firestore.collection('users').doc(uid).get();
      UserModel user = UserModel.fromJson(userData.data()!);

      // Récupérer les stories existantes de l'utilisateur, si elles existent
      var statusesSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: uid)
          .where(
            'createdAt',
            isGreaterThan: DateTime.now()
                .subtract(const Duration(hours: 24))
                .millisecondsSinceEpoch,
          )
          .limit(1) // Limiter la requête à un seul document
          .get();

      if (statusesSnapshot.docs.isNotEmpty) {
        // Si une story existe, ajouter l'image à la liste
        var status = StorieModel.fromJson(statusesSnapshot.docs.first.data());
        statusImageUrls = status.photoUrl ?? [];
        statusImageUrls.add({
          'url': imageUrl,
          'timeSent': timeSent,
          'type': type,
        });
        print('le donner duppliquer');
        await firestore
            .collection('status')
            .doc(statusesSnapshot.docs.first.id)
            .update({
          'photoUrl': statusImageUrls,
          'createdAt': timeSent,
        });
      } else {
        // Sinon, créer une nouvelle story
        statusImageUrls.add({
          'url': imageUrl,
          'timeSent': timeSent,
          'type': type,
        });

        StorieModel newStatus = StorieModel(
            uid: uid,
            username: user.name,
            photoUrl: statusImageUrls,
            createdAt: timeSent,
            profilePic: user.profilePic,
            statusId: statusId,
            QuivoirStorie: uidWhoCanSee,
            storyAvailableForUser: []);

        await firestore
            .collection('status')
            .doc(statusId)
            .set(newStatus.toMap());
      }
    } catch (e) {
      print('Erreur lors de la création de la story: $e');
      throw Exception('Erreur lors de la création de la story');
    }
  }

  @override
  Future<Map<String, dynamic>> getAllStory(
      DocumentSnapshot? lastDocument, int limit) async {
    try {
      int cutoffTime = DateTime.now()
          .subtract(const Duration(hours: 24))
          .millisecondsSinceEpoch;

      // Construire la requête Firestore
      Query query = firestore
          .collection('status')
          .where('createdAt', isGreaterThanOrEqualTo: cutoffTime)
          .orderBy('createdAt')
          .limit(limit);

      // Si un dernier document est fourni, continuer à partir de celui-ci (pagination)
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // Exécuter la requête et obtenir les snapshots
      QuerySnapshot snapshot = await query.get();

      // Vérifier s'il y a des documents
      if (snapshot.docs.isEmpty) {
        return {
          'storie': [],
          'lastDocument': null,
        };
      }

      // Extraire les stories à partir des documents
      List<Map<String, dynamic>> storie = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Retourner les stories et le dernier document pour la pagination
      return {
        'storie': storie,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      print('Erreur lors de la récupération des stories: $e');
      throw Exception('Erreur lors de la récupération des stories');
    }
  }

  @override
  Future<void> ReplyStory(String text, String receiverUserId,
      String messageReply, String type) async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final uuid = Uuid();
    final timeSent = DateTime.now();
    final senderUserId = auth.currentUser!.uid;

    try {
      // Fetch user data for receiver and sender
      final receiverUserSnapshot =
          await firestore.collection('users').doc(receiverUserId).get();
      final senderUserSnapshot =
          await firestore.collection('users').doc(senderUserId).get();

      if (!receiverUserSnapshot.exists || !senderUserSnapshot.exists) {
        throw Exception('User data not found');
      }

      final receiverUserData = UserModel.fromJson(receiverUserSnapshot.data()!);
      final senderUserData = UserModel.fromJson(senderUserSnapshot.data()!);

      final messageId = uuid.v1();

      // Save data to contacts subcollection
      await _saveDataToContactsSubcollection(
        senderUserData: senderUserData,
        receiverUserData: receiverUserData,
        text: text,
        timeSent: timeSent,
        receiverUserId: receiverUserId,
      );
      print('le type de video est $type');
      // Save message to message subcollection
      await _saveMessageToMessageSubcollection(
        receiverUserId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        messageType: MessageEnum.text,
        messageReplySender:
            type == "video" ? MessageEnum.video : MessageEnum.image,
        messageReply: messageReply,
        senderUsername: senderUserData.name ?? '',
        receiverUserName: receiverUserData.name,
        senderUserData: senderUserData,
        receiverUserData: receiverUserData,
      );
    } catch (e) {
      print('Error replying to story: $e');
      throw Exception('Failed to reply to story');
    }
  }

  Future<void> _saveDataToContactsSubcollection({
    required UserModel senderUserData,
    required UserModel receiverUserData,
    required String text,
    required DateTime timeSent,
    required String receiverUserId,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final senderUserId = senderUserData.uid;

    try {
      // Update or create chat data for receiver's contact
      final receiverChatContact = ChatModel(
        name: senderUserData.name ?? '',
        profilePic: senderUserData.profilePic ?? '',
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        statusBlock: false,
        statusRead: false,
        statusTyping: false,
        checkStatusReadOnOther: false,
        messageLastBy: senderUserId,
        flag: senderUserData.flag ?? '',
      );

      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(senderUserId)
          .set(receiverChatContact.toMap(), SetOptions(merge: true));

      // Update or create chat data for sender's contact
      final senderChatContact = ChatModel(
        name: receiverUserData.name ?? '',
        profilePic: receiverUserData.profilePic ?? '',
        contactId: receiverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        statusBlock: false,
        statusRead: true,
        checkStatusReadOnOther: false,
        messageLastBy: senderUserId,
        flag: receiverUserData.flag ?? '',
      );

      await firestore
          .collection('users')
          .doc(senderUserId)
          .collection('chats')
          .doc(receiverUserId)
          .set(senderChatContact.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving data to contacts subcollection: $e');
      throw Exception('Failed to save contact data');
    }
  }

  Future<void> _saveMessageToMessageSubcollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String senderUsername,
    required String? receiverUserName,
    required MessageEnum messageType,
    required MessageEnum messageReplySender,
    required String? messageReply,
    required UserModel senderUserData,
    required UserModel receiverUserData,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final senderUserId = senderUserData.uid;

    try {
      final message = MessageModel(
        senderId: senderUserId,
        recieverid: receiverUserId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false,
        repliedMessage: messageReply ?? '',
        repliedTo: senderUsername,
        repliedMessageType: messageReplySender,
        reactMessageSingle: [],
        reactMessageReply: [],
      );

      // Save message for sender
      await firestore
          .collection('users')
          .doc(senderUserId)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap(), SetOptions(merge: true));

      // Save message for receiver
      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(senderUserId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving message to subcollection: $e');
      throw Exception('Failed to save message data');
    }
  }

  @override
  Future<void> sendNotificationToFollowers() async {
    try {
      // Récupérer les données de l'utilisateur actuel
      var userData =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();
      UserModel currentUser = UserModel.fromJson(userData.data()!);

      // Vérifie s'il y a des abonnés
      if (currentUser.availableSendNotification != null &&
          currentUser.availableSendNotification!.isNotEmpty) {
        // Liste pour stocker les tokens FCM des abonnés
        List<String> tokens = [];

        // Récupérer les tokens FCM pour chaque abonné
        for (String followerUid in currentUser.availableSendNotification!) {
          var followerData =
              await firestore.collection('users').doc(followerUid).get();
          UserModel follower = UserModel.fromJson(followerData.data()!);

          if (follower.tokenNotification != null) {
            tokens.add(follower.tokenNotification!);
          }
        }
        String textMessageStory =
            "a partagé une nouvelle story ! Découvrez-la avant qu'elle ne disparaisse."
                .tr;
        String messageTitle = "Nouvelle story".tr;
        String message = "${currentUser.name} $textMessageStory";
        // Envoyer la notification via FCM en utilisant les tokens récupérés
        await notificationService.sendNotificationForAll(
            currentUser, message, messageTitle, tokens);
        print("Notifications envoyées avec succès aux abonnés.");
      } else {
        print("Aucun abonné à notifier.");
      }
    } catch (e) {
      print("Erreur lors de l'envoi de la notification : $e");
    }
  }
}
