import 'dart:ui';

import 'package:animated_dashed_circle/animated_dashed_circle.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/my_date_util.dart';
import 'package:natify/core/utils/widget/loading.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:natify/features/Chat/presentation/widget/MessageInputField.dart';
import 'package:natify/features/Chat/presentation/widget/sectionListMessageSpecific.dart';
import 'package:natify/features/User/presentation/pages/userProfilePage.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MessageDetail extends ConsumerWidget {
  final String urlPhoto;
  final String uid;
  final String name;
  const MessageDetail(
      {required this.urlPhoto,
      required this.uid,
      required this.name,
      super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String AvezVousDebloquer = "debloquer".tr;
    String VousEtesBloquer = "Vous avez été bloqué par".tr;
    final notifier = ref.watch(themesStateNotifier);
    Future<List<Map<String, String>>> getUserTheme(
        String uidSendMessage) async {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      try {
        final docSnapshot = await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('chats')
            .doc(uidSendMessage)
            .collection('theme')
            .doc('currentTheme')
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()?['themeMessage'] as List<dynamic>?;
          print('le donner est $data');
          // Convertir la liste dynamique en List<Map<String, String>>
          if (data != null) {
            return data.map((item) => Map<String, String>.from(item)).toList();
          }
        }
        return []; // Retourne une liste vide si aucune donnée n'est trouvée
      } catch (e) {
        print('Erreur lors de la récupération du thème : $e');
        return [];
      }
    }

    return FutureBuilder(
        key: ValueKey(notifier.tokenUpdateTheme),
        future: Future.wait([
          getUserTheme(uid),
          ref.read(infoUserStateNotifier.notifier).getInfoUser(uid),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                  child:
                      Loading()), // Indicateur de chargement pendant la récupération du thème
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                  child: Text('Erreur lors du chargement du thème',
                      style: TextStyle(color: Colors.red))),
            );
          }

          final themeData = snapshot.data?[0] ?? [];
          final userInfo = snapshot.data?[1];
          String imageFond = themeData.isEmpty
              ? "assets/theme_chat/bufferfly.png"
              : (themeData[0] as Map)['image'];
          String nameFond =
              themeData.isEmpty ? "BUFFERFLY" : (themeData[0] as Map)['name'];
          String colorSender = themeData.isEmpty
              ? "f5f5f1"
              : (themeData[0] as Map)['colorSender'];
          String colorMe =
              themeData.isEmpty ? "90c390" : (themeData[0] as Map)['colorMe'];

          if (userInfo!.isEmpty) {
            return Scaffold(
              body: Center(
                child: Text(
                    textAlign: TextAlign.center,
                    "Ce message n'est pas disponible. L'utilisateur a désactivé ou supprimé son compte."
                        .tr,
                    style: TextStyle(color: Colors.red)),
              ), // Indicateur de chargement pendant la récupération du thème
            );
          }
          return WillPopScope(
            onWillPop: () async {
              ref.read(chatStateNotifier(uid).notifier).cancelReply();
              return true; // Retourne true pour autoriser la sortie, false pour bloquer
            },
            child: ThemeSwitchingArea(
              child: Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black
                            .withOpacity(0.1), // Semi-transparent avec flou
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Center(
                            child: FaIcon(FontAwesomeIcons.chevronLeft,
                                size: 20, color: Colors.white))),
                    onPressed: () {
                      ref.read(chatStateNotifier(uid).notifier).cancelReply();
                      // Action for the back button
                      Navigator.pop(context);
                    },
                  ),
                  title: GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(uid: uid),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            FutureBuilder<Map<String, dynamic>>(
                                future: ref
                                    .read(allUserListStateNotifier.notifier)
                                    .checkifHasStorie(uid),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Shimmer.fromColors(
                                      key: ValueKey(urlPhoto),
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
                                  }
                                  bool hasStorie =
                                      snapshot.data!['hasStorie'] ?? false;
                                  return hasStorie
                                      ? AnimatedDashedCircle().show(
                                          image: urlPhoto.isEmpty
                                              ? AssetImage('assets/noimage.png')
                                              : CachedNetworkImageProvider(
                                                  urlPhoto),
                                          contentPadding: 04,
                                          autoPlay: true,
                                          duration: const Duration(seconds: 5),
                                          height: 40,
                                          borderWidth: 8,
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(
                                              right: 8.0, top: 8),
                                          height: 40.0,
                                          width: 40.0,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: urlPhoto.isEmpty
                                                  ? AssetImage(
                                                      'assets/noimage.png')
                                                  : CachedNetworkImageProvider(
                                                      urlPhoto),
                                              fit: BoxFit.cover,
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Color(int.parse(
                                                    "0xFF$colorSender"))),
                                          ),
                                        );
                                }),
                            Positioned(
                                bottom: 0,
                                right: 6,
                                child: Text(
                                  '',
                                  style: TextStyle(fontSize: 13),
                                ))
                          ],
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow
                                    .ellipsis, // Tronque le texte si trop long
                              ),
                              StreamBuilder(
                                  stream: ref
                                      .read(chatStateNotifier(uid).notifier)
                                      .getStatusOnline(uid),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox();
                                    }
                                    if (snapshot.data!.isEmpty) {
                                      return SizedBox();
                                    } else {
                                      bool statusOnline =
                                          snapshot.data?.first.isOnline ??
                                              false;
                                      String lastActiveTimeStr =
                                          snapshot.data?.first.LastActivetime ??
                                              '0';
                                      int timeS;
                                      try {
                                        timeS = int.parse(lastActiveTimeStr);
                                      } catch (e) {
                                        timeS =
                                            0; // Valeur par défaut en cas d'erreur de conversion
                                      }

                                      // Convertir en DateTime avec une valeur par défaut si timeS est 0
                                      var lastOnline =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              timeS);
                                      return Text(
                                        statusOnline == true
                                            ? "en ligne".tr
                                            : MyDateUtil.timeAgoSinceDate(
                                                lastOnline.toString()),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      );
                                    }
                                  }),
                              SizedBox(
                                height: 5,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                body: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imageFond),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black
                              .withOpacity(0.5), // Applique une opacité de 50%
                          BlendMode.srcOver,
                        ),
                      ),
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return Column(
                          children: [
                            Expanded(
                              child: ListMessageDetail(
                                colorMe: colorMe,
                                colorSender: colorSender,
                                uidUser: uid,
                                photo: urlPhoto,
                                name: name,
                              ),
                            ),
                            StreamBuilder<bool>(
                                stream: ref
                                    .read(chatStateNotifier(uid).notifier)
                                    .getStatusBlockOnChat(uid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox();
                                  }
                                  var chatContactData = snapshot.data ?? false;
                                  return StreamBuilder<bool>(
                                      stream: ref
                                          .read(chatStateNotifier(uid).notifier)
                                          .getStatusBlock(uid),
                                      builder: (context, snapshot1) {
                                        var statusBlock =
                                            snapshot1.data ?? false;
                                        return chatContactData == true &&
                                                statusBlock == false
                                            ? Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 50,
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color(int.parse(
                                                              "0xFF$colorSender")),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(1),
                                                        ),
                                                        child: Text(
                                                          '$VousEtesBloquer $name',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(context)
                                                                          .brightness ==
                                                                      Brightness
                                                                          .dark
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black),
                                                        )),
                                                  ),
                                                ],
                                              )
                                            : chatContactData == false &&
                                                    statusBlock == true
                                                ? Column(
                                                    children: [
                                                      SizedBox(
                                                          width:
                                                              double.infinity,
                                                          height: 50,
                                                          child: ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Color(int.parse(
                                                                        "0xFF$colorSender")),
                                                              ),
                                                              onPressed: () {
                                                                ref
                                                                    .read(chatStateNotifier(
                                                                            uid)
                                                                        .notifier)
                                                                    .debloquerConversation(
                                                                        uid);
                                                              },
                                                              child: Text(
                                                                '$AvezVousDebloquer $name',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ))),
                                                    ],
                                                  )
                                                : MessageInputField(
                                                    themeApply: nameFond,
                                                    userUid: uid,
                                                    colorSender: colorSender,
                                                    colorMe: colorMe);
                                      });
                                }),
                          ],
                        );
                      },
                    )),
              ),
            ),
          );
        });
  }
}
