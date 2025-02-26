import 'package:animated_dashed_circle/animated_dashed_circle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class cardUserOnline extends StatelessWidget {
  final Map<String, dynamic> user;
  final GestureTapCallback onTap;
  final bool hasStory; // Nouveau paramètre
  const cardUserOnline(
      {super.key,
      required this.user,
      required this.onTap,
      required this.hasStory});

  @override
  Widget build(BuildContext context) {
    final String uidUser = FirebaseAuth.instance.currentUser?.uid ?? "";
    final onlineTag = Positioned(
      bottom: 1.0,
      right: 12.0,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(30))),
      ),
    );
    final flagTag = Positioned(
      bottom: 0,
      left: 2,
      child: Container(
        child: Text(
          user['flag']?.toString() ?? "",
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
    return SizedBox(
      width: 80,
      child: Padding(
        padding: const EdgeInsets.only(top: 3, left: 5, right: 5, bottom: 2),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: onTap,
              child: Stack(
                children: <Widget>[
                  hasStory
                      ? AnimatedDashedCircle().show(
                          image: user['profilePic']!.toString().isEmpty
                              ? AssetImage('assets/noimage.png')
                              : CachedNetworkImageProvider(
                                  user['profilePic']?.toString() ?? ""),
                          contentPadding: 04,
                          autoPlay: true,
                          duration: const Duration(seconds: 5),
                          height: 55,
                          borderWidth: 8,
                        )
                      : hasStory == false
                          ? CachedNetworkImage(
                              imageUrl: user['profilePic']?.toString() ?? "",
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                height: 55.0,
                                width: 55.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors
                                        .grey, // Condition pour la bordure bleue
                                    width: 1, // Épaisseur de la bordure
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                height: 55.0,
                                width: 55.0,
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
                                height: 55.0,
                                width: 55.0,
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
                              margin: const EdgeInsets.only(right: 8.0),
                              height: 55.0,
                              width: 55.0,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('assets/noimage.png'),
                                  fit: BoxFit.cover,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                  onlineTag,
                  flagTag
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            uidUser == user['uid']
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Moi",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          user['name']?.toString() ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
