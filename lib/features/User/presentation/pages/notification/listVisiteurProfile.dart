import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/pages/userProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class AllVisiteurByNationality extends StatelessWidget {
  final List<dynamic> listVisiteur;
  const AllVisiteurByNationality({super.key, required this.listVisiteur});
  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Historique des visites de profil'.tr,
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
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            //   child: Text(
            //     "Voici la liste des utilisateurs qui ont récemment visité votre profil."
            //         .tr,
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //       fontSize: 15.0,
            //     ),
            //   ),
            // ),
            // Divider(
            //   color: Colors.grey.shade500,
            //   thickness: 0.2,
            // ),
            SizedBox(
              height: 1,
            ),
            Expanded(
                child: FirestorePagination(
              limit: 10, // Defaults to 10.
              viewType: ViewType.list,
              bottomLoader: Center(
                child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator()),
              ),
              initialLoader: Center(
                child: SizedBox(
                    width: 30, height: 30, child: CircularProgressIndicator()),
              ),
              query: firestore
                  .collection('users')
                  .where('uid', whereIn: listVisiteur),
              itemBuilder: (context, documentSnapshot, index) {
                final data = documentSnapshot.data() as Map<String, dynamic>?;
                if (data == null) return Container();
                return Container(
                  key: ValueKey(data['uid']),
                  child: _buildOption(
                      onTap: () {
                        SlideNavigation.slideToPage(
                            context, UserProfileScreen(uid: data['uid']));
                      },
                      urlPhoto: data['profilePic'],
                      nom: data['name'],
                      flag: data['flag']),
                );
              },
              onEmpty: SizedBox(),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
      {required String urlPhoto,
      required String nom,
      required String flag,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
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
              width: 50,
              height: 50,
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
