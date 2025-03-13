import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:natify/features/Chat/presentation/widget/my_message_card.dart';
import 'package:natify/features/Chat/presentation/widget/my_message_card_copy.dart';
import 'package:natify/features/Chat/presentation/widget/sender_message_card.dart';
import 'package:natify/features/Chat/presentation/widget/sender_message_card_copy.dart';
import 'package:natify/features/Chat/presentation/widget/typingIndicator.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_reactions/model/menu_item.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:shimmer/shimmer.dart';

class ListMessageDetail extends ConsumerStatefulWidget {
  final String uidUser;
  final String photo;
  final String name;
  final String colorSender;
  final String colorMe;
  const ListMessageDetail(
      {required this.uidUser,
      required this.photo,
      required this.name,
      required this.colorSender,
      required this.colorMe,
      super.key});

  @override
  ConsumerState<ListMessageDetail> createState() => _ListMessageDetailState();
}

class _ListMessageDetailState extends ConsumerState<ListMessageDetail> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String uidUser = FirebaseAuth.instance.currentUser?.uid ?? "";
  final ScrollController _scrollController = ScrollController();
  List<DateTime> messageDates = [];
  double previousScrollPosition = 0; // Position précédente
  int previousMessageCount = 0; // Compte de messages précédent
  bool _userIsScrolling = false;
  bool initOpenChat = true;
  List<String> reactions = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '😠',
  ];
  List<MenuItem> menuItems = [
    MenuItem(
      label: 'Répondre'.tr,
      icon: Icons.reply,
    ),
    MenuItem(
      label: 'Copier'.tr,
      icon: Icons.copy,
    ),
    MenuItem(
      label: "Supprimer pour moi".tr,
      icon: Icons.delete_forever,
      isDestuctive: true,
    ),
    MenuItem(
      label: "Supprimer pour tout le monde".tr,
      icon: Icons.delete_forever,
      isDestuctive: true,
    ),
    MenuItem(
      label: 'Detail'.tr,
      icon: Icons.info_outline,
    ),
  ];
  List<MenuItem> menuItemsSender = [
    MenuItem(
      label: 'Répondre'.tr,
      icon: Icons.reply,
    ),
    MenuItem(
      label: 'Copier'.tr,
      icon: Icons.copy,
    ),
    MenuItem(
      label: 'Detail'.tr,
      icon: Icons.info_outline,
    ),
  ];
  void onMessageSwipe(Map<String, dynamic> messageData, bool isMe) {
    List<Map<String, dynamic>> dataMessage = [];
    dataMessage.add({
      "idMessage": messageData['messageId'],
      "checkIsMe": isMe,
      "typeMessage": messageData['type'] == 'audio'
          ? MessageEnum.audio
          : messageData['type'] == 'image'
              ? MessageEnum.image
              : messageData['type'] == 'video'
                  ? MessageEnum.video
                  : messageData['type'] == 'gif'
                      ? MessageEnum.gif
                      : MessageEnum.text,
      "message": messageData['text'],
      "nameSender": widget.name
    });
    if (mounted) {
      ref
          .read(chatStateNotifier(widget.uidUser).notifier)
          .getReplyMessage(dataMessage);
    }
  }

  bool _shouldShowDateSeparator(int index, DateTime currentDate) {
    if (index == 0) {
      return true;
    }

    final previousDate = messageDates[index - 1];
    return !_isSameDay(currentDate, previousDate);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  _showMoreOption4(bool isMe, String name, String date) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Colors.transparent,
      builder: (context) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.7, // Limite à 80% de la hauteur de l'écran
          ),
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 5,
                right: 5),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                      child: Text(
                        "plus_d_options".tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 0.7,
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 1, top: 1),
                      child: ListTile(
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.grey.shade300,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/utilisateur (1).png',
                                width: 17,
                                height: 17,
                              ),
                            )),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expediteur".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isMe ? "Vous".tr : name,
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 1, top: 1),
                      child: ListTile(
                        onTap: () {},
                        leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.grey.shade300,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/calendrier (1).png',
                                width: 30,
                                height: 30,
                              ),
                            )),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              date.tr,
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),
          )),
    );
  }

  void unReadMessage() {
    if (mounted) {
      ref
          .read(chatStateNotifier(widget.uidUser).notifier)
          .unreadMessage(widget.uidUser);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // unReadMessage();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            _userIsScrolling = true;
          } else if (notification is ScrollEndNotification) {
            _userIsScrolling = false;
          }
          return true;
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uidUser)
              .collection('chats')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('messages')
              .where('isSeen',
                  isEqualTo: false) // Écoute seulement les messages non lus
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return FirestorePagination(
                  controller: _scrollController,
                  limit: 15, // Defaults to 10.
                  viewType: ViewType.list,
                  isLive: true,
                  reverse: true,
                  bottomLoader: SizedBox(),
                  initialLoader: SizedBox(),
                  query: firestore
                      .collection('users')
                      .doc(uidUser)
                      .collection('chats')
                      .doc(widget.uidUser)
                      .collection('messages')
                      .orderBy('timeSent', descending: true),
                  itemBuilder: (context, documentSnapshot, index) {
                    final data =
                        documentSnapshot.data() as Map<String, dynamic>?;
                    if (data == null) return Container();
                    final messageData = data;
                    DateTime datetimes = DateTime.fromMillisecondsSinceEpoch(
                        messageData['timeSent']);
                    var timeSent = DateFormat.Hm().format(datetimes);
                    String a = "à".tr;
                    var dateSentq = DateFormat.yMMMd().format(datetimes);
                    String dateSent = "$dateSentq $a $timeSent";
                    // Ajouter la date du message actuel à la liste
                    if (!messageDates.contains(datetimes)) {
                      messageDates.add(datetimes);
                    }
                    // Utilisation de SchedulerBinding pour s'assurer que la liste est bien affichée
                    if (initOpenChat == true) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (!_userIsScrolling) {
                          _scrollToBottom(); // Forcer le défilement
                        }
                      });
                    } else {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (!_userIsScrolling) {
                          _scrollToBottomNotInit(); // Forcer le défilement
                        }
                      });
                    }
                    if (messageData['senderId'] == uidUser) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (messageData['reactMessageReply'].isNotEmpty ||
                                  messageData['reactMessageSingle']
                                      .isNotEmpty) {
                                showReactionMessage(
                                    widget.photo,
                                    widget.uidUser,
                                    widget.name,
                                    messageData['reactMessageReply']
                                        as List<dynamic>,
                                    messageData['reactMessageSingle']
                                        as List<dynamic>);
                              }
                            },
                            onLongPress: () {
                              if (!(messageData['text'] ==
                                      "messageretirerforme" ||
                                  messageData['text'] ==
                                      "messageretirerforall")) {
                                // navigate with a custom [HeroDialogRoute] to [ReactionsDialogWidget]
                                Navigator.of(context).push(
                                  HeroDialogRoute(
                                    builder: (context) {
                                      return ReactionsDialogWidget(
                                          menuItemsWidth: 1,
                                          menuItems: menuItems,
                                          reactions: reactions,
                                          id: messageData[
                                              'messageId'], // unique id for message
                                          messageWidget: MyMessageCardCopy(
                                            colorMe: widget.colorMe,
                                            colorSender: widget.colorSender,
                                            messageId: messageData['messageId']
                                                    ?.toString() ??
                                                "",
                                            key: ValueKey(
                                                messageData['messageId']),
                                            message: messageData['text']
                                                    ?.toString() ??
                                                "",
                                            date: timeSent,
                                            type: messageData['type'] == 'audio'
                                                ? MessageEnum.audio
                                                : messageData['type'] == 'image'
                                                    ? MessageEnum.image
                                                    : messageData['type'] ==
                                                            'video'
                                                        ? MessageEnum.video
                                                        : messageData['type'] ==
                                                                'gif'
                                                            ? MessageEnum.gif
                                                            : MessageEnum.text,
                                            repliedText:
                                                messageData['repliedMessage']
                                                        ?.toString() ??
                                                    "",
                                            username: messageData['repliedTo']
                                                    ?.toString() ??
                                                "",
                                            repliedMessageType: messageData[
                                                        'repliedMessageType'] ==
                                                    'audio'
                                                ? MessageEnum.audio
                                                : messageData[
                                                            'repliedMessageType'] ==
                                                        'image'
                                                    ? MessageEnum.image
                                                    : messageData[
                                                                'repliedMessageType'] ==
                                                            'video'
                                                        ? MessageEnum.video
                                                        : messageData[
                                                                    'repliedMessageType'] ==
                                                                'gif'
                                                            ? MessageEnum.gif
                                                            : MessageEnum.text,
                                            onLeftSwipe: () => onMessageSwipe(
                                              messageData,
                                              true,
                                            ),
                                            isSeen: messageData['isSeen'],
                                          ), // message widget
                                          onReactionTap: (reaction) async {
                                            final List<ConnectivityResult>
                                                connectivityResult =
                                                await (Connectivity()
                                                    .checkConnectivity());
                                            bool isMessageReply =
                                                messageData['repliedMessage'] ==
                                                        ""
                                                    ? false
                                                    : true;
                                            if (reaction == '➕') {
                                              // show emoji picker container
                                            } else {
                                              if (connectivityResult.contains(
                                                  ConnectivityResult.none)) {
                                                showCustomSnackBar(
                                                    "Pas de connexion internet");
                                                return;
                                              }
                                              if (mounted) {
                                                ref
                                                    .read(chatStateNotifier(
                                                            widget.uidUser)
                                                        .notifier)
                                                    .reactMessage(
                                                        reaction,
                                                        messageData[
                                                            'messageId'],
                                                        widget.uidUser,
                                                        isMessageReply);
                                              }
                                            }
                                          },
                                          onContextMenuTap: (menuItem) async {
                                            final List<ConnectivityResult>
                                                connectivityResult =
                                                await (Connectivity()
                                                    .checkConnectivity());
                                            int selectedIndex =
                                                menuItems.indexOf(menuItem);
                                            if (selectedIndex != -1) {
                                              if (selectedIndex == 0) {
                                                List<Map<String, dynamic>>
                                                    dataMessage = [];
                                                bool isMe =
                                                    (messageData['senderId'] ==
                                                            uidUser)
                                                        ? true
                                                        : false;
                                                dataMessage.add({
                                                  "idMessage":
                                                      messageData['messageId'],
                                                  "checkIsMe": isMe,
                                                  "typeMessage": messageData[
                                                              'type'] ==
                                                          'audio'
                                                      ? MessageEnum.audio
                                                      : messageData['type'] ==
                                                              'image'
                                                          ? MessageEnum.image
                                                          : messageData[
                                                                      'type'] ==
                                                                  'video'
                                                              ? MessageEnum
                                                                  .video
                                                              : messageData[
                                                                          'type'] ==
                                                                      'gif'
                                                                  ? MessageEnum
                                                                      .gif
                                                                  : MessageEnum
                                                                      .text,
                                                  "message":
                                                      messageData['text'],
                                                  "nameSender": widget.name
                                                });
                                                if (mounted) {
                                                  ref
                                                      .read(chatStateNotifier(
                                                              widget.uidUser)
                                                          .notifier)
                                                      .getReplyMessage(
                                                          dataMessage);
                                                }
                                              } else if (selectedIndex == 1) {
                                                await Clipboard.setData(
                                                    ClipboardData(
                                                        text: messageData[
                                                                    'text']
                                                                ?.toString() ??
                                                            ""));
                                              } else if (selectedIndex == 2) {
                                                if (connectivityResult.contains(
                                                    ConnectivityResult.none)) {
                                                  showCustomSnackBar(
                                                      "Pas de connexion internet");
                                                  return;
                                                }
                                                if (mounted) {
                                                  int timesent =
                                                      messageData['timeSent'];
                                                  ref
                                                      .read(chatStateNotifier(
                                                              widget.uidUser)
                                                          .notifier)
                                                      .deleteMessage(
                                                          messageData[
                                                              'messageId'],
                                                          widget.uidUser,
                                                          timesent,
                                                          true);
                                                }
                                              } else if (selectedIndex == 3) {
                                                if (connectivityResult.contains(
                                                    ConnectivityResult.none)) {
                                                  showCustomSnackBar(
                                                      "Pas de connexion internet");
                                                  return;
                                                }
                                                if (mounted) {
                                                  int timesent =
                                                      messageData['timeSent'];
                                                  ref
                                                      .read(chatStateNotifier(
                                                              widget.uidUser)
                                                          .notifier)
                                                      .deleteMessage(
                                                          messageData[
                                                              'messageId'],
                                                          widget.uidUser,
                                                          timesent,
                                                          false);
                                                }
                                              } else if (selectedIndex == 4) {
                                                bool isMe =
                                                    (messageData['senderId'] ==
                                                            uidUser)
                                                        ? true
                                                        : false;
                                                _showMoreOption4(isMe,
                                                    widget.name, dateSent);
                                              }
                                              // Gérer l'élément du menu selon l'index
                                            } else {
                                              print("Menu item not found");
                                            }
                                            // handle context menu item
                                          },
                                          widgetAlignment:
                                              Alignment.centerLeft);
                                    },
                                  ),
                                );
                              }
                            },
                            child: messageData['text'] == "messageretirerforme"
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(right: 7, top: 3),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                          height: 40,
                                          width: 120,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15)),
                                              color: newColorBlueElevate),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Center(
                                                child: Text(
                                              'Ce message a été retiré.'.tr,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white54,
                                                  fontStyle: FontStyle.italic),
                                            )),
                                          )),
                                    ),
                                  )
                                : messageData['text'] == "messageretirerforall"
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            right: 7, top: 3),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                              height: 40,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(15),
                                                          topRight:
                                                              Radius.circular(
                                                                  15),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  15)),
                                                  color: newColorBlueElevate),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Center(
                                                    child: Text(
                                                  'Ce message a été retiré.'.tr,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white54,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                )),
                                              )),
                                        ),
                                      )
                                    : MyMessageCard(
                                        colorMe: widget.colorMe,
                                        colorSender: widget.colorSender,
                                        reactMessageReply: (messageData[
                                                        'reactMessageReply']
                                                    as List<dynamic>?)
                                                ?.map((e) =>
                                                    Map<String, String>.from(e))
                                                .toList() ??
                                            [],
                                        reactMessageSingle: (messageData[
                                                        'reactMessageSingle']
                                                    as List<dynamic>?)
                                                ?.map((e) =>
                                                    Map<String, String>.from(e))
                                                .toList() ??
                                            [],
                                        messageId: messageData['messageId']
                                                ?.toString() ??
                                            "",
                                        key: ValueKey(messageData['messageId']),
                                        message:
                                            messageData['text']?.toString() ??
                                                "",
                                        date: timeSent,
                                        type: messageData['type'] == 'audio'
                                            ? MessageEnum.audio
                                            : messageData['type'] == 'image'
                                                ? MessageEnum.image
                                                : messageData['type'] == 'video'
                                                    ? MessageEnum.video
                                                    : messageData['type'] ==
                                                            'gif'
                                                        ? MessageEnum.gif
                                                        : MessageEnum.text,
                                        repliedText:
                                            messageData['repliedMessage']
                                                    ?.toString() ??
                                                "",
                                        username: messageData['repliedTo']
                                                ?.toString() ??
                                            "",
                                        repliedMessageType: messageData[
                                                    'repliedMessageType'] ==
                                                'audio'
                                            ? MessageEnum.audio
                                            : messageData[
                                                        'repliedMessageType'] ==
                                                    'image'
                                                ? MessageEnum.image
                                                : messageData[
                                                            'repliedMessageType'] ==
                                                        'video'
                                                    ? MessageEnum.video
                                                    : messageData[
                                                                'repliedMessageType'] ==
                                                            'gif'
                                                        ? MessageEnum.gif
                                                        : MessageEnum.text,
                                        onLeftSwipe: () => onMessageSwipe(
                                          messageData,
                                          true,
                                        ),
                                        isSeen: messageData['isSeen'],
                                      ),
                          ),
                          (index == 0)
                              ? StreamBuilder(
                                  stream: ref
                                      .read(chatStateNotifier(widget.uidUser)
                                          .notifier)
                                      .getStatusTyping(widget.uidUser),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox();
                                    }
                                    return snapshot.data == null
                                        ? SizedBox()
                                        : Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 12),
                                              child: TypingIndicator(
                                                showIndicator: snapshot.data!,
                                                photo: widget.photo,
                                              ),
                                            ),
                                          );
                                  })
                              : SizedBox()
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (messageData['reactMessageReply'].isNotEmpty ||
                                  messageData['reactMessageSingle']
                                      .isNotEmpty) {
                                showReactionMessage(
                                    widget.photo,
                                    widget.uidUser,
                                    widget.name,
                                    messageData['reactMessageReply']
                                        as List<dynamic>,
                                    messageData['reactMessageSingle']
                                        as List<dynamic>);
                              }
                            },
                            onLongPress: () {
                              // _showMoreOption(messageData,index,totalMessage,false);
                              if (!(messageData['text'] ==
                                      "messageretirerforme" ||
                                  messageData['text'] ==
                                      "messageretirerforall")) {
                                // navigate with a custom [HeroDialogRoute] to [ReactionsDialogWidget]
                                Navigator.of(context).push(
                                  HeroDialogRoute(
                                    builder: (context) {
                                      return ReactionsDialogWidget(
                                        menuItemsWidth: 1,
                                        menuItems: menuItemsSender,
                                        reactions: reactions,
                                        id: messageData[
                                            'messageId'], // unique id for message
                                        messageWidget: SenderMessageCardCopy(
                                          colorMe: widget.colorMe,
                                          colorSender: widget.colorSender,
                                          messageId: messageData['messageId']
                                                  ?.toString() ??
                                              "",
                                          key: ValueKey(
                                              messageData['messageId']),
                                          message:
                                              messageData['text']?.toString() ??
                                                  "",
                                          date: timeSent,
                                          type: messageData['type'] == 'audio'
                                              ? MessageEnum.audio
                                              : messageData['type'] == 'image'
                                                  ? MessageEnum.image
                                                  : messageData['type'] ==
                                                          'video'
                                                      ? MessageEnum.video
                                                      : messageData['type'] ==
                                                              'gif'
                                                          ? MessageEnum.gif
                                                          : MessageEnum.text,
                                          username: messageData['repliedTo']
                                                  ?.toString() ??
                                              "",
                                          repliedMessageType: messageData[
                                                      'repliedMessageType'] ==
                                                  'audio'
                                              ? MessageEnum.audio
                                              : messageData[
                                                          'repliedMessageType'] ==
                                                      'image'
                                                  ? MessageEnum.image
                                                  : messageData[
                                                              'repliedMessageType'] ==
                                                          'video'
                                                      ? MessageEnum.video
                                                      : messageData[
                                                                  'repliedMessageType'] ==
                                                              'gif'
                                                          ? MessageEnum.gif
                                                          : MessageEnum.text,
                                          onRightSwipe: () => onMessageSwipe(
                                            messageData,
                                            false,
                                          ),
                                          repliedText:
                                              messageData['repliedMessage']
                                                      ?.toString() ??
                                                  "",
                                        ), // message widget
                                        onReactionTap: (reaction) async {
                                          final List<ConnectivityResult>
                                              connectivityResult =
                                              await (Connectivity()
                                                  .checkConnectivity());
                                          bool isMessageReply =
                                              messageData['repliedMessage'] ==
                                                      ""
                                                  ? false
                                                  : true;
                                          if (reaction == '➕') {
                                            // show emoji picker container
                                          } else {
                                            if (connectivityResult.contains(
                                                ConnectivityResult.none)) {
                                              showCustomSnackBar(
                                                  "Pas de connexion internet");
                                              return;
                                            }
                                            if (mounted) {
                                              ref
                                                  .read(chatStateNotifier(
                                                          widget.uidUser)
                                                      .notifier)
                                                  .reactMessage(
                                                      reaction,
                                                      messageData['messageId'],
                                                      widget.uidUser,
                                                      isMessageReply);
                                            }
                                          }
                                        },
                                        onContextMenuTap: (menuItem) async {
                                          final List<ConnectivityResult>
                                              connectivityResult =
                                              await (Connectivity()
                                                  .checkConnectivity());
                                          int selectedIndex =
                                              menuItemsSender.indexOf(menuItem);
                                          if (selectedIndex != -1) {
                                            if (selectedIndex == 0) {
                                              List<Map<String, dynamic>>
                                                  dataMessage = [];
                                              bool isMe =
                                                  (messageData['senderId'] ==
                                                          uidUser)
                                                      ? true
                                                      : false;
                                              dataMessage.add({
                                                "idMessage":
                                                    messageData['messageId']
                                                            ?.toString() ??
                                                        "",
                                                "checkIsMe": isMe,
                                                "typeMessage": messageData[
                                                            'type'] ==
                                                        'audio'
                                                    ? MessageEnum.audio
                                                    : messageData['type'] ==
                                                            'image'
                                                        ? MessageEnum.image
                                                        : messageData['type'] ==
                                                                'video'
                                                            ? MessageEnum.video
                                                            : messageData[
                                                                        'type'] ==
                                                                    'gif'
                                                                ? MessageEnum
                                                                    .gif
                                                                : MessageEnum
                                                                    .text,
                                                "message": messageData['text'],
                                                "nameSender": widget.name
                                              });
                                              if (mounted) {
                                                ref
                                                    .read(chatStateNotifier(
                                                            widget.uidUser)
                                                        .notifier)
                                                    .getReplyMessage(
                                                        dataMessage);
                                              }
                                            } else if (selectedIndex == 1) {
                                              await Clipboard.setData(
                                                  ClipboardData(
                                                      text: messageData['text']
                                                              ?.toString() ??
                                                          ""));
                                            } else if (selectedIndex == 2) {
                                              bool isMe =
                                                  (messageData['senderId'] ==
                                                          uidUser)
                                                      ? true
                                                      : false;
                                              _showMoreOption4(
                                                  isMe, widget.name, dateSent);
                                            }
                                            // Gérer l'élément du menu selon l'index
                                          } else {
                                            print("Menu item not found");
                                          }
                                          // handle context menu item
                                        },
                                        widgetAlignment: Alignment.centerLeft,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            child: messageData['text'] == "messageretirerforme"
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                          height: 30,
                                          width: 120,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                  bottomLeft:
                                                      Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(20)),
                                              color: Colors.white),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Center(
                                                child: Text(
                                              'Ce message a été retiré.'.tr,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black26,
                                                  fontStyle: FontStyle.italic),
                                            )),
                                          )),
                                    ),
                                  )
                                : messageData['text'] == "messageretirerforall"
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                              height: 30,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20)),
                                                  color: Colors.white),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Center(
                                                    child: Text(
                                                  'Ce message a été retiré.'.tr,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.black26,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                )),
                                              )),
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: SenderMessageCard(
                                          colorMe: widget.colorMe,
                                          colorSender: widget.colorSender,
                                          reactMessageReply: (messageData[
                                                          'reactMessageReply']
                                                      as List<dynamic>?)
                                                  ?.map((e) =>
                                                      Map<String, String>.from(
                                                          e))
                                                  .toList() ??
                                              [],
                                          reactMessageSingle: (messageData[
                                                          'reactMessageSingle']
                                                      as List<dynamic>?)
                                                  ?.map((e) =>
                                                      Map<String, String>.from(
                                                          e))
                                                  .toList() ??
                                              [],
                                          messageId: messageData['messageId']
                                                  ?.toString() ??
                                              "",
                                          key: ValueKey(
                                              messageData['messageId']),
                                          message:
                                              messageData['text']?.toString() ??
                                                  "",
                                          date: timeSent,
                                          type: messageData['type'] == 'audio'
                                              ? MessageEnum.audio
                                              : messageData['type'] == 'image'
                                                  ? MessageEnum.image
                                                  : messageData['type'] ==
                                                          'video'
                                                      ? MessageEnum.video
                                                      : messageData['type'] ==
                                                              'gif'
                                                          ? MessageEnum.gif
                                                          : MessageEnum.text,
                                          username: messageData['repliedTo']
                                                  ?.toString() ??
                                              "",
                                          repliedMessageType: messageData[
                                                      'repliedMessageType'] ==
                                                  'audio'
                                              ? MessageEnum.audio
                                              : messageData[
                                                          'repliedMessageType'] ==
                                                      'image'
                                                  ? MessageEnum.image
                                                  : messageData[
                                                              'repliedMessageType'] ==
                                                          'video'
                                                      ? MessageEnum.video
                                                      : messageData[
                                                                  'repliedMessageType'] ==
                                                              'gif'
                                                          ? MessageEnum.gif
                                                          : MessageEnum.text,
                                          onRightSwipe: () => onMessageSwipe(
                                            messageData,
                                            false,
                                          ),
                                          repliedText:
                                              messageData['repliedMessage']
                                                      ?.toString() ??
                                                  "",
                                        ),
                                      ),
                          ),
                          (index == 0)
                              ? StreamBuilder(
                                  stream: ref
                                      .read(chatStateNotifier(widget.uidUser)
                                          .notifier)
                                      .getStatusTyping(widget.uidUser),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox();
                                    }
                                    return snapshot.data == null
                                        ? SizedBox()
                                        : Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 12),
                                              child: TypingIndicator(
                                                showIndicator: snapshot.data!,
                                                photo: widget.photo,
                                              ),
                                            ),
                                          );
                                  })
                              : SizedBox()
                        ],
                      );
                    }
                  },
                  onEmpty: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 110,
                              height: 110,
                              child: Image.asset(
                                'assets/bulle-de-chat.png',
                                color:
                                    Color(int.parse("0xFF${widget.colorMe}")),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            "Soyez_respectueux".tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "Vos_messages_cryptés".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            }

            final messages = snapshot.data!.docs;
            // Mettre à jour tous les messages non lus
            Future.delayed(Duration.zero, () async {
              for (var doc in messages) {
                await doc.reference.update({'isSeen': true});
              }

              // Ensuite, mettre à jour les statuts de lecture
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('chats')
                  .doc(widget.uidUser)
                  .update({'statusRead': true});

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uidUser)
                  .collection('chats')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({'checkStatusReadOnOther': true});
            });
            return FirestorePagination(
                controller: _scrollController,
                limit: 15, // Defaults to 10.
                viewType: ViewType.list,
                isLive: true,
                reverse: true,
                bottomLoader: SizedBox(),
                initialLoader: SizedBox(),
                query: firestore
                    .collection('users')
                    .doc(uidUser)
                    .collection('chats')
                    .doc(widget.uidUser)
                    .collection('messages')
                    .orderBy('timeSent', descending: true),
                itemBuilder: (context, documentSnapshot, index) {
                  final data = documentSnapshot.data() as Map<String, dynamic>?;
                  if (data == null) return Container();
                  final messageData = data;
                  DateTime datetimes = DateTime.fromMillisecondsSinceEpoch(
                      messageData['timeSent']);
                  var timeSent = DateFormat.Hm().format(datetimes);
                  String a = "à".tr;
                  var dateSentq = DateFormat.yMMMd().format(datetimes);
                  String dateSent = "$dateSentq $a $timeSent";
                  // Ajouter la date du message actuel à la liste
                  if (!messageDates.contains(datetimes)) {
                    messageDates.add(datetimes);
                  }
                  // Utilisation de SchedulerBinding pour s'assurer que la liste est bien affichée
                  if (initOpenChat == true) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (!_userIsScrolling) {
                        _scrollToBottom(); // Forcer le défilement
                      }
                    });
                  } else {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (!_userIsScrolling) {
                        _scrollToBottomNotInit(); // Forcer le défilement
                      }
                    });
                  }
                  if (messageData['senderId'] == uidUser) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            if (messageData['reactMessageReply'].isNotEmpty ||
                                messageData['reactMessageSingle'].isNotEmpty) {
                              showReactionMessage(
                                  widget.photo,
                                  widget.uidUser,
                                  widget.name,
                                  messageData['reactMessageReply']
                                      as List<dynamic>,
                                  messageData['reactMessageSingle']
                                      as List<dynamic>);
                            }
                          },
                          onLongPress: () {
                            if (!(messageData['text'] ==
                                    "messageretirerforme" ||
                                messageData['text'] ==
                                    "messageretirerforall")) {
                              // navigate with a custom [HeroDialogRoute] to [ReactionsDialogWidget]
                              Navigator.of(context).push(
                                HeroDialogRoute(
                                  builder: (context) {
                                    return ReactionsDialogWidget(
                                        menuItemsWidth: 1,
                                        menuItems: menuItems,
                                        reactions: reactions,
                                        id: messageData[
                                            'messageId'], // unique id for message
                                        messageWidget: MyMessageCardCopy(
                                          colorMe: widget.colorMe,
                                          colorSender: widget.colorSender,
                                          messageId: messageData['messageId']
                                                  ?.toString() ??
                                              "",
                                          key: ValueKey(
                                              messageData['messageId']),
                                          message:
                                              messageData['text']?.toString() ??
                                                  "",
                                          date: timeSent,
                                          type: messageData['type'] == 'audio'
                                              ? MessageEnum.audio
                                              : messageData['type'] == 'image'
                                                  ? MessageEnum.image
                                                  : messageData['type'] ==
                                                          'video'
                                                      ? MessageEnum.video
                                                      : messageData['type'] ==
                                                              'gif'
                                                          ? MessageEnum.gif
                                                          : MessageEnum.text,
                                          repliedText:
                                              messageData['repliedMessage']
                                                      ?.toString() ??
                                                  "",
                                          username: messageData['repliedTo']
                                                  ?.toString() ??
                                              "",
                                          repliedMessageType: messageData[
                                                      'repliedMessageType'] ==
                                                  'audio'
                                              ? MessageEnum.audio
                                              : messageData[
                                                          'repliedMessageType'] ==
                                                      'image'
                                                  ? MessageEnum.image
                                                  : messageData[
                                                              'repliedMessageType'] ==
                                                          'video'
                                                      ? MessageEnum.video
                                                      : messageData[
                                                                  'repliedMessageType'] ==
                                                              'gif'
                                                          ? MessageEnum.gif
                                                          : MessageEnum.text,
                                          onLeftSwipe: () => onMessageSwipe(
                                            messageData,
                                            true,
                                          ),
                                          isSeen: messageData['isSeen'],
                                        ), // message widget
                                        onReactionTap: (reaction) async {
                                          final List<ConnectivityResult>
                                              connectivityResult =
                                              await (Connectivity()
                                                  .checkConnectivity());
                                          bool isMessageReply =
                                              messageData['repliedMessage'] ==
                                                      ""
                                                  ? false
                                                  : true;
                                          if (reaction == '➕') {
                                            // show emoji picker container
                                          } else {
                                            if (connectivityResult.contains(
                                                ConnectivityResult.none)) {
                                              showCustomSnackBar(
                                                  "Pas de connexion internet");
                                              return;
                                            }
                                            if (mounted) {
                                              ref
                                                  .read(chatStateNotifier(
                                                          widget.uidUser)
                                                      .notifier)
                                                  .reactMessage(
                                                      reaction,
                                                      messageData['messageId'],
                                                      widget.uidUser,
                                                      isMessageReply);
                                            }
                                          }
                                        },
                                        onContextMenuTap: (menuItem) async {
                                          final List<ConnectivityResult>
                                              connectivityResult =
                                              await (Connectivity()
                                                  .checkConnectivity());
                                          int selectedIndex =
                                              menuItems.indexOf(menuItem);
                                          if (selectedIndex != -1) {
                                            if (selectedIndex == 0) {
                                              List<Map<String, dynamic>>
                                                  dataMessage = [];
                                              bool isMe =
                                                  (messageData['senderId'] ==
                                                          uidUser)
                                                      ? true
                                                      : false;
                                              dataMessage.add({
                                                "idMessage":
                                                    messageData['messageId'],
                                                "checkIsMe": isMe,
                                                "typeMessage": messageData[
                                                            'type'] ==
                                                        'audio'
                                                    ? MessageEnum.audio
                                                    : messageData['type'] ==
                                                            'image'
                                                        ? MessageEnum.image
                                                        : messageData['type'] ==
                                                                'video'
                                                            ? MessageEnum.video
                                                            : messageData[
                                                                        'type'] ==
                                                                    'gif'
                                                                ? MessageEnum
                                                                    .gif
                                                                : MessageEnum
                                                                    .text,
                                                "message": messageData['text'],
                                                "nameSender": widget.name
                                              });
                                              if (mounted) {
                                                ref
                                                    .read(chatStateNotifier(
                                                            widget.uidUser)
                                                        .notifier)
                                                    .getReplyMessage(
                                                        dataMessage);
                                              }
                                            } else if (selectedIndex == 1) {
                                              await Clipboard.setData(
                                                  ClipboardData(
                                                      text: messageData['text']
                                                              ?.toString() ??
                                                          ""));
                                            } else if (selectedIndex == 2) {
                                              if (connectivityResult.contains(
                                                  ConnectivityResult.none)) {
                                                showCustomSnackBar(
                                                    "Pas de connexion internet");
                                                return;
                                              }
                                              if (mounted) {
                                                int timesent =
                                                    messageData['timeSent'];
                                                ref
                                                    .read(chatStateNotifier(
                                                            widget.uidUser)
                                                        .notifier)
                                                    .deleteMessage(
                                                        messageData[
                                                            'messageId'],
                                                        widget.uidUser,
                                                        timesent,
                                                        true);
                                              }
                                            } else if (selectedIndex == 3) {
                                              if (connectivityResult.contains(
                                                  ConnectivityResult.none)) {
                                                showCustomSnackBar(
                                                    "Pas de connexion internet");
                                                return;
                                              }
                                              if (mounted) {
                                                int timesent =
                                                    messageData['timeSent'];
                                                ref
                                                    .read(chatStateNotifier(
                                                            widget.uidUser)
                                                        .notifier)
                                                    .deleteMessage(
                                                        messageData[
                                                            'messageId'],
                                                        widget.uidUser,
                                                        timesent,
                                                        false);
                                              }
                                            } else if (selectedIndex == 4) {
                                              bool isMe =
                                                  (messageData['senderId'] ==
                                                          uidUser)
                                                      ? true
                                                      : false;
                                              _showMoreOption4(
                                                  isMe, widget.name, dateSent);
                                            }
                                            // Gérer l'élément du menu selon l'index
                                          } else {
                                            print("Menu item not found");
                                          }
                                          // handle context menu item
                                        },
                                        widgetAlignment: Alignment.centerLeft);
                                  },
                                ),
                              );
                            }
                          },
                          child: messageData['text'] == "messageretirerforme"
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(right: 7, top: 3),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                        height: 40,
                                        width: 120,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                                bottomLeft: Radius.circular(15),
                                                bottomRight:
                                                    Radius.circular(15)),
                                            color: newColorBlueElevate),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Center(
                                              child: Text(
                                            'Ce message a été retiré.'.tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontStyle: FontStyle.italic),
                                          )),
                                        )),
                                  ),
                                )
                              : messageData['text'] == "messageretirerforall"
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          right: 7, top: 3),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                            height: 40,
                                            width: 120,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15)),
                                                color: newColorBlueElevate),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Center(
                                                  child: Text(
                                                'Ce message a été retiré.'.tr,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white54,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              )),
                                            )),
                                      ),
                                    )
                                  : MyMessageCard(
                                      colorMe: widget.colorMe,
                                      colorSender: widget.colorSender,
                                      reactMessageReply: (messageData[
                                                      'reactMessageReply']
                                                  as List<dynamic>?)
                                              ?.map((e) =>
                                                  Map<String, String>.from(e))
                                              .toList() ??
                                          [],
                                      reactMessageSingle: (messageData[
                                                      'reactMessageSingle']
                                                  as List<dynamic>?)
                                              ?.map((e) =>
                                                  Map<String, String>.from(e))
                                              .toList() ??
                                          [],
                                      messageId: messageData['messageId']
                                              ?.toString() ??
                                          "",
                                      key: ValueKey(messageData['messageId']),
                                      message:
                                          messageData['text']?.toString() ?? "",
                                      date: timeSent,
                                      type: messageData['type'] == 'audio'
                                          ? MessageEnum.audio
                                          : messageData['type'] == 'image'
                                              ? MessageEnum.image
                                              : messageData['type'] == 'video'
                                                  ? MessageEnum.video
                                                  : messageData['type'] == 'gif'
                                                      ? MessageEnum.gif
                                                      : MessageEnum.text,
                                      repliedText: messageData['repliedMessage']
                                              ?.toString() ??
                                          "",
                                      username: messageData['repliedTo']
                                              ?.toString() ??
                                          "",
                                      repliedMessageType: messageData[
                                                  'repliedMessageType'] ==
                                              'audio'
                                          ? MessageEnum.audio
                                          : messageData['repliedMessageType'] ==
                                                  'image'
                                              ? MessageEnum.image
                                              : messageData[
                                                          'repliedMessageType'] ==
                                                      'video'
                                                  ? MessageEnum.video
                                                  : messageData[
                                                              'repliedMessageType'] ==
                                                          'gif'
                                                      ? MessageEnum.gif
                                                      : MessageEnum.text,
                                      onLeftSwipe: () => onMessageSwipe(
                                        messageData,
                                        true,
                                      ),
                                      isSeen: messageData['isSeen'],
                                    ),
                        ),
                        (index == 0)
                            ? StreamBuilder(
                                stream: ref
                                    .read(chatStateNotifier(widget.uidUser)
                                        .notifier)
                                    .getStatusTyping(widget.uidUser),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox();
                                  }
                                  return snapshot.data == null
                                      ? SizedBox()
                                      : Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 12),
                                            child: TypingIndicator(
                                              showIndicator: snapshot.data!,
                                              photo: widget.photo,
                                            ),
                                          ),
                                        );
                                })
                            : SizedBox()
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            if (messageData['reactMessageReply'].isNotEmpty ||
                                messageData['reactMessageSingle'].isNotEmpty) {
                              showReactionMessage(
                                  widget.photo,
                                  widget.uidUser,
                                  widget.name,
                                  messageData['reactMessageReply']
                                      as List<dynamic>,
                                  messageData['reactMessageSingle']
                                      as List<dynamic>);
                            }
                          },
                          onLongPress: () {
                            // _showMoreOption(messageData,index,totalMessage,false);
                            if (!(messageData['text'] ==
                                    "messageretirerforme" ||
                                messageData['text'] ==
                                    "messageretirerforall")) {
                              // navigate with a custom [HeroDialogRoute] to [ReactionsDialogWidget]
                              Navigator.of(context).push(
                                HeroDialogRoute(
                                  builder: (context) {
                                    return ReactionsDialogWidget(
                                      menuItemsWidth: 1,
                                      menuItems: menuItemsSender,
                                      reactions: reactions,
                                      id: messageData[
                                          'messageId'], // unique id for message
                                      messageWidget: SenderMessageCardCopy(
                                        colorMe: widget.colorMe,
                                        colorSender: widget.colorSender,
                                        messageId: messageData['messageId']
                                                ?.toString() ??
                                            "",
                                        key: ValueKey(messageData['messageId']),
                                        message:
                                            messageData['text']?.toString() ??
                                                "",
                                        date: timeSent,
                                        type: messageData['type'] == 'audio'
                                            ? MessageEnum.audio
                                            : messageData['type'] == 'image'
                                                ? MessageEnum.image
                                                : messageData['type'] == 'video'
                                                    ? MessageEnum.video
                                                    : messageData['type'] ==
                                                            'gif'
                                                        ? MessageEnum.gif
                                                        : MessageEnum.text,
                                        username: messageData['repliedTo']
                                                ?.toString() ??
                                            "",
                                        repliedMessageType: messageData[
                                                    'repliedMessageType'] ==
                                                'audio'
                                            ? MessageEnum.audio
                                            : messageData[
                                                        'repliedMessageType'] ==
                                                    'image'
                                                ? MessageEnum.image
                                                : messageData[
                                                            'repliedMessageType'] ==
                                                        'video'
                                                    ? MessageEnum.video
                                                    : messageData[
                                                                'repliedMessageType'] ==
                                                            'gif'
                                                        ? MessageEnum.gif
                                                        : MessageEnum.text,
                                        onRightSwipe: () => onMessageSwipe(
                                          messageData,
                                          false,
                                        ),
                                        repliedText:
                                            messageData['repliedMessage']
                                                    ?.toString() ??
                                                "",
                                      ), // message widget
                                      onReactionTap: (reaction) async {
                                        final List<ConnectivityResult>
                                            connectivityResult =
                                            await (Connectivity()
                                                .checkConnectivity());
                                        bool isMessageReply =
                                            messageData['repliedMessage'] == ""
                                                ? false
                                                : true;
                                        if (reaction == '➕') {
                                          // show emoji picker container
                                        } else {
                                          if (connectivityResult.contains(
                                              ConnectivityResult.none)) {
                                            showCustomSnackBar(
                                                "Pas de connexion internet");
                                            return;
                                          }
                                          if (mounted) {
                                            ref
                                                .read(chatStateNotifier(
                                                        widget.uidUser)
                                                    .notifier)
                                                .reactMessage(
                                                    reaction,
                                                    messageData['messageId'],
                                                    widget.uidUser,
                                                    isMessageReply);
                                          }
                                        }
                                      },
                                      onContextMenuTap: (menuItem) async {
                                        final List<ConnectivityResult>
                                            connectivityResult =
                                            await (Connectivity()
                                                .checkConnectivity());
                                        int selectedIndex =
                                            menuItemsSender.indexOf(menuItem);
                                        if (selectedIndex != -1) {
                                          if (selectedIndex == 0) {
                                            List<Map<String, dynamic>>
                                                dataMessage = [];
                                            bool isMe =
                                                (messageData['senderId'] ==
                                                        uidUser)
                                                    ? true
                                                    : false;
                                            dataMessage.add({
                                              "idMessage":
                                                  messageData['messageId']
                                                          ?.toString() ??
                                                      "",
                                              "checkIsMe": isMe,
                                              "typeMessage": messageData[
                                                          'type'] ==
                                                      'audio'
                                                  ? MessageEnum.audio
                                                  : messageData['type'] ==
                                                          'image'
                                                      ? MessageEnum.image
                                                      : messageData['type'] ==
                                                              'video'
                                                          ? MessageEnum.video
                                                          : messageData[
                                                                      'type'] ==
                                                                  'gif'
                                                              ? MessageEnum.gif
                                                              : MessageEnum
                                                                  .text,
                                              "message": messageData['text'],
                                              "nameSender": widget.name
                                            });
                                            if (mounted) {
                                              ref
                                                  .read(chatStateNotifier(
                                                          widget.uidUser)
                                                      .notifier)
                                                  .getReplyMessage(dataMessage);
                                            }
                                          } else if (selectedIndex == 1) {
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: messageData['text']
                                                            ?.toString() ??
                                                        ""));
                                          } else if (selectedIndex == 2) {
                                            bool isMe =
                                                (messageData['senderId'] ==
                                                        uidUser)
                                                    ? true
                                                    : false;
                                            _showMoreOption4(
                                                isMe, widget.name, dateSent);
                                          }
                                          // Gérer l'élément du menu selon l'index
                                        } else {
                                          print("Menu item not found");
                                        }
                                        // handle context menu item
                                      },
                                      widgetAlignment: Alignment.centerLeft,
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          child: messageData['text'] == "messageretirerforme"
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                        height: 30,
                                        width: 120,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20)),
                                            color: Colors.white),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Center(
                                              child: Text(
                                            'Ce message a été retiré.'.tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black26,
                                                fontStyle: FontStyle.italic),
                                          )),
                                        )),
                                  ),
                                )
                              : messageData['text'] == "messageretirerforall"
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                            height: 30,
                                            width: 120,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                    bottomRight:
                                                        Radius.circular(20)),
                                                color: Colors.white),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Center(
                                                  child: Text(
                                                'Ce message a été retiré.'.tr,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black26,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              )),
                                            )),
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: SenderMessageCard(
                                        colorMe: widget.colorMe,
                                        colorSender: widget.colorSender,
                                        reactMessageReply: (messageData[
                                                        'reactMessageReply']
                                                    as List<dynamic>?)
                                                ?.map((e) =>
                                                    Map<String, String>.from(e))
                                                .toList() ??
                                            [],
                                        reactMessageSingle: (messageData[
                                                        'reactMessageSingle']
                                                    as List<dynamic>?)
                                                ?.map((e) =>
                                                    Map<String, String>.from(e))
                                                .toList() ??
                                            [],
                                        messageId: messageData['messageId']
                                                ?.toString() ??
                                            "",
                                        key: ValueKey(messageData['messageId']),
                                        message:
                                            messageData['text']?.toString() ??
                                                "",
                                        date: timeSent,
                                        type: messageData['type'] == 'audio'
                                            ? MessageEnum.audio
                                            : messageData['type'] == 'image'
                                                ? MessageEnum.image
                                                : messageData['type'] == 'video'
                                                    ? MessageEnum.video
                                                    : messageData['type'] ==
                                                            'gif'
                                                        ? MessageEnum.gif
                                                        : MessageEnum.text,
                                        username: messageData['repliedTo']
                                                ?.toString() ??
                                            "",
                                        repliedMessageType: messageData[
                                                    'repliedMessageType'] ==
                                                'audio'
                                            ? MessageEnum.audio
                                            : messageData[
                                                        'repliedMessageType'] ==
                                                    'image'
                                                ? MessageEnum.image
                                                : messageData[
                                                            'repliedMessageType'] ==
                                                        'video'
                                                    ? MessageEnum.video
                                                    : messageData[
                                                                'repliedMessageType'] ==
                                                            'gif'
                                                        ? MessageEnum.gif
                                                        : MessageEnum.text,
                                        onRightSwipe: () => onMessageSwipe(
                                          messageData,
                                          false,
                                        ),
                                        repliedText:
                                            messageData['repliedMessage']
                                                    ?.toString() ??
                                                "",
                                      ),
                                    ),
                        ),
                        (index == 0)
                            ? StreamBuilder(
                                stream: ref
                                    .read(chatStateNotifier(widget.uidUser)
                                        .notifier)
                                    .getStatusTyping(widget.uidUser),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox();
                                  }
                                  return snapshot.data == null
                                      ? SizedBox()
                                      : Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 12),
                                            child: TypingIndicator(
                                              showIndicator: snapshot.data!,
                                              photo: widget.photo,
                                            ),
                                          ),
                                        );
                                })
                            : SizedBox()
                      ],
                    );
                  }
                },
                onEmpty: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 130,
                            height: 130,
                            child: Image.asset('assets/speech-bubble.png',
                                color: Colors.white)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "Soyez_respectueux".tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "Vos_messages_cryptés".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          },
        ));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final minScrollExtent = _scrollController.position.minScrollExtent;
      _scrollController
          .animateTo(
        minScrollExtent, // Scroll vers le bas (minScrollExtent avec reverse = true)
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      )
          .then((_) {
        initOpenChat = false;
      }).catchError((error) {
        // Log en cas d'erreur d'animation
      });
    } else {
      print('ScrollController has no clients.');
    }
  }

  void _scrollToBottomNotInit() async {
    if (_scrollController.hasClients) {
      final currentPosition = _scrollController.offset;
      final offsetToint = currentPosition.toInt();
      final minScrollExtent = _scrollController.position.minScrollExtent;
      if (offsetToint <= 200) {
        // Si déjà en haut (offset = 0.0), ajuster pour forcer l'animation
        if (currentPosition <= 0.0 && !initOpenChat) {
          _scrollController
              .jumpTo(5.0); // Saut plus grand pour forcer l'animation
          // Toujours animer vers le bas, peu importe la position actuelle
          await Future.delayed(const Duration(milliseconds: 300));
          _scrollController
              .animateTo(
            minScrollExtent, // Scroll vers le bas (minScrollExtent avec reverse = true)
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeIn,
          )
              .then((_) {
            // Log lorsque l'animation est terminée
          }).catchError((error) {
            // Log en cas d'erreur d'animation
          });
        } else {
          // Toujours animer vers le bas, peu importe la position actuelle
          _scrollController
              .animateTo(
            minScrollExtent, // Scroll vers le bas (minScrollExtent avec reverse = true)
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          )
              .then((_) {
            // Log lorsque l'animation est terminée
          }).catchError((error) {
            // Log en cas d'erreur d'animation
          });
        }
      }
    } else {
      print('ScrollController has no clients.');
    }
  }

  Future<void> showReactionMessage(
    String photoSender,
    String uidSender,
    String nameSender,
    List<dynamic> listReactionReply,
    List<dynamic> listReactionSingle,
  ) async {
    final listToDisplay =
        listReactionReply.isNotEmpty ? listReactionReply : listReactionSingle;
    final notifier = ref.read(infoUserStateNotifier);
    return await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: Text(
                "Reactions".tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade200,
              thickness: 0.2,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: listToDisplay.length,
              itemBuilder: (context, index) {
                final reaction = listToDisplay[index] as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(left: 1, top: 1),
                  child: ListTile(
                    leading: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: reaction['uid'] == uidSender
                            ? photoSender
                            : notifier.MydataPersiste!.profilePic.toString(),
                        placeholder: (context, url) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: ClipOval(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      reaction['uid'] == uidSender
                          ? nameSender
                          : notifier.MydataPersiste!.name.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      '${reaction['reaction']}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
