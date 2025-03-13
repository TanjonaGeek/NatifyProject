import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:natify/features/User/presentation/pages/editerprofile.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProfileInformation extends ConsumerWidget {
  final List<UserEntity> MyOwnData;
  final String uid;
  const ProfileInformation(
      {super.key, required this.MyOwnData, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(infoUserStateNotifier);
    final String uidUser = FirebaseAuth.instance.currentUser?.uid ?? "";
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Information'.tr,
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
          actions: [
            if (uid == uidUser)
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.solidPenToSquare,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) => Editerprofile(
                              uid: uid,
                              myOwnData: notifier.MydataPersiste!,
                            )),
                  );
                },
              )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: uid == uidUser
                                ? notifier.MydataPersiste!.profilePic
                                        ?.toString() ??
                                    ""
                                : MyOwnData.first.profilePic?.toString() ?? "",
                            placeholder: (context, url) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) => Container(
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
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: Text(MyOwnData.first.flag?.toString() ?? ""))
                      ],
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          uid == uidUser
                              ? Text(
                                  notifier.MydataPersiste!.name!.length > 20
                                      ? '${notifier.MydataPersiste!.name?.substring(0, 18) ?? ""} ...'
                                      : notifier.MydataPersiste?.name ?? "",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  MyOwnData.first.name!.length > 20
                                      ? '${MyOwnData.first.name?.substring(0, 18) ?? ""} ...'
                                      : MyOwnData.first.name ?? "",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                          Text(
                            uid == uidUser
                                ? notifier.MydataPersiste!.bio?.toString() ?? ""
                                : MyOwnData.first.bio?.toString() ?? "",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Divider(
                thickness: 0.4,
              ),
              // General Section
              ProfileSection(
                title: "Personnels".tr,
                items: [
                  ProfileItem(
                    icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Image.asset(
                          'assets/utilisateur (1).png',
                          width: 19,
                          height: 19,
                        ))),
                    title: "Nom_Prenom".tr,
                    subtitle: uid == uidUser
                        ? "${notifier.MydataPersiste?.nom ?? ""} ${notifier.MydataPersiste?.prenom ?? ""}"
                        : "${MyOwnData.first.nom ?? ""} ${MyOwnData.first.prenom ?? ""}",
                  ),
                  ProfileItem(
                    icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Image.asset(
                          'assets/genre-fluide.png',
                          width: 22,
                          height: 22,
                        ))),
                    title: "Genre".tr,
                    subtitle: uid == uidUser
                        ? notifier.MydataPersiste?.sexe ?? ""
                        : MyOwnData.first.sexe ?? "",
                  ),
                  ProfileItem(
                    icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Image.asset(
                          'assets/localisation-de-ladresse.png',
                          width: 22,
                          height: 22,
                        ))),
                    title: "residant".tr,
                    subtitle:
                        "${uid == uidUser && notifier.MydataPersiste!.pays!.isNotEmpty ? notifier.MydataPersiste?.pays ?? "" : uid != uidUser && MyOwnData.first.pays!.isNotEmpty ? MyOwnData.first.pays ?? "" : SizedBox.shrink()}",
                  ),
                  ProfileItem(
                    icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Image.asset(
                          'assets/drapeau.png',
                          width: 22,
                          height: 22,
                        ))),
                    title: "dorigine".tr,
                    subtitle:
                        "${uid == uidUser && notifier.MydataPersiste!.nationalite!.isNotEmpty ? notifier.MydataPersiste?.nationalite ?? "" : uid != uidUser && MyOwnData.first.nationalite!.isNotEmpty ? MyOwnData.first.nationalite ?? "" : SizedBox.shrink()}",
                  ),
                ],
              ),
              Divider(
                thickness: 0.4,
              ),
              ProfileSection(
                title: "education".tr,
                items: [
                  ProfileItem(
                    icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Image.asset(
                          'assets/college (2).png',
                          width: 22,
                          height: 22,
                        ))),
                    title: "education_college".tr,
                    subtitle:
                        "${uid == uidUser && notifier.MydataPersiste!.college!.isNotEmpty ? notifier.MydataPersiste?.college![0]['nom'] ?? "" : uid != uidUser && MyOwnData.first.college!.isNotEmpty ? MyOwnData.first.college![0]['nom'] : "aucun".tr}",
                  ),
                  ProfileItem(
                    icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Image.asset(
                          'assets/lobtention-du-diplome.png',
                          width: 25,
                          height: 25,
                        ))),
                    title: "education_universite".tr,
                    subtitle:
                        "${uid == uidUser && notifier.MydataPersiste!.universite!.isNotEmpty ? notifier.MydataPersiste?.universite![0]['nom'] ?? "" : uid != uidUser && MyOwnData.first.universite!.isNotEmpty ? MyOwnData.first.universite![0]['nom'] : "aucun".tr}",
                  ),
                ],
              ),
              //  SizedBox(height: 10),
              Divider(
                thickness: 0.4,
              ),
              // Preferences Section
              ProfileSection(
                title: "relation".tr,
                items: [
                  ProfileItem(
                    icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Image.asset(
                          'assets/amour.png',
                          width: 25,
                          height: 25,
                        ))),
                    title: "situation".tr,
                    subtitle:
                        "${uid == uidUser && notifier.MydataPersiste!.situationamoureux!.isNotEmpty ? notifier.MydataPersiste?.situationamoureux![0]['situation'] ?? "" : uid != uidUser && MyOwnData.first.situationamoureux!.isNotEmpty ? MyOwnData.first.situationamoureux![0]['situation'] : "aucun".tr}"
                            .tr,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String title;
  final List<ProfileItem> items;

  const ProfileSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Container(
        decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...items.map((item) => item),
          ],
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const ProfileItem(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: trailing ?? SizedBox(),
      onTap: () {},
    );
  }
}
