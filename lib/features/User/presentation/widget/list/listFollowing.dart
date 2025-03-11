import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/Chat/presentation/pages/messageDetail.dart';
import 'package:natify/features/User/presentation/pages/userProfilePage.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/list/shimmer/shimmerFollower_Following.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class AllUserFollowing extends ConsumerWidget {
  final String uid;
  const AllUserFollowing({
    required this.uid,
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Listes_following'.tr,
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Center(
                    child: FaIcon(FontAwesomeIcons.chevronLeft, size: 20))),
            onPressed: () {
              // Action for the back button
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Text(
                "Voici_la_liste_following".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade500,
              thickness: 0.2,
            ),
            SizedBox(
              height: 1,
            ),
            FutureBuilder(
                future: Future.delayed(Duration(milliseconds: 500), () {
                  return ref
                      .read(infoUserStateNotifier.notifier)
                      .getInfoUser(uid);
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: ShimmerLoadingFollowers(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Erreur : ${snapshot.error}')); // Gérer les erreurs
                  } else if (snapshot.hasData) {
                    final users = snapshot.data!;

                    return users.first.abonnement!.isEmpty
                        ? Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: Image.asset(
                                    'assets/grouper.png',
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  textAlign: TextAlign.center,
                                  "Vous_nabonnez".tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "Explorez_utilisateurs".tr,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: FirestorePagination(
                            limit: 10, // Defaults to 10.
                            viewType: ViewType.list,
                            bottomLoader: SizedBox(),
                            initialLoader: Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: SizedBox(),
                              ),
                            ),
                            query: firestore
                                .collection('users')
                                .where('uid', whereIn: users.first.abonnement),
                            itemBuilder: (context, documentSnapshot, index) {
                              final data = documentSnapshot.data()
                                  as Map<String, dynamic>?;
                              if (data == null) return Container();

                              return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Container(
                                          key: ValueKey(data['uid']),
                                          child: _buildOption(
                                              uid: data['uid'],
                                              context: context,
                                              onTap: () {
                                                SlideNavigation.slideToPage(
                                                    context,
                                                    UserProfileScreen(
                                                        uid: data['uid']));
                                              },
                                              urlPhoto: data['profilePic'],
                                              nom: data['name'],
                                              flag: data['flag']),
                                        ),
                                      )));
                            },
                            onEmpty: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: Image.asset(
                                    'assets/grouper.png',
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  textAlign: TextAlign.center,
                                  "Vous_nabonnez".tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  textAlign: TextAlign.center,
                                  "Explorez_utilisateurs".tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17),
                                ),
                              ],
                            ),
                          ));
                  } else {
                    return Container();
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
      {required String urlPhoto,
      required String uid,
      required String nom,
      required String flag,
      required VoidCallback onTap,
      required BuildContext context}) {
    return ListTile(
      onTap: onTap,
      trailing: IconButton(
          icon: FaIcon(FontAwesomeIcons.message,
              size: 24,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => MessageDetail(
                  urlPhoto: urlPhoto.toString(),
                  uid: uid.toString(),
                  name: nom.toString(),
                ),
              ),
            );
          }),
      leading: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: urlPhoto,
            imageBuilder: (context, imageProvider) => Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
            placeholder: (context, url) => Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 50.0,
              width: 50.0,
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
          ),
          Positioned(bottom: 0, right: 0, child: Text(flag))
        ],
      ),
      title: Text(
        nom,
        style: TextStyle(fontSize: 16),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 1.0, horizontal: 15.0),
    );
  }
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
