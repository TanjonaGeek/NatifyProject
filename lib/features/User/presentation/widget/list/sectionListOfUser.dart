import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/core/utils/widget/contact_card.dart';
import 'package:natify/core/utils/widget/loading.dart';
import 'package:natify/features/User/presentation/pages/map/maps.dart';
import 'package:natify/features/User/presentation/pages/userProfilePage.dart';
import 'package:natify/features/User/presentation/provider/state/list_state_user.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class SectonListOfUser extends ConsumerWidget {
  final VoidCallback onTap;
  final AllUserListState notifier;
  const SectonListOfUser(
      {super.key, required this.onTap, required this.notifier});

  bool isUserSubscribed(String uid, List<dynamic> subscribedUids) {
    // Convertir la List<dynamic> en Set<String> pour améliorer les performances
    Set<String> subscribedUidsSet =
        Set<String>.from(subscribedUids.whereType<String>());

    return subscribedUidsSet.contains(uid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myOwnData = ref.watch(infoUserStateNotifier);
    final String uidUser = auth.currentUser?.uid ?? "";
    var requeteId = const Uuid().v1();
    if (notifier.nameSearch.isEmpty &&
        notifier.nationalite.isEmpty &&
        notifier.pays.isEmpty &&
        notifier.sexe.isEmpty &&
        notifier.isFilter == false &&
        (notifier.rangeOfageDebutAndFin.start.toInt() == 14 &&
            notifier.rangeOfageDebutAndFin.end.toInt() == 90)) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'assets/personnes.png',
                  )),
              // SizedBox(height: 10,),
              // Text("Aucun résultat".tr,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "Explorez les utilisateurs se trouvant à proximité de votre emplacement."
                      .tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => Maps(
                              statusShareDistance:
                                  myOwnData.MydataPersiste!.hiddenPosition,
                              photoUrl: myOwnData.MydataPersiste!.profilePic
                                  .toString(),
                            )),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      "Découvrir".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: kPrimaryColor),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
    // Construire la requête Firestore
    Query query = firestore.collection('users');

    // Ajouter les filtres de recherche
    if (notifier.nameSearch.isNotEmpty) {
      query = query.where('nameParts',
          arrayContains: notifier.nameSearch.toLowerCase());
    }
    if (notifier.nationaliteGroupSansFlag.isNotEmpty) {
      query = query.where('nationalite',
          whereIn: notifier.nationaliteGroupSansFlag);
    }
    if (notifier.pays.isNotEmpty) {
      query = query.where('pays', isEqualTo: notifier.pays);
    }
    if (notifier.sexe.isNotEmpty) {
      query = query.where('sexe', isEqualTo: notifier.sexe);
    }
    if (myOwnData.MydataPersiste!.friendBlocked!.isNotEmpty) {
      query = query.where('uid',
          whereNotIn: myOwnData.MydataPersiste!.friendBlocked!);
    }
    query = query
        .orderBy('ageReel') // Ordre par âge
        .startAt([notifier.rangeOfageDebutAndFin.start.toInt()]).endAt(
            [notifier.rangeOfageDebutAndFin.end.toInt()]);
    return FirestorePagination(
        key: ValueKey(requeteId),
        limit: 15, // Defaults to 10.
        viewType: ViewType.list,
        bottomLoader: Center(
          child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)),
        ),
        initialLoader: Loading(),
        query: query,
        itemBuilder: (context, documentSnapshot, index) {
          final data = documentSnapshot.data() as Map<String, dynamic>?;
          if (data == null) return Container();
          bool estAbonne = isUserSubscribed(uidUser, data['abonnee']);
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 3,
                  ),
                  ContactCard(
                    isAbonne: estAbonne,
                    contactSource: data,
                    onTap: () {
                      SlideNavigation.slideToPage(
                          context, UserProfileScreen(uid: data['uid']));
                    },
                  )
                ],
              )),
            ),
          );
        },
        onEmpty: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/personnes.png',
                    )),
                SizedBox(
                  height: 10,
                ),
                // Text("Aucun résultat".tr,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                // SizedBox(height: 2,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Explorez les utilisateurs se trouvant à proximité de votre emplacement."
                        .tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => Maps(
                                statusShareDistance:
                                    myOwnData.MydataPersiste!.hiddenPosition,
                                photoUrl: myOwnData.MydataPersiste!.profilePic
                                    .toString(),
                              )),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        "Découvrir".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: kPrimaryColor),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

final firestore = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;
