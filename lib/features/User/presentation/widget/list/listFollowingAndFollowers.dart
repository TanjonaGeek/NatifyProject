import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/Chat/presentation/pages/messageDetail.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:natify/features/User/presentation/pages/map/filterOption.dart';
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

class ListFollowingAndFollowers extends ConsumerStatefulWidget {
  final String uid;
  final String nom;
  final String nombrefollowing;
  final String nombrefollower;
  final String optionSelected;
  const ListFollowingAndFollowers({
    required this.uid,
    required this.nom,
    required this.nombrefollowing,
    required this.nombrefollower,
    required this.optionSelected,
    super.key,
  });

  @override
  ConsumerState<ListFollowingAndFollowers> createState() =>
      _ListFollowingAndFollowersState();
}

class _ListFollowingAndFollowersState
    extends ConsumerState<ListFollowingAndFollowers> {
  String selected = "Followers";
  final TextEditingController _searchController = TextEditingController();
  final String uidUser = auth.currentUser?.uid ?? "";
  Timer? _debounce;

  void _filterUsers(String value) {
    _debounce = Timer(const Duration(milliseconds: 1300), () {
      setState(() {});
    });
  }

  bool isUserSubscribed(String uid, List<dynamic> subscribedUids) {
    // Convertir la List<dynamic> en Set<String> pour améliorer les performances
    Set<String> subscribedUidsSet =
        Set<String>.from(subscribedUids.whereType<String>());
    return subscribedUidsSet.contains(uid);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      selected = widget.optionSelected;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(infoUserStateNotifier);
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(widget.nom, style: TextStyle(fontWeight: FontWeight.bold)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FilterOption(
                checkIfAge: false,
                selectedOptions: Helpers.list_Following_Followers,
                selectedItem: selected,
                content: SizedBox(),
                onSelected: (String? selectedss) {
                  _searchController.clear();
                  setState(() {
                    selected = selectedss.toString();
                  });
                },
              ),
              // SizedBox(
              //   height: 10,
              // ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15, right: 15, top: 9, bottom: 9),
              child: TextField(
                onTap: () {},
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 2.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 2.0,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.only(left: 25, top: 15, bottom: 15),
                  hintText: 'Rechercher'.tr,
                  hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                onChanged: (value) => _filterUsers(value),
              ),
            ),
            Divider(
              color: Colors.grey.shade500,
              thickness: 0.2,
            ),
            SizedBox(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                selected == "Followers"
                    ? "(${widget.nombrefollower}) Followers"
                    : "(${widget.nombrefollowing}) Following".tr,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            selected == "Followers"
                ? FutureBuilder(
                    future: Future.delayed(Duration(milliseconds: 500), () {
                      return ref
                          .read(infoUserStateNotifier.notifier)
                          .getInfoUser(widget.uid);
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
                        Query query1 = firestore.collection('users');
                        if (_searchController.text.isNotEmpty) {
                          query1 = query1.where('nameParts',
                              arrayContains:
                                  _searchController.text.toLowerCase());
                        }
                        if (users.first.abonnee!.isNotEmpty) {
                          query1 = query1.where('uid',
                              whereIn: users.first.abonnee!);
                        }
                        return users.first.abonnee!.isEmpty
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
                                      "pas_abonnés".tr,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        "Commencez_partagez".tr,
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
                                initialLoader: SizedBox(),
                                query: query1,
                                itemBuilder:
                                    (context, documentSnapshot, index) {
                                  final data = documentSnapshot.data()
                                      as Map<String, dynamic>?;
                                  if (data == null) return Container();
                                  bool estAbonne = isUserSubscribed(
                                      data['uid'], data['abonnee']);
                                  return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: Container(
                                              key: ValueKey(data['uid']),
                                              child: _buildOption(
                                                  optionSelectedItem:
                                                      "Followers",
                                                  estAbonne: estAbonne,
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
                                      "pas_abonnés".tr,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      textAlign: TextAlign.center,
                                      "Commencez_partagez".tr,
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
                    })
                : FutureBuilder(
                    future: Future.delayed(Duration(milliseconds: 500), () {
                      return ref
                          .read(infoUserStateNotifier.notifier)
                          .getInfoUser(widget.uid);
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
                        final users2 = snapshot.data!;
                        Query query2 = firestore.collection('users');
                        if (_searchController.text.isNotEmpty) {
                          query2 = query2.where('nameParts',
                              arrayContains:
                                  _searchController.text.toLowerCase());
                        }
                        if (users2.first.abonnement!.isNotEmpty) {
                          query2 = query2.where('uid',
                              whereIn: users2.first.abonnement!);
                        }
                        return users2.first.abonnement!.isEmpty
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
                                query: query2,
                                itemBuilder:
                                    (context, documentSnapshot, index) {
                                  final data = documentSnapshot.data()
                                      as Map<String, dynamic>?;
                                  if (data == null) return Container();
                                  bool estAbonne = isUserSubscribed(
                                      uidUser, data['abonnee']);
                                  return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: Container(
                                              key: ValueKey(data['uid']),
                                              child: _buildOption2(
                                                  optionSelectedItem:
                                                      "Following",
                                                  estAbonne: estAbonne,
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
      required BuildContext context,
      required String optionSelectedItem,
      required bool estAbonne}) {
    return ListTile(
      onTap: onTap,
      trailing: IconButton(
          icon: SizedBox(
              width: 28,
              height: 28,
              child: Image.asset(
                'assets/message-de-chat.png',
                color: kPrimaryColor,
              )),
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

  Widget _buildOption2(
      {required String urlPhoto,
      required String uid,
      required String nom,
      required String flag,
      required VoidCallback onTap,
      required BuildContext context,
      required String optionSelectedItem,
      required bool estAbonne}) {
    return ListTile(
      onTap: onTap,
      trailing: (optionSelectedItem == "Following" && estAbonne)
          ? OutlinedButton(
              onPressed: () async {
                // Action au clic
                await ref
                    .read(infoUserStateNotifier.notifier)
                    .desabonner(uid, 'dd');
                Future.delayed(Duration(milliseconds: 600), () {
                  setState(() {});
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black), // Bordure
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)), // Coins arrondis
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8), // Espacement
              ),
              child: Text(
                "Suivi(e)".tr,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            )
          : OutlinedButton(
              onPressed: () async {
                // Action au clic
                await ref
                    .read(infoUserStateNotifier.notifier)
                    .abonner(uid, 'dd');
                Future.delayed(Duration(milliseconds: 600), () {
                  setState(() {});
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black), // Bordure
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)), // Coins arrondis
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8), // Espacement
              ),
              child: Text(
                "Suivre".tr,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
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
