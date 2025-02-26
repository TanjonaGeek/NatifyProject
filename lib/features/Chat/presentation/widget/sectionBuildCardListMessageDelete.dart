import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class cardListMessageDelete extends ConsumerStatefulWidget {
  final Map<String, dynamic> userMessage;
  const cardListMessageDelete({super.key, required this.userMessage});

  @override
  ConsumerState<cardListMessageDelete> createState() =>
      _cardListMessageDeleteState();
}

class _cardListMessageDeleteState extends ConsumerState<cardListMessageDelete> {
  @override
  Widget build(BuildContext context) {
    DateTime datetimes =
        DateTime.fromMillisecondsSinceEpoch(widget.userMessage['timeSent']);
    var timeSent = DateFormat.Hm().format(datetimes);
    final userImage = Stack(
      children: <Widget>[
        widget.userMessage['profilePic'] != ""
            ? CachedNetworkImage(
                imageUrl: widget.userMessage['profilePic'].toString(),
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
            widget.userMessage['flag'].toString(),
            style: const TextStyle(
              color: Colors.black,
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
                    tag: widget.userMessage['name'].toString(),
                    child: Text(
                      widget.userMessage['name'].toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
                Text(
                  timeSent,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
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
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Loader circulaire
                          SizedBox(
                            width: 25.0,
                            height: 25.0,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 3.0,
                            ),
                          ),
                          // Icône de suppression au centre
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 30.0 / 2,
                          ),
                        ],
                      )
                    ],
                  )
                : Text(
                    widget.userMessage['lastMessage'] == "messageretirerforall"
                        ? 'messageretire'
                        : widget.userMessage['lastMessage'] ==
                                "messageretirerforme"
                            ? 'messageretire'
                            : widget.userMessage['lastMessage'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ],
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
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
    );
  }
}
