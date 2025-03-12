import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/features/User/presentation/pages/map/listeUtilisateurAproximite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UtilisateuraproximiteNationalite extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> users;
  const UtilisateuraproximiteNationalite({required this.users, super.key});
  @override
  _UtilisateuraproximiteNationaliteState createState() =>
      _UtilisateuraproximiteNationaliteState();
}

class _UtilisateuraproximiteNationaliteState
    extends ConsumerState<UtilisateuraproximiteNationalite> {
  bool isUserSubscribed(String uid, List<dynamic> subscribedUids) {
    // Convertir la List<dynamic> en Set<String> pour améliorer les performances
    Set<String> subscribedUidsSet =
        Set<String>.from(subscribedUids.whereType<String>());

    return subscribedUidsSet.contains(uid);
  }

  @override
  Widget build(BuildContext context) {
    String Proximite = "Proximité".tr;
    String uidUser = FirebaseAuth.instance.currentUser?.uid ?? "";
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('$Proximite ${widget.users[0]['nationalite']}',
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
          actions: [SizedBox()],
        ),
        body: Consumer(
          builder: ((context, ref, child) {
            return widget.users.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Image.asset(
                                'assets/localisation-de-lutilisateur.png',
                                width: 120,
                                height: 120),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Aucun résultat".tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "Personne n'a été trouvé dans votre zone. Essayez de modifier vos critères de recherche."
                                  .tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Utilisateurs proches de vous, visibles dans la zone sélectionnée pour faciliter les connexions."
                              .tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Container(
                        child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 5.0,
                                    crossAxisSpacing: 5.0,
                                    mainAxisExtent: 220),
                            padding: const EdgeInsets.all(8.0),
                            itemCount: widget.users.length,
                            itemBuilder: (context, index) {
                              bool estAbonne = isUserSubscribed(
                                  uidUser, widget.users[index]['abonnee']);
                              return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  columnCount: 3,
                                  child: SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: CardUserProximity(
                                          notifiers: widget.users,
                                          index: index,
                                          isAbonne: estAbonne,
                                        ),
                                      )));
                            }),
                      )
                    ],
                  );
          }),
        ),
      ),
    );
  }
}
