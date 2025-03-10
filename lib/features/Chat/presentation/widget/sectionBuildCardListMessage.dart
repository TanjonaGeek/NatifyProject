import 'package:natify/features/Chat/presentation/pages/messageDetail.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class cardListMessage extends ConsumerStatefulWidget {
  final Map<String, dynamic> userMessage;
  const cardListMessage({super.key, required this.userMessage});

  @override
  ConsumerState<cardListMessage> createState() => _cardListMessageState();
}

class _cardListMessageState extends ConsumerState<cardListMessage>
    with SingleTickerProviderStateMixin {
  late final controller = SlidableController(this);
  @override
  Widget build(BuildContext context) {
    DateTime datetimes = DateTime.fromMillisecondsSinceEpoch(
        widget.userMessage['timeSent'] ?? 0);
    var timeSent = DateFormat.Hm().format(datetimes);
    String uid = widget.userMessage['contactId'] ?? "";
    String uidUser = FirebaseAuth.instance.currentUser?.uid ?? "";
    void desappearMessageInList() async {
      if (mounted) {
        ref.read(chatStateNotifier(uid).notifier).desapearMessageInList(uid);
      }
    }

    final userImage = Stack(
      children: <Widget>[
        widget.userMessage['profilePic'] != ""
            ? CachedNetworkImage(
                imageUrl: widget.userMessage['profilePic']?.toString() ?? "",
                imageBuilder: (context, imageProvider) => Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey, // Condition pour la bordure bleue
                      width: 1, // Épaisseur de la bordure
                    ),
                  ),
                ),
                placeholder: (context, url) => Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    image: const DecorationImage(
                      image: AssetImage('assets/noimage.png'),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    image: const DecorationImage(
                      image: AssetImage('assets/noimage.png'),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(right: 8.0, bottom: 10.0),
                height: 60.0,
                width: 60.0,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/noimage.png'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey),
                  shape: BoxShape.circle,
                ),
              ),
        Positioned(
          bottom: 0,
          right: 10,
          child: Text(
            widget.userMessage['flag']?.toString() ?? "",
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        )
      ],
    );

    final userNameMessage = Expanded(
      child: Container(
        padding: const EdgeInsets.only(left: 1.0, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Hero(
                    tag: widget.userMessage['name']?.toString() ?? "",
                    child: Text(
                      widget.userMessage['name']?.toString() ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .appBarTheme
                          .titleTextStyle
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                15.0, // On force uniquement la graisse en bold
                          ),
                    ),
                  ),
                ),
                widget.userMessage['statusRead'] != false
                    ? Text(
                        timeSent,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 10),
                      )
                    : Text(
                        "🔵  $timeSent",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 10),
                      )
              ],
            ),
            const SizedBox(
              height: 7,
            ),
            widget.userMessage['statusRead'] != false
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.userMessage['lastMessage'] ==
                                  "messageretirerforall"
                              ? 'messageretire'
                              : widget.userMessage['lastMessage'] ==
                                      "messageretirerforme"
                                  ? 'messageretire'
                                  : widget.userMessage['lastMessage']
                                      .toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      (widget.userMessage['checkStatusReadOnOther'] == true &&
                              widget.userMessage['messageLastBy'] == uidUser)
                          ? Container(
                              height: 15.0,
                              width: 15.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: widget.userMessage['profilePic']!
                                          .toString()
                                          .isEmpty
                                      ? AssetImage('assets/noimage.png')
                                      : CachedNetworkImageProvider(widget
                                              .userMessage['profilePic']
                                              ?.toString() ??
                                          ""),
                                  fit: BoxFit.cover,
                                ),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1.0),
                                // gradient: primaryGradient,
                              ),
                            )
                          : const SizedBox()
                    ],
                  )
                : Text(
                    widget.userMessage['lastMessage'] == "messageretirerforall"
                        ? 'messageretire'
                        : widget.userMessage['lastMessage'] ==
                                "messageretirerforme"
                            ? 'messageretire'
                            : widget.userMessage['lastMessage'].toString(),
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  13.0, // On force uniquement la graisse en bold
                            ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ],
        ),
      ),
    );
    return InkWell(
      onTap: () async {
        String uid = widget.userMessage['contactId']?.toString() ?? "";
        // if (mounted) {
        //   ref.read(chatStateNotifier(uid).notifier).unreadMessage(uid);
        // }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => MessageDetail(
              urlPhoto: widget.userMessage['profilePic']?.toString() ?? "",
              uid: widget.userMessage['contactId']?.toString() ?? "",
              name: widget.userMessage['name']?.toString() ?? "",
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Slidable(
          key: ValueKey(widget.userMessage['contactId']),
          controller: controller,
          endActionPane: ActionPane(
            extentRatio: 0.3,
            motion:
                StretchMotion(), // Utilisation de DrawerMotion pour un effet de glissement différent
            children: [
              SlidableAction(
                onPressed: (_) => desappearMessageInList(),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                label: 'supprimer'.tr,
              ),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 12),
            child: Row(
              children: [
                userImage,
                userNameMessage,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//  child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(Radius.circular(17)) 
//             ),
//             margin: const EdgeInsets.only(bottom: 7.0),
//             child: Padding(
//               padding: const EdgeInsets.only(right: 10,left:10,top: 10,bottom: 12),
//               child: Row(
//                 children: [
//                  userImage,
//                  userNameMessage,
//                 ],
//               ),
//             ),
//           ),