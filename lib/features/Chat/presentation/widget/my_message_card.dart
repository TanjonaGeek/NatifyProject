import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/presentation/widget/display_reply_message.dart';
import 'package:natify/features/Chat/presentation/widget/display_text_image_gif.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback onLeftSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;
  final bool isSeen;
  final String messageId;
  final List<Map<String, String>> reactMessageSingle;
  final List<Map<String, String>> reactMessageReply;
  final String colorSender;
  final String colorMe;

  const MyMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    required this.onLeftSwipe,
    required this.repliedText,
    required this.username,
    required this.repliedMessageType,
    required this.isSeen,
    required this.messageId,
    required this.reactMessageSingle,
    required this.reactMessageReply,
    required this.colorSender,
    required this.colorMe,
  });

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;

    return SwipeTo(
      swipeSensitivity: 15,
      onLeftSwipe: (swipe) {
        onLeftSwipe();
      },
      child: Align(
          alignment: Alignment.centerRight,
          child: !isReplying
              ? Stack(
                  children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 130,
                            minWidth: 100),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15)),
                              // gradient: chatBubbleGradient,
                              color: Color(int.parse("0xFF$colorMe"))),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                              right: 7,
                              top: 3,
                              bottom: 5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                DisplayTextImageGIF(
                                    colorMe: colorMe,
                                    colorSender: colorSender,
                                    key: ValueKey(messageId),
                                    message: message,
                                    type: type,
                                    check: 'me'),
                                SizedBox(
                                  height: 2,
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        date,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        isSeen ? Icons.done_all : Icons.done,
                                        size: 15,
                                        color: isSeen
                                            ? kPrimaryColor
                                            : Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                    if (reactMessageSingle.isNotEmpty)
                      Positioned(
                          bottom: 1,
                          left: 1,
                          child: Container(
                              decoration: BoxDecoration(
                                color: Color(int.parse("0xFF$colorMe")),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 4, right: 4, top: 2, bottom: 2),
                                child: Center(
                                  child: Text(
                                    // Parcourir les réactions et afficher sous forme de texte
                                    reactMessageSingle
                                        .map((reaction) => reaction['reaction'])
                                        .join(", "),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              )))
                  ],
                )
              : Stack(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 130,
                          minWidth: 100),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                          right: 5,
                          top: 5,
                          bottom: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Le message auquel on répond
                            Container(
                              padding: EdgeInsets.only(
                                  top: 8, left: 5, right: 5, bottom: 15),
                              margin: EdgeInsets.only(
                                  right:
                                      15), // Laisser de la place pour que le message de réponse puisse couvrir
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15)),
                                  // gradient: chatBubbleGradient,
                                  color: Color(int.parse("0xFF$colorSender"))),
                              child: DisplayReplyMessage(
                                  key: ValueKey(messageId),
                                  message: repliedText,
                                  type: repliedMessageType,
                                  check: 'me'),
                            ),
                            // Le message envoyé (partiellement superposé)
                            Transform.translate(
                              offset: Offset(0,
                                  -10), // Superposer légèrement le message en réponse
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 5, left: 5, right: 7, bottom: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15)),
                                    // gradient: chatBubbleGradient,
                                    color: Color(int.parse("0xFF$colorMe"))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    DisplayTextImageGIF(
                                        colorMe: colorMe,
                                        colorSender: colorSender,
                                        key: ValueKey(messageId),
                                        message: message,
                                        type: type,
                                        check: 'me'),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            date,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            isSeen
                                                ? Icons.done_all
                                                : Icons.done,
                                            size: 15,
                                            color: isSeen
                                                ? kPrimaryColor
                                                : Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (reactMessageReply.isNotEmpty)
                      Positioned(
                          bottom: 13,
                          right: 12,
                          child: Container(
                              decoration: BoxDecoration(
                                color: Color(int.parse("0xFF$colorMe")),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 4, right: 4, top: 2, bottom: 2),
                                child: Center(
                                  child: Text(
                                    // Parcourir les réactions et afficher sous forme de texte
                                    reactMessageReply
                                        .map((reaction) => reaction['reaction'])
                                        .join(", "),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              )))
                  ],
                )),
    );
  }
}
