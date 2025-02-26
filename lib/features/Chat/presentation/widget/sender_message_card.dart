import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/presentation/widget/display_reply_message.dart';
import 'package:natify/features/Chat/presentation/widget/display_text_image_gif.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    required this.onRightSwipe,
    required this.repliedText,
    required this.username,
    required this.repliedMessageType,
    required this.messageId,
    required this.reactMessageSingle,
    required this.reactMessageReply,
    required this.colorSender,
    required this.colorMe,
  });
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback onRightSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;
  final String messageId;
  final List<Map<String, String>> reactMessageSingle;
  final List<Map<String, String>> reactMessageReply;
  final String colorSender;
  final String colorMe;

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;

    return SwipeTo(
        swipeSensitivity: 15,
        onRightSwipe: (swipe) {
          onRightSwipe();
        },
        child: Align(
            alignment: Alignment.centerLeft,
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
                                color: Color(int.parse("0xFF$colorSender"))),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 7,
                                right: 7,
                                top: 5,
                                bottom: 7,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  DisplayTextImageGIF(
                                      colorMe: colorMe,
                                      colorSender: colorSender,
                                      key: ValueKey(messageId),
                                      message: message,
                                      type: type,
                                      check: 'sender'),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      date,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      if (reactMessageSingle.isNotEmpty)
                        Positioned(
                            bottom: 0,
                            right: 2,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Color(int.parse("0xFF$colorSender")),
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
                                          .map((reaction) =>
                                              reaction['reaction'])
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: Color(int.parse("0xFF$colorMe"))),
                                child: DisplayReplyMessage(
                                    key: ValueKey(messageId),
                                    message: repliedText,
                                    type: repliedMessageType,
                                    check: 'sender'),
                              ),
                              // Le message envoyé (partiellement superposé)
                              Transform.translate(
                                offset: Offset(0,
                                    -10), // Superposer légèrement le message en réponse
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 7, right: 7, bottom: 7),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15)),
                                    // gradient: chatBubbleGradient,
                                    color: Color(int.parse("0xFF$colorSender")),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      DisplayTextImageGIF(
                                          colorMe: colorMe,
                                          colorSender: colorSender,
                                          key: ValueKey(messageId),
                                          message: message,
                                          type: type,
                                          check: 'sender'),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          date,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black,
                                          ),
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
                            bottom: 14,
                            left: 8,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Color(int.parse("0xFF$colorSender")),
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
                                          .map((reaction) =>
                                              reaction['reaction'])
                                          .join(", "),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                )))
                    ],
                  )));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double factor = 25.0;
    path.lineTo(0, size.height);
    path.lineTo(factor, size.height - factor);
    path.lineTo(size.width - factor, size.height - factor);
    path.quadraticBezierTo(size.width, size.height - factor, size.width,
        size.height - (factor * 2));
    path.lineTo(size.width, factor);
    path.quadraticBezierTo(size.width, 0, size.width - factor, 0);
    path.lineTo(factor, 0);
    path.quadraticBezierTo(0, 0, 0, factor);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}
