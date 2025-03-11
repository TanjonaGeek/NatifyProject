import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/pages/notification/listVisiteurProfile.dart';
import 'package:natify/features/User/presentation/pages/userProfilePage.dart';
import 'package:natify/features/User/presentation/widget/list/shimmer/shimmerListNotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class AllNotification extends StatelessWidget {
  AllNotification({super.key});
  final String uidUser = auth.currentUser?.uid ?? "";
  Future<void> updateAllStatusOnSeeNotification() async {
    try {
      // Récupérer toutes les notifications dont statusOnSee est false
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .doc(uidUser)
          .collection('Notification')
          .where('statusOnSee', isEqualTo: false)
          .get();

      // Vérifiez si des notifications ont été trouvées
      if (querySnapshot.docs.isEmpty) {
        print('Aucune notification à mettre à jour.');
        return; // Sortir de la fonction si aucune notification n'est trouvée
      }

      // Liste de futures pour mettre à jour chaque document
      List<Future<void>> updateFutures = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Créez une future pour mettre à jour chaque notification
        updateFutures.add(doc.reference.update({'statusOnSee': true}));
      }

      // Attendre que toutes les mises à jour soient complètes
      await Future.wait(updateFutures);
      print('Toutes les notifications mises à jour avec succès.');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    String deNationalite = "de nationalité".tr;
    String quelqueUnNationalite = "Quelqu'un de Nationalite".tr;
    String aCommencer =
        "a commencé à suivre votre profil , Découvrez qui s'intéresse à vous"
            .tr;
    String aVisiter = "à visiter votre profile".tr;
    String a = "à".tr;
    String todays = "Aujourd'hui".tr;
    String reagir = "réagi_votre_story".tr;
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notification'.tr,
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
        body: FutureBuilder(
            future: updateAllStatusOnSeeNotification(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(); // Afficher un indicateur de chargement
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer."
                            .tr)); // Gérer l'erreur
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Text(
                      "Suivez de près les interactions sur votre profil en recevant des notifications personnalisées, et découvrez qui visite votre profiles"
                          .tr,
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
                  Expanded(
                      child: FirestorePagination(
                    limit: 10, // Defaults to 10.
                    viewType: ViewType.list,
                    bottomLoader: SizedBox(),
                    initialLoader: Shimmerlistnotification(),
                    query: firestore
                        .collection('users')
                        .doc(uidUser)
                        .collection('Notification')
                        .orderBy('timeSent', descending: true),
                    itemBuilder: (context, documentSnapshot, index) {
                      final data =
                          documentSnapshot.data() as Map<String, dynamic>?;
                      if (data == null) return Container();
                      var NotifData = data;
                      var timeSentMillis = data['timeSent'] ??
                          0; // Valeur par défaut de 0 si null
                      var datetime =
                          DateTime.fromMillisecondsSinceEpoch(timeSentMillis);
                      var timeSent = DateFormat.Hm().format(datetime);
                      var dateNow = DateTime.now();
                      var dateTimeFormat = DateFormat.yMMMd().format(dateNow);
                      var dateTimeFormat2 = DateFormat.yMMMd().format(datetime);

                      var date = dateTimeFormat == dateTimeFormat2
                          ? todays
                          : DateFormat.yMMMd().format(datetime);

                      return ListTile(
                        onTap: () {
                          if (NotifData['type'] == "follower") {
                            SlideNavigation.slideToPage(
                                context,
                                UserProfileScreen(
                                    uid: data['contactId'] ?? ""));
                          } else {
                            SlideNavigation.slideToPage(
                                context,
                                AllVisiteurByNationality(
                                    listVisiteur:
                                        NotifData['uidUserVisite'] ?? ""));
                          }
                        },
                        leading: Stack(
                          children: [
                            NotifData['type'] == "follower" ||
                                    NotifData['type'] == "reagieStorie"
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: NotifData['profilePic'] ?? "",
                                      placeholder: (context, url) {
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        );
                                      },
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                'assets/noimage.png'),
                                            fit: BoxFit.cover,
                                          ),
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                      ),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : NotifData['type'] == "proximity"
                                    ? Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            // border: Border.all(color: Colors.grey.shade200),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: Center(
                                            child: FaIcon(
                                          FontAwesomeIcons.location,
                                          size: 24,
                                          color: kPrimaryColor,
                                        )),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            // border: Border.all(color: Colors.grey.shade200),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: Center(
                                            child: Text(
                                          '${NotifData['flag'] ?? ""}',
                                          style: TextStyle(fontSize: 27),
                                        )),
                                      ),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: NotifData['type'] == "follower"
                                    ? Text(
                                        '${NotifData['flag'] ?? ""}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      )
                                    : NotifData['type'] == "reagieStorie"
                                        ? Image(
                                            width: 20,
                                            height: 20,
                                            image: AssetImage(
                                                "assets/${NotifData['nombreVisiteurs'] ?? ""}.gif"),
                                          )
                                        : Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                            ),
                                            child: Center(
                                                child: FittedBox(
                                                    child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                '${NotifData['nombreVisiteurs'] ?? ""}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ))),
                                          ))
                          ],
                        ),
                        title: RichText(
                          text: TextSpan(
                            text: NotifData['type'] == "follower" ||
                                    NotifData['type'] == "reagieStorie"
                                ? "${NotifData['name'] ?? ""} $deNationalite"
                                : NotifData['type'] == "proximity"
                                    ? "nouvel_amie_proximité".tr
                                    : " $quelqueUnNationalite",
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  fontSize:
                                      16, // Taille personnalisée pour "Quelqu'un de Nationalite"
                                ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: ' ${NotifData['nationalite'] ?? ""}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              TextSpan(
                                  text: NotifData['type'] == "follower"
                                      ? " $aCommencer"
                                      : NotifData['type'] == "reagieStorie"
                                          ? " $reagir"
                                          : NotifData['type'] == "proximity"
                                              ? ""
                                              : " $aVisiter",
                                  style: TextStyle(
                                    fontSize: 16,
                                  )),
                            ],
                          ),
                          textScaler: TextScaler.linear(
                              MediaQuery.of(context).textScaleFactor),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: Colors.grey.shade600,
                              size: 18,
                            ),
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  text: '',
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: date,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    TextSpan(
                                        text: ' $a $timeSent',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ],
                                ),
                                textScaler: TextScaler.linear(
                                    MediaQuery.of(context).textScaleFactor),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            // if(NotifData['statusRead'] == false)Container(
                            //   width: 7,
                            //   height: 7,
                            //   decoration: BoxDecoration(
                            //     color: kPrimaryColor,
                            //     borderRadius: BorderRadius.all(Radius.circular(30))
                            //   ),
                            // )
                          ],
                        ),
                      );
                    },
                    onEmpty: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      // color:Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                              'assets/cloche-de-notification.png',
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "il n'y a aucune notification à afficher".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Restez à l'écoute pour les nouvelles interactions et mises à jour concernant votre profil."
                                .tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                  ))
                ],
              );
            }),
      ),
    );
  }
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
