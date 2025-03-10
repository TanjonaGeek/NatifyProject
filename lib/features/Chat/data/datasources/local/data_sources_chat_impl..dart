import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:natify/core/Services/NotificationService.dart';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/data/datasources/local/data_source_chat.dart';
import 'package:natify/features/Chat/data/models/chat_model.dart';
import 'package:natify/features/Chat/data/models/message_model.dart';
import 'package:natify/features/Chat/data/models/theme_message_model.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

NotificationService notificationService = NotificationService();
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseStorage firebaseStorage = FirebaseStorage.instance;

class DataSourceChatImpl implements DataSourceChat {
  @override
  Future<void> BloquePersonne(String uidUser) async {
    try {
      String uidMe = auth.currentUser!.uid;
      final userSnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: uidMe)
          .limit(1) // Limitation à un seul document
          .get();
      if (userSnapshot.docs.isEmpty) {
        return;
      }
      final userDoc = userSnapshot.docs.first;
      final userData = userDoc.data();
      final List<dynamic> userBlocked =
          List.from(userData['friendBlocked'] ?? []);
      final userBlockedData = userBlocked.firstWhere(
        (element) => element == uidUser,
        orElse: () => null,
      );
      if (userBlockedData == null) {
        // If no reaction data exists, create it
        userBlocked.add(uidUser);
      }
      await firestore
          .collection('users')
          .doc(uidMe)
          .update({'friendBlocked': userBlocked});
      await firestore
          .collection('users')
          .doc(uidUser)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .update({'statusBlock': true});
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> DebloquerPersonne(String uidUser) async {
    try {
      String uidMe = auth.currentUser!.uid;
      final userSnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: uidMe)
          .limit(1) // Limitation à un seul document
          .get();
      if (userSnapshot.docs.isEmpty) {
        return;
      }
      final userDoc = userSnapshot.docs.first;
      final userData = userDoc.data();
      final List<dynamic> userBlocked =
          List.from(userData['friendBlocked'] ?? []);
      final userBlockedData = userBlocked.firstWhere(
        (element) => element == uidUser,
        orElse: () => null,
      );
      if (userBlockedData != null) {
        // If no reaction data exists, create it
        userBlocked.remove(uidUser);
      }
      await firestore
          .collection('users')
          .doc(uidMe)
          .update({'friendBlocked': userBlocked});
      await firestore
          .collection('users')
          .doc(uidUser)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .update({'statusBlock': false});
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> ReactMessage(
    String reaction,
    String messageUid,
    String userUid,
    bool isReplyMessage,
  ) async {
    try {
      final currentUserUid = auth.currentUser!.uid;

      // Déterminer le champ de réaction à mettre à jour
      final reactField =
          isReplyMessage ? 'reactMessageReply' : 'reactMessageSingle';

      // Obtenir le document du message pour les deux utilisateurs
      final messageDocUser = firestore
          .collection('users')
          .doc(userUid)
          .collection('chats')
          .doc(currentUserUid)
          .collection('messages')
          .doc(messageUid);

      final messageDocCurrent = firestore
          .collection('users')
          .doc(currentUserUid)
          .collection('chats')
          .doc(userUid)
          .collection('messages')
          .doc(messageUid);

      // Récupérer les données actuelles du message
      final snapshot = await messageDocUser.get();
      if (!snapshot.exists) {
        print('Message non trouvé');
        return;
      }

      final messageData = snapshot.data() as Map<String, dynamic>;
      final List<Map<String, String>> reactions =
          (messageData[reactField] ?? [])
              .map<Map<String, String>>(
                  (reaction) => Map<String, String>.from(reaction as Map))
              .toList();

      // Vérifier si une réaction de cet utilisateur existe déjà
      final existingReactionIndex =
          reactions.indexWhere((r) => r['uid'] == currentUserUid);

      if (existingReactionIndex != -1) {
        // Mettre à jour la réaction existante
        reactions[existingReactionIndex]['reaction'] = reaction;
      } else {
        // Ajouter une nouvelle réaction
        reactions.add({'uid': currentUserUid, 'reaction': reaction});
      }

      // Mettre à jour la réaction pour les deux utilisateurs
      await messageDocUser.update({reactField: reactions});
      await messageDocCurrent.update({reactField: reactions});
      String reagiA = "Vous_avez_reagi".tr;
      String aReponse = "une_reponse".tr;
      String aMessage = "une_message".tr;
      // Mettre à jour le dernier message pour indiquer la réaction
      final lastMessageText = isReplyMessage
          ? "$reagiA ($reaction) $aReponse"
          : "$reagiA ($reaction) $aMessage";

      await firestore
          .collection('users')
          .doc(currentUserUid)
          .collection('chats')
          .doc(userUid)
          .update({'lastMessage': lastMessageText});

      await firestore
          .collection('users')
          .doc(userUid)
          .collection('chats')
          .doc(currentUserUid)
          .update({'lastMessage': "A réagi ($reaction) à un message"});
    } catch (e) {
      print('Erreur lors de la réaction : $e');
    }
  }

  @override
  Future<void> DeleteMessage(String messageUid, String userUid, int timesent,
      bool isDeleteForMe) async {
    try {
      final lastMessageSnapshot = await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(userUid)
          .get();
      final lastMessageData = ChatModel.fromJson(lastMessageSnapshot.data()!);
      final timesentChat = lastMessageData.timeSent!.millisecondsSinceEpoch;
      if (isDeleteForMe == false) {
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('chats')
            .doc(userUid)
            .collection('messages')
            .doc(messageUid)
            .update({'text': 'messageretirerforme'});
        if (timesentChat == timesent) {
          await firestore
              .collection('users')
              .doc(auth.currentUser!.uid)
              .collection('chats')
              .doc(userUid)
              .update({'lastMessage': 'messageretirerforme'});
        }
      } else {
        await firestore
            .collection('users')
            .doc(userUid)
            .collection('chats')
            .doc(auth.currentUser!.uid)
            .collection('messages')
            .doc(messageUid)
            .update({'text': 'messageretirerforall'});
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('chats')
            .doc(userUid)
            .collection('messages')
            .doc(messageUid)
            .update({'text': 'messageretirerforall'});
        if (timesentChat == timesent) {
          await firestore
              .collection('users')
              .doc(userUid)
              .collection('chats')
              .doc(auth.currentUser!.uid)
              .update({'lastMessage': 'messageretirerforall'});
          await firestore
              .collection('users')
              .doc(auth.currentUser!.uid)
              .collection('chats')
              .doc(userUid)
              .update({'lastMessage': 'messageretirerforall'});
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> SendMessage(
    String text,
    String receiverUserId,
    String messageReply,
    MessageEnum messageReplyType,
    MessageEnum messageEnum,
    List<File> files,
    String urlGif,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final uuid = Uuid();
    final timeSent = DateTime.now();
    final senderUserId = auth.currentUser!.uid;

    try {
      // Fetch user data for receiver and sender concurrently
      final fetchUsers = Future.wait([
        firestore.collection('users').doc(receiverUserId).get(),
        firestore.collection('users').doc(senderUserId).get(),
      ]);
      final results = await fetchUsers;
      final receiverUserSnapshot = results[0];
      final senderUserSnapshot = results[1];

      if (!receiverUserSnapshot.exists || !senderUserSnapshot.exists) {
        throw Exception('User data not found');
      }

      final receiverUserData = UserModel.fromJson(receiverUserSnapshot.data()!);
      final senderUserData = UserModel.fromJson(senderUserSnapshot.data()!);
      String urlFile = "";
      final messageId = uuid.v1();
      String contactMsg = getContactMessage(messageEnum);
      if (files.isNotEmpty) {
        String ref =
            "/chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId";
        urlFile = await storeFileToFirebase(ref, files, "Importation fichier");
      }
      // Prepare message data
      final messageData = {
        'text': messageEnum == MessageEnum.gif ? urlGif : text,
        'type': messageEnum,
        'timeSent': timeSent,
        'messageId': messageId,
        'messageReplySender': messageReplyType,
        'messageReply': messageReply,
        'urlFile': urlFile,
      };
      if (files.isNotEmpty) {
        // Prepare and execute batch write
        final batch = firestore.batch();

        await _prepareBatch(
          batch: batch,
          senderUserData: senderUserData,
          receiverUserData: receiverUserData,
          contactMsg: contactMsg,
          messageData: messageData,
          receiverUserId: receiverUserId,
          senderUserId: senderUserId,
        );

        await batch.commit();
        await notificationService.sendNotification(
            receiverUserData, "Envoi $contactMsg", senderUserData.name!);
      } else {
        // Prepare and execute batch write
        final batch = firestore.batch();
        await _prepareBatch(
          batch: batch,
          senderUserData: senderUserData,
          receiverUserData: receiverUserData,
          contactMsg: contactMsg,
          messageData: messageData,
          receiverUserId: receiverUserId,
          senderUserId: senderUserId,
        );
        await batch.commit();
        if (contactMsg == "Text") {
          await notificationService.sendNotification(
              receiverUserData, text, senderUserData.name!);
        } else if (contactMsg == "GIF") {
          await notificationService.sendNotification(
              receiverUserData, "Envoi $contactMsg", senderUserData.name!);
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message');
    }
  }

  Future<void> _prepareBatch({
    required WriteBatch batch,
    required UserModel senderUserData,
    required UserModel receiverUserData,
    required String contactMsg,
    required Map<String, dynamic> messageData,
    required String receiverUserId,
    required String senderUserId,
  }) async {
    // Save message to message subcollection
    batch.set(
      FirebaseFirestore.instance
          .collection('users')
          .doc(senderUserId)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageData['messageId']),
      MessageModel(
        senderId: senderUserId,
        recieverid: receiverUserId,
        text: messageData['urlFile'] != ""
            ? messageData['urlFile']
            : messageData['text'],
        type: messageData['type'],
        timeSent: messageData['timeSent'],
        messageId: messageData['messageId'],
        isSeen: false,
        repliedMessage: messageData['messageReply'] ?? '',
        repliedTo: senderUserData.name,
        repliedMessageType:
            messageData['messageReplySender'] == MessageEnum.text
                ? MessageEnum.text
                : messageData['messageReplySender'],
        reactMessageSingle: [],
        reactMessageReply: [],
      ).toMap(),
      SetOptions(merge: true),
    );
    batch.set(
      FirebaseFirestore.instance
          .collection('users')
          .doc(senderUserId)
          .collection('chats')
          .doc(receiverUserId),
      ChatModel(
        name: receiverUserData.name ?? '',
        profilePic: receiverUserData.profilePic ?? '',
        contactId: receiverUserData.uid,
        timeSent: messageData['timeSent'],
        lastMessage: messageData['type'] == MessageEnum.text
            ? messageData['text']
            : contactMsg,
        statusBlock: false,
        statusRead: true,
        checkStatusReadOnOther: false,
        messageLastBy: senderUserId,
        flag: receiverUserData.flag ?? '',
      ).toMap(),
      SetOptions(merge: true),
    );
    batch.set(
      FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(senderUserId)
          .collection('messages')
          .doc(messageData['messageId']),
      MessageModel(
        senderId: senderUserId,
        recieverid: receiverUserId,
        text: messageData['urlFile'] != ""
            ? messageData['urlFile']
            : messageData['text'],
        type: messageData['type'],
        timeSent: messageData['timeSent'],
        messageId: messageData['messageId'],
        isSeen: false,
        repliedMessage: messageData['messageReply'] ?? '',
        repliedTo: senderUserData.name,
        repliedMessageType:
            messageData['messageReplySender'] == MessageEnum.text
                ? MessageEnum.text
                : messageData['messageReplySender'],
        reactMessageSingle: [],
        reactMessageReply: [],
      ).toMap(),
      SetOptions(merge: true),
    );
    // Save data to contacts subcollection
    batch.set(
      FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(senderUserId),
      ChatModel(
        name: senderUserData.name ?? '',
        profilePic: senderUserData.profilePic ?? '',
        contactId: senderUserData.uid,
        timeSent: messageData['timeSent'],
        lastMessage: messageData['type'] == MessageEnum.text
            ? messageData['text']
            : contactMsg,
        statusBlock: false,
        statusRead: false,
        statusTyping: false,
        checkStatusReadOnOther: false,
        messageLastBy: senderUserId,
        flag: senderUserData.flag ?? '',
      ).toMap(),
      SetOptions(merge: true),
    );
  }

  Future<String> storeFileToFirebase(
      String ref, List<File> files, String title) async {
    if (files.isEmpty) {
      throw Exception('Aucun fichier à télécharger.');
    }

    final file = files.first;
    final fileExtension = p.extension(file.path);
    final mimeTypeMap = {
      '.jpg': 'image/jpeg',
      '.png': 'image/png',
      '.mp4': 'video/mp4',
      '.mp3': 'audio/mp3',
      '.wav': 'audio/.wav',
      '.aac': 'audio/.aac',
      '.ogg': 'audio/.ogg',
      '.pdf': 'application/pdf',
    };

    final contentType =
        mimeTypeMap[fileExtension] ?? 'application/octet-stream';
    final storageRef = FirebaseStorage.instance.ref().child(ref);
    final uploadTask = storageRef.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );

    try {
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'importation: $e');
      throw Exception('Échec de l\'importation du fichier');
    }
  }

  String getContactMessage(MessageEnum messageEnum) {
    switch (messageEnum) {
      case MessageEnum.image:
        return '📷 Photo';
      case MessageEnum.video:
        return '📸 Video';
      case MessageEnum.audio:
        return '🎵 Audio';
      case MessageEnum.gif:
        return 'GIF';
      case MessageEnum.music:
        return '🎵 Music';
      default:
        return 'Text';
    }
  }

  @override
  Future<void> activeTyping(String uidUser, bool status) async {
    try {
      var contactDataMap = await firestore
          .collection('users')
          .doc(uidUser)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .get();
      if (contactDataMap.exists) {
        await firestore
            .collection('users')
            .doc(uidUser)
            .collection('chats')
            .doc(auth.currentUser!.uid)
            .update({'statusTyping': status});
      }
      print('le typing indicator est afficher');
    } catch (e) {
      print(e);
    }
  }

  @override
  Stream<bool> getStatusTyping(String uidUser) {
    late bool statusTyping;
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(uidUser)
        .snapshots()
        .map((event) {
      if (event.exists) {
        statusTyping = event.get('statusTyping');
      } else {
        statusTyping = false;
      }
      return statusTyping;
    });
  }

  @override
  Stream<List<UserModel>> getStatusOnline(String uidUser) {
    return firestore
        .collection('users')
        .where('uid', isEqualTo: uidUser)
        .snapshots()
        .map((event) {
      List<UserModel> allUser = [];
      for (var document in event.docs) {
        allUser.add(UserModel.fromJson(document.data()));
      }
      return allUser;
    });
  }

  @override
  Future<void> unreadMessage(String recieverUserId) async {
    try {
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .get();
      if (data.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('chats')
            .doc(recieverUserId)
            .update({
          'statusRead': true,
        });

        //
        await FirebaseFirestore.instance
            .collection('users')
            .doc(recieverUserId)
            .collection('chats')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'checkStatusReadOnOther': true});

        final chatRef = FirebaseFirestore.instance
            .collection('users')
            .doc(recieverUserId)
            .collection('chats')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('messages');
        final querySnapshot =
            await chatRef.where('isSeen', isEqualTo: false).get();

        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var doc in querySnapshot.docs) {
          batch.update(doc.reference, {'isSeen': true});
        }
        await batch.commit();
      } else {
        print('tsy misy');
      }
      print('unreadMessage success');
    } catch (e) {
      print(e);
    }
  }

  @override
  Stream<bool> getStatusBlock(String uidUser) {
    try {
      return firestore
          .collection('users')
          .doc(uidUser)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .snapshots()
          .map((event) {
        bool statusBlock;
        if (event.exists) {
          statusBlock = event.get('statusBlock');
        } else {
          statusBlock = false;
        }
        return statusBlock;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<bool> getStatusBlockOnChat(String uidUser) {
    try {
      return firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(uidUser)
          .snapshots()
          .map((event) {
        bool statusBlock;
        if (event.exists) {
          statusBlock = event.get('statusBlock');
        } else {
          statusBlock = false;
        }
        return statusBlock;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> desappearMessageInList(String receiverUserId) async {
    try {
      // Supprimer le document du chat avec l'utilisateur
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .delete();

      // Supprimer les messages en arrière-plan
      _deleteMessagesInBackground(receiverUserId);

      print("Suppression du chat principale effectuée");
    } catch (e) {
      print("Erreur lors de la suppression des messages: $e");
    }
  }

  void _deleteMessagesInBackground(String receiverUserId) async {
    try {
      // Supprimer tous les messages de la sous-collection 'messages'
      final messagesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages');

      final messagesSnapshot = await messagesCollection.get();

      for (var messageDoc in messagesSnapshot.docs) {
        // Utilisez `Future.delayed` pour introduire une légère pause entre les suppressions si nécessaire
        await Future.microtask(() async => await messageDoc.reference.delete());
      }

      print("Tous les messages ont été supprimés en arrière-plan");
    } catch (e) {
      print("Erreur lors de la suppression des messages en arrière-plan: $e");
    }
  }

  @override
  Future<void> ChangeThemeMessage(
    List<Map<String, String>> dataThemeMessage,
    String uidSendMessage,
  ) async {
    try {
      final dataTheme = ThemeMessageModel(
        themeMessage: dataThemeMessage,
      );

      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(uidSendMessage)
          .collection('theme')
          .doc(
              'currentTheme') // Ajout d'un doc pour éviter d'écraser toute la collection
          .set(dataTheme.toMap(), SetOptions(merge: true));
      await firestore
          .collection('users')
          .doc(uidSendMessage)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('theme')
          .doc(
              'currentTheme') // Ajout d'un doc pour éviter d'écraser toute la collection
          .set(dataTheme.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors du changement de thème : $e');
    }
  }
}
