import 'package:natify/features/Chat/presentation/widget/sectionBuildCardListMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  String tokenRefresh = Uuid().v1();
  // Fonction pour recharger le Future
  Future<void> _refreshData() async {
    setState(() {
      tokenRefresh = Uuid().v1();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      child: FirestorePagination(
          key: ValueKey(tokenRefresh),
          physics: AlwaysScrollableScrollPhysics(),
          limit: 15, // Defaults to 10.
          isLive: true, // Defaults to false.
          viewType: ViewType.list,
          bottomLoader: SizedBox(),
          initialLoader: // Section de post
              Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar du post
                  Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Texte du post
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          query: firestore
              .collection('users')
              .doc(auth.currentUser?.uid ?? "")
              .collection('chats')
              .orderBy('timeSent', descending: true),
          itemBuilder: (context, documentSnapshot, index) {
            final data = documentSnapshot.data() as Map<String, dynamic>?;
            if (data == null) {
              return Container();
            }
            var listMessageReceive = data;
            return cardListMessage(
                userMessage: listMessageReceive,
                key: ValueKey(data['contactId']));
          },
          onEmpty: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 130,
                      height: 130,
                      child: Image.asset(
                        'assets/discuter.png',
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    "Vous n'avez pas encore de messages".tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Entamez une discussion avec vos amies pour voir leurs réponses ici."
                          .tr,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
