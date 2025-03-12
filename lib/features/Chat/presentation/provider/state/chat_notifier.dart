import 'dart:async';
import 'dart:io';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseAppearMessageInList.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseBloqueMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseChangeThemeMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseDebloqueMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseDeleteMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseGetStatusBloqueOnChat.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseGetStatusTyping.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseGetStatusbloque.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseSendMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseTypingIndicator.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseUnreadMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCasegetStatusOnline.dart';
import 'package:natify/features/Chat/domaine/usecases/useCasesReactMessage.dart';
import 'package:natify/features/Chat/presentation/provider/state/chat_state.dart';
import 'package:natify/features/Storie/presentation/provider/state/storie_state.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/injector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  final KeyboardVisibilityController _keyboardVisibilityController;
  final String uid;
  final UseCaseSendMessage _sendMessage = injector.get<UseCaseSendMessage>();
  final UseCaseDeleteMessage _deleteMessage =
      injector.get<UseCaseDeleteMessage>();
  final UseCaseTypingIndicator _typingIndicator =
      injector.get<UseCaseTypingIndicator>();
  final UseCaseStatusTyping _statusTypingIndicator =
      injector.get<UseCaseStatusTyping>();
  final UseCaseStatusOnline _statusOnline = injector.get<UseCaseStatusOnline>();
  final UseCaseUnreadMessage _unreadMessage =
      injector.get<UseCaseUnreadMessage>();
  final UseCaseBloqueMessage _bloqueConversation =
      injector.get<UseCaseBloqueMessage>();
  final UseCaseDebloqueMessage _debloqueConversation =
      injector.get<UseCaseDebloqueMessage>();
  final UseCaseGetStatusBloque _statusBloqueConversation =
      injector.get<UseCaseGetStatusBloque>();
  final UseCaseGetStatusBloqueOnChat _statusBloqueConversationOnChat =
      injector.get<UseCaseGetStatusBloqueOnChat>();
  final UseCaseDesappearMessageInlist _desappearMessageInlist =
      injector.get<UseCaseDesappearMessageInlist>();
  final UseCaseReactMessage _reactMessage = injector.get<UseCaseReactMessage>();
  final UseCaseChangeThemeMessage _changeThemeMessage =
      injector.get<UseCaseChangeThemeMessage>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  late final StreamSubscription<bool> _keyboardSubscription;

  ChatNotifier(this._keyboardVisibilityController, this.uid)
      : super(ChatState.initial()) {
    _keyboardSubscription =
        _keyboardVisibilityController.onChange.listen((bool visible) {
      activeTyping(uid, visible);
    });
  }
  @override
  void dispose() {
    _keyboardSubscription.cancel(); // Annule l'écoute du stream
    super.dispose();
  }

  bool get isFetching => state.state != StorieListConcreteState.loading;

  Future<void> sendMessage(
      BuildContext context,
      String text,
      String recieverUserId,
      List<Map<String, dynamic>> messageReply,
      MessageEnum messageEnum,
      List<File> file,
      String urlGif) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion Internet.");
        return;
      }
      if (messageReply.isEmpty) {
        _sendMessage.call(text, recieverUserId, '', MessageEnum.text,
            messageEnum, file, urlGif);
      } else {
        _sendMessage.call(text, recieverUserId, messageReply.first['message'],
            messageReply.first['typeMessage'], messageEnum, file, urlGif);
      }
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> changeThemeMessage(
      List<Map<String, String>> dataThemeMessage, String uidSendMessage) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion Internet.");
        return;
      }
      _changeThemeMessage.call(dataThemeMessage, uidSendMessage);
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  void getReplyMessage(List<Map<String, dynamic>> dataMessage) {
    state = state.copyWith(
      messageReply: dataMessage,
      state: ChatListConcreteState.loaded,
      isLoading: false,
    );
  }

  void cancelReply() {
    activeTyping(uid, false);
    state = state.copyWith(
      messageReply: [],
      state: ChatListConcreteState.loaded,
      isLoading: false,
    );
  }

  void deleteMessage(
      String messageUid, String userUid, int timesent, bool isDeleteForMe) {
    try {
      _deleteMessage.call(messageUid, userUid, timesent, isDeleteForMe);
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  void reactMessage(
      String reaction, String messageUid, String userUid, bool isReplyMessage) {
    try {
      _reactMessage.call(reaction, messageUid, userUid, isReplyMessage);
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  void unreadMessage(String recieverUserId) {
    _unreadMessage.call(recieverUserId);
  }

  void activeTyping(String uidUser, bool status) {
    print('activeTyping');
    _typingIndicator.call(uidUser, status);
  }

  Stream getStatusTyping(String uidUser) {
    return _statusTypingIndicator.call(uidUser);
  }

  Stream<List<UserModel>> getStatusOnline(String uidUser) {
    return _statusOnline.call(uidUser);
  }

  Future<void> bloquerConversation(String userUid) async {
    _bloqueConversation.call(userUid).then((onValue) {
      showCustomSnackBar("Vous_bloqué_utilisateur.");
    });
  }

  Future<void> debloquerConversation(String userUid) async {
    _debloqueConversation.call(userUid).then((onValue) {
      showCustomSnackBar("Vous_débloqué_utilisateur.");
    });
  }

  Stream<bool> getStatusBlock(String uidUser) {
    return _statusBloqueConversation.call(uidUser);
  }

  Stream<bool> getStatusBlockOnChat(String uidUser) {
    return _statusBloqueConversationOnChat.call(uidUser);
  }

  Future<void> desapearMessageInList(String uidUser) {
    return _desappearMessageInlist.call(uidUser);
  }
}
