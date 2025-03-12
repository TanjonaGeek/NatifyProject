import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/Chat/presentation/pages/messageDetail.dart';
import 'package:natify/features/Chat/presentation/widget/sectionCardUser.dart';
import 'package:natify/features/Storie/domaine/entities/storie_entities.dart';
import 'package:natify/features/Storie/presentation/pages/creeateStoriePage.dart';
import 'package:natify/features/Storie/presentation/pages/storieViewForMe.dart';
import 'package:natify/features/Storie/presentation/pages/storyViewForAll.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rxdart/rxdart.dart' as Rx;

class ListUserOnline extends ConsumerStatefulWidget {
  const ListUserOnline({super.key});

  @override
  ConsumerState<ListUserOnline> createState() => _ListUserOnlineState();
}

class _ListUserOnlineState extends ConsumerState<ListUserOnline> {
  final String uidUser = FirebaseAuth.instance.currentUser?.uid ?? "";
  late final Stream<List<DocumentSnapshot>> combinedStream;
  @override
  void initState() {
    super.initState();

    // Stream qui récupère friendBlocked
    final userStream1 = FirebaseFirestore.instance
        .collection('users')
        .doc(uidUser)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      return List<String>.from(data?['friendBlocked'] ?? [uidUser]);
    });

    // Stream qui récupère les utilisateurs en ligne
    final userStream2 = FirebaseFirestore.instance
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .where('uid', isNotEqualTo: uidUser)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    // Combine les deux streams
    combinedStream = Rx.CombineLatestStream.combine2(
      userStream1,
      userStream2,
      (friendBlocked, users) {
        return users
            .where((user) => !friendBlocked.contains(user['uid']))
            .toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(infoUserStateNotifier);
    return SizedBox(
        height: 95.0,
        width: double.infinity,
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: combinedStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Shimmer for the circular image
                    Stack(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            height: 55.0,
                            width: 55.0,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.add, color: kPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Shimmer for the text (username)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 10, // Adjust the height as needed
                          width: 40, // Adjust the width as needed
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text("Erreur : ${snapshot.error}"));
            }

            if (!snapshot.hasData && snapshot.data!.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                    future: ref
                        .read(allUserListStateNotifier.notifier)
                        .checkifHasStorie(uidUser),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Shimmer for the circular image
                              Stack(
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8.0),
                                      height: 55.0,
                                      width: 55.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.white,
                                      child:
                                          Icon(Icons.add, color: kPrimaryColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Shimmer for the text (username)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 7),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    height: 10, // Adjust the height as needed
                                    width: 40, // Adjust the width as needed
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      bool hasStorie1 = snapshot.data!['hasStorie'] ?? false;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            hasStorie1
                                ? GestureDetector(
                                    onTap: () async {
                                      List<StorieEntity> storieList = [];
                                      StorieEntity storie = StorieEntity(
                                        uid: snapshot.data?['data']?.uid ?? '',
                                        username:
                                            snapshot.data?['data']?.username ??
                                                'Utilisateur inconnu',
                                        photoUrl: snapshot
                                                    .data?['data']?.photoUrl !=
                                                null
                                            ? List<Map<String, dynamic>>.from(
                                                snapshot.data!['data'].photoUrl)
                                            : [],
                                        createdAt:
                                            snapshot.data?['data']?.createdAt ??
                                                DateTime.now(),
                                        profilePic: snapshot
                                                .data?['data']?.profilePic ??
                                            '',
                                        statusId:
                                            snapshot.data?['data']?.statusId ??
                                                '',
                                        QuivoirStorie: snapshot.data?['data']
                                                    ?.QuivoirStorie !=
                                                null
                                            ? List<Map<String, dynamic>>.from(
                                                snapshot.data!['data']
                                                    .QuivoirStorie)
                                            : [],
                                        storyAvailableForUser: snapshot
                                                    .data?['data']
                                                    ?.storyAvailableForUser !=
                                                null
                                            ? List<String>.from(snapshot
                                                .data!['data']
                                                .storyAvailableForUser)
                                            : [],
                                      );
                                      storieList.add(storie);
                                      await Future.delayed(
                                          const Duration(milliseconds: 50));
                                      SlideNavigation.slideToPage(
                                          context,
                                          StoryViewForMe(
                                              indexJump: 0,
                                              stories: storieList));
                                    },
                                    child: Stack(
                                      children: [
                                        // AnimatedDashedCircle().show(
                                        //   image: CachedNetworkImageProvider(
                                        //       notifier.MydataPersiste
                                        //               ?.profilePic ??
                                        //           ""),
                                        //   contentPadding: 04,
                                        //   autoPlay: true,
                                        //   duration: const Duration(seconds: 5),
                                        //   height: 55,
                                        //   borderWidth: 8,
                                        // ),
                                        CachedNetworkImage(
                                          imageUrl: snapshot.data?['data']
                                                      ?.photoUrl !=
                                                  null
                                              ? "${snapshot.data?['data']?.photoUrl[0]['url']}"
                                              : "",
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            margin: const EdgeInsets.only(
                                                right: 1.0),
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
                                                width:
                                                    1, // Épaisseur de la bordure
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              Container(
                                            margin: const EdgeInsets.only(
                                                right: 1.0),
                                            height: 55.0,
                                            width: 55.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/noimage.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            margin: const EdgeInsets.only(
                                                right: 1.0),
                                            height: 55.0,
                                            width: 55.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/noimage.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.add,
                                                color: kPrimaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      SlideNavigation.slideToPage(
                                          context, GalleryPage());
                                    },
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: notifier
                                                  .MydataPersiste?.profilePic ??
                                              "",
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            margin: const EdgeInsets.only(
                                                right: 8.0),
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
                                                width:
                                                    1, // Épaisseur de la bordure
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              Container(
                                            margin: const EdgeInsets.only(
                                                right: 8.0),
                                            height: 55.0,
                                            width: 55.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/noimage.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            margin: const EdgeInsets.only(
                                                right: 8.0),
                                            height: 55.0,
                                            width: 55.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/noimage.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.add,
                                                color: kPrimaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            SizedBox(height: 7),
                            Text("Créez des Story".tr,
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }

            // Les utilisateurs récupérés
            final users = snapshot.data!;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: users.length + 1, // +1 pour inclure "Créer note"
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Section "Créer note"
                  return FutureBuilder(
                    future: ref
                        .read(allUserListStateNotifier.notifier)
                        .checkifHasStorie(uidUser),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Shimmer for the circular image
                              Stack(
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8.0),
                                      height: 55.0,
                                      width: 55.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.white,
                                      child:
                                          Icon(Icons.add, color: kPrimaryColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Shimmer for the text (username)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 7),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    height: 10, // Adjust the height as needed
                                    width: 40, // Adjust the width as needed
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      bool hasStorie1 = snapshot.data!['hasStorie'] ?? false;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            hasStorie1
                                ? GestureDetector(
                                    onTap: () async {
                                      List<StorieEntity> storieList = [];
                                      StorieEntity storie = StorieEntity(
                                        uid: snapshot.data?['data']?.uid ?? '',
                                        username:
                                            snapshot.data?['data']?.username ??
                                                'Utilisateur inconnu',
                                        photoUrl: snapshot
                                                    .data?['data']?.photoUrl !=
                                                null
                                            ? List<Map<String, dynamic>>.from(
                                                snapshot.data!['data'].photoUrl)
                                            : [],
                                        createdAt:
                                            snapshot.data?['data']?.createdAt ??
                                                DateTime.now(),
                                        profilePic: snapshot
                                                .data?['data']?.profilePic ??
                                            '',
                                        statusId:
                                            snapshot.data?['data']?.statusId ??
                                                '',
                                        QuivoirStorie: snapshot.data?['data']
                                                    ?.QuivoirStorie !=
                                                null
                                            ? List<Map<String, dynamic>>.from(
                                                snapshot.data!['data']
                                                    .QuivoirStorie)
                                            : [],
                                        storyAvailableForUser: snapshot
                                                    .data?['data']
                                                    ?.storyAvailableForUser !=
                                                null
                                            ? List<String>.from(snapshot
                                                .data!['data']
                                                .storyAvailableForUser)
                                            : [],
                                      );
                                      storieList.add(storie);
                                      await Future.delayed(
                                          const Duration(milliseconds: 50));
                                      SlideNavigation.slideToPage(
                                          context,
                                          StoryViewForMe(
                                              indexJump: 0,
                                              stories: storieList));
                                    },
                                    child: Stack(
                                      children: [
                                        // AnimatedDashedCircle().show(
                                        //   image: CachedNetworkImageProvider(
                                        //       notifier.MydataPersiste
                                        //               ?.profilePic ??
                                        //           ""),
                                        //   contentPadding: 04,
                                        //   autoPlay: true,
                                        //   duration: const Duration(seconds: 5),
                                        //   height: 55,
                                        //   borderWidth: 8,
                                        // ),
                                        CachedNetworkImage(
                                          imageUrl: snapshot.data?['data']
                                                      ?.photoUrl !=
                                                  null
                                              ? "${snapshot.data?['data']?.photoUrl[0]['url']}"
                                              : "",
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            margin: const EdgeInsets.only(
                                                right: 1.0),
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
                                                width:
                                                    1, // Épaisseur de la bordure
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              Container(
                                            margin: const EdgeInsets.only(
                                                right: 1.0),
                                            height: 55.0,
                                            width: 55.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/noimage.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            margin: const EdgeInsets.only(
                                                right: 1.0),
                                            height: 55.0,
                                            width: 55.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/noimage.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.add,
                                                color: kPrimaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      SlideNavigation.slideToPage(
                                          context, GalleryPage());
                                    },
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: notifier
                                                  .MydataPersiste?.profilePic ??
                                              "",
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            margin: const EdgeInsets.only(
                                                right: 8.0),
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
                                                width:
                                                    1, // Épaisseur de la bordure
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              Container(
                                            margin: const EdgeInsets.only(
                                                right: 8.0),
                                            height: 55.0,
                                            width: 55.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/noimage.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            margin: const EdgeInsets.only(
                                                right: 8.0),
                                            height: 55.0,
                                            width: 55.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/noimage.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.add,
                                                color: kPrimaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            SizedBox(height: 7),
                            Text("Créez des Story".tr,
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    },
                  );
                }

                // Utilisateur en ligne
                final data = users[index - 1].data() as Map<String,
                    dynamic>?; // Convertir en Map<String, dynamic>?
                if (data == null) {
                  return SizedBox.shrink(); // Gérer le cas où data est null
                }
                final uidFuture = data['uid'];
                return FutureBuilder<Map<String, dynamic>>(
                  future: ref
                      .read(allUserListStateNotifier.notifier)
                      .checkifHasStorie(uidFuture),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Shimmer for the circular image
                            Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                height: 55.0,
                                width: 55.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Shimmer for the text (username)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  height: 10, // Adjust the height as needed
                                  width: 40, // Adjust the width as needed
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    bool hasStorie = snapshot.data!['hasStorie'] ?? false;
                    return uidFuture == FirebaseAuth.instance.currentUser!.uid
                        ? SizedBox.shrink()
                        : cardUserOnline(
                            hasStory: hasStorie,
                            onTap: () async {
                              if (data['uid'] == uidUser) {
                                // Action si c'est le profil de l'utilisateur
                              } else {
                                List<StorieEntity> storieList = [];
                                if (hasStorie) {
                                  StorieEntity storie = StorieEntity(
                                    uid: snapshot.data?['data']?.uid ?? '',
                                    username:
                                        snapshot.data?['data']?.username ??
                                            'Utilisateur inconnu',
                                    photoUrl:
                                        snapshot.data?['data']?.photoUrl != null
                                            ? List<Map<String, dynamic>>.from(
                                                snapshot.data!['data'].photoUrl)
                                            : [],
                                    createdAt:
                                        snapshot.data?['data']?.createdAt ??
                                            DateTime.now(),
                                    profilePic:
                                        snapshot.data?['data']?.profilePic ??
                                            '',
                                    statusId:
                                        snapshot.data?['data']?.statusId ?? '',
                                    QuivoirStorie:
                                        snapshot.data?['data']?.QuivoirStorie !=
                                                null
                                            ? List<Map<String, dynamic>>.from(
                                                snapshot.data!['data']
                                                    .QuivoirStorie)
                                            : [],
                                    storyAvailableForUser: snapshot
                                                .data?['data']
                                                ?.storyAvailableForUser !=
                                            null
                                        ? List<String>.from(snapshot
                                            .data!['data']
                                            .storyAvailableForUser)
                                        : [],
                                  );
                                  storieList.add(storie);
                                  await Future.delayed(
                                      const Duration(milliseconds: 50));
                                  SlideNavigation.slideToPage(
                                      context,
                                      StoryViewForAll(
                                          indexJump: 0, stories: storieList));
                                } else {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => MessageDetail(
                                        urlPhoto:
                                            data['profilePic']?.toString() ??
                                                "",
                                        uid: data['uid']?.toString() ?? "",
                                        name: data['name']?.toString() ?? "",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            key: ValueKey(data['uid'] ?? ""),
                            user: data,
                          );
                  },
                );
              },
            );
          },
        ));
  }
}
