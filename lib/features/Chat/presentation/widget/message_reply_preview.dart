import 'package:cached_network_image/cached_network_image.dart';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:natify/features/Chat/presentation/widget/display_text_image_gif.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessageReplyPreview extends ConsumerWidget {
  final String uid;
  final String colorSender;
  final String colorMe;
  const MessageReplyPreview({required this.uid,required this.colorSender,required this.colorMe,super.key});

  void cancelReply(WidgetRef ref) {
    ref.read(chatStateNotifier(uid).notifier).cancelReply();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(chatStateNotifier(uid));
    final String uidCurrent = FirebaseAuth.instance.currentUser?.uid ?? "";
    return Container(
      // width: 350,
      padding: const EdgeInsets.only(top: 5,left: 8,right: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                 messageReply.messageReply.first['checkIsMe'] ? 'Vous' : '${messageReply.messageReply.first['nameSender']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white
                  ),
                ),
              ),
              IconButton(
                icon: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Colors.grey.shade300,
                  ),
                  child: Center(child: FaIcon(FontAwesomeIcons.close,size:16,color:Colors.black45))),
                onPressed: () => cancelReply(ref)
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: messageReply.messageReply.first['typeMessage'] as MessageEnum == MessageEnum.audio 
            ? 
             Padding(
               padding: const EdgeInsets.only(bottom: 1),
               child: DisplayTextImageGIF(
                                colorMe: colorMe,
                                colorSender: colorSender,
                                message: messageReply.messageReply.first['message'],
                                type:  messageReply.messageReply.first['typeMessage'] as MessageEnum,
                                check : messageReply.messageReply.first['checkIsMe'] ? 'me' : "not me"
                              ),
             )
            : messageReply.messageReply.first['typeMessage'] as MessageEnum == MessageEnum.gif 
            ?
             Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(5)
                  ),
                child: 
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                           height: 90.0,
                           width: 90.0,
                          decoration: BoxDecoration(
                               shape: BoxShape.rectangle,
                               border: Border.all( color: Colors.transparent),
                               borderRadius: BorderRadius.circular(5.0),
                             ),
                             child: DisplayTextImageGIF(
                                colorMe: colorMe,
                                colorSender: colorSender,
                                message: messageReply.messageReply.first['message'],
                                type:  messageReply.messageReply.first['typeMessage'] as MessageEnum,
                                check : messageReply.messageReply.first['checkIsMe'] ? 'me' : "not me"
                              ),
                          ),
                    )
                  ),
                ) 
            :
            messageReply.messageReply.first['typeMessage'] as MessageEnum == MessageEnum.video 
            ? 
             Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(5)
                  ),
                child: 
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                           height: 90.0,
                           width: 90.0,
                          decoration: BoxDecoration(
                               shape: BoxShape.rectangle,
                               border: Border.all(color: Colors.transparent),
                               borderRadius: BorderRadius.circular(5.0),
                             ),
                             child: DisplayTextImageGIF(
                                colorMe: colorMe,
                                colorSender: colorSender,
                                message: messageReply.messageReply.first['message'],
                                type:  messageReply.messageReply.first['typeMessage'] as MessageEnum,
                                check : messageReply.messageReply.first['checkIsMe'] ? 'me' : "not me"
                              ),
                          ),
                    )
                  ),
                ) 
            :  messageReply.messageReply.first['typeMessage'] as MessageEnum == MessageEnum.image 
            ?
             Padding(
              padding: const EdgeInsets.only(bottom:1),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(5)
                  ),
                child: 
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                           height: 90.0,
                           width: 90.0,
                          decoration: BoxDecoration(
                               image: DecorationImage(
                                 image: CachedNetworkImageProvider('${messageReply.messageReply.first['message']}'),
                                 fit: BoxFit.cover,
                               ),
                               shape: BoxShape.rectangle,
                               borderRadius: BorderRadius.circular(5.0),
                             ),
                          ),
                    )
                  ),
                ) 
            :
              Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Container(
                decoration: BoxDecoration(
                  color: messageReply.messageReply.first['checkIsMe'] ? Color(int.parse("0xFF$colorMe")) : Color(int.parse("0xFF$colorSender")),
                  borderRadius: BorderRadius.circular(5)
                  ),
                child: 
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Text('${messageReply.messageReply.first['message']}',style: TextStyle(fontSize: 13,color:messageReply.messageReply.first['checkIsMe'] ? Colors.white : Colors.black),),
                    // child: DisplayTextImageGIF(
                    // message: messageReply.message,
                    // type: messageReply.messageEnum,
                    // check: 'me',
                    //         ),
                  ),
                ),
              )
          )
        ],
      ),
    );
  }
}
