import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/imageGallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class Modifierprofile extends ConsumerStatefulWidget {
  final String profilePic;
  final String uid;
  const Modifierprofile(
      {super.key, required this.profilePic, required this.uid});
  @override
  ConsumerState<Modifierprofile> createState() => _EditerprofileState();
}

class _EditerprofileState extends ConsumerState<Modifierprofile> {
  final _formKey = GlobalKey<FormState>();
  final List<File> photoProfile = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void openPhotoAdd() async {
      final selectedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Imagegallery(),
        ),
      );
      photoProfile.clear();
      if (selectedImage != null) {
        print('le image select est $selectedImage');
        photoProfile.add(selectedImage);
        setState(() {});
      }
    }

    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Modifier_photo_profile".tr,
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
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       if (mounted) {
          //         ref
          //             .read(infoUserStateNotifier.notifier)
          //             .updatePhotoProfileUser(widget.uid, photoProfile);
          //       }
          //       Navigator.pop(context);
          //     },
          //     child: Text(
          //       "Enregistrer".tr,
          //       style: TextStyle(
          //           color: kPrimaryColor, fontWeight: FontWeight.bold),
          //     ),
          //   )
          // ],
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image and Section Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => openPhotoAdd(),
                          child: photoProfile.isNotEmpty
                              ? Stack(
                                  children: [
                                    ClipOval(
                                      child: SizedBox(
                                          width:
                                              120, // Définir la largeur du cercle
                                          height:
                                              120, // Définir la hauteur du cercle
                                          child: Image.file(
                                            photoProfile
                                                .first, // Afficher l'image à partir du fichier
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                    Positioned(
                                        bottom: 8,
                                        right: 3,
                                        child: FaIcon(FontAwesomeIcons.camera,
                                            size: 24, color: kPrimaryColor))
                                  ],
                                )
                              : Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: widget.profilePic,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        height: 120.0,
                                        width: 120.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white),
                                        ),
                                      ),
                                      placeholder: (context, url) => Container(
                                        margin: EdgeInsets.only(right: 8.0),
                                        height: 120.0,
                                        width: 120.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/noimage.png'),
                                            fit: BoxFit.cover,
                                          ),
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        margin: EdgeInsets.only(right: 8.0),
                                        height: 120.0,
                                        width: 120.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/noimage.png'),
                                            fit: BoxFit.cover,
                                          ),
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 8,
                                        right: 3,
                                        child: FaIcon(FontAwesomeIcons.camera,
                                            size: 24, color: kPrimaryColor))
                                  ],
                                ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Divider(
                            color: Colors.grey.shade300,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: ElevatedButton(
            onPressed: () {
              if (mounted) {
                ref
                    .read(infoUserStateNotifier.notifier)
                    .updatePhotoProfileUser(widget.uid, photoProfile);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              textStyle: TextStyle(fontSize: 18),
            ),
            child: Text(
              textAlign: TextAlign.center,
              "Enregistrer".tr,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
