import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/config/themes/themeColors.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class Parametre extends ConsumerStatefulWidget{
  const Parametre({super.key,});

  @override
  ConsumerState<Parametre> createState() => _ParametreState();
}

class _ParametreState extends ConsumerState<Parametre> {
   // Variables pour gérer l'état des switches
  bool masquerLocation = false;
  bool alertLocation = false;
  bool alertPublication = false;
  bool partageMedia = false;
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(infoUserStateNotifier);
    return ThemeSwitchingArea(
      child: Scaffold(
       appBar: AppBar(
          title: Text('Parametre'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                child: Center(child: FaIcon(FontAwesomeIcons.chevronLeft,size:20))),
              onPressed: () {
                // Action for the back button
                Navigator.pop(context);
              },
            ),
            actions: [
              ThemeSwitcher.withTheme(
                      builder: (_, switcher, theme) {
                        return IconButton(
                          onPressed: () => switcher.changeTheme(
                            theme: theme.brightness == Brightness.light
                                ? darkTheme
                                : lightTheme,
                          ),
                          icon: const Icon(Icons.brightness_2, size: 22),
                        );
                      },
                    ),
            ],
        ),
        body: Consumer(
          builder: (context, ref, child){
              return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // Settings Section
              Text(
                'Localisation'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildSwitchTile(
                title: 'Masquer ma distance sur la carte',
                subtitle: "Empêche l'affichage de votre distance exacte sur la carte de proximité.",
                value: notifier.MydataPersiste!.hiddenPosition,
                onChanged: (value) {
                  // setState(() {
                  //   showTrafficOnMap = value;
                  // });
                    if(mounted){
                      ref.read(infoUserStateNotifier.notifier).updateDistancePosition(value);
                    }
                },
              ),
              _buildSwitchTile(
                title: 'Alerte de localisation en déplacement',
                subtitle:
                    'Recevez une alerte si vous dépassez 100 km de votre position actuelle.',
                value: notifier.MydataPersiste!.alertLocation,
                onChanged: (value) {
                  // setState(() {
                  //   showDriverLocation = value;
                  // });
                   if(mounted){
                      ref.read(infoUserStateNotifier.notifier).updateStatusAutorize(value,"alertLocation");
                   }
                },
              ),
              // Divider(color: Colors.grey.shade300,),
              // SizedBox(height: 10),
              // // Notifications Section
              // Text(
              //   'Notifications',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 10),
              // _buildSwitchTile(
              //   title: 'Publication',
              //   subtitle: "Avertit vos abonnés de vos nouvelles publications.",
              //   value: notifier.MydataPersiste!.alertPublication,
              //   onChanged: (value) {
              //     // setState(() {
              //     //   priceDrops = value;
              //     // });
              //       if(mounted){
              //         ref.read(infoUserStateNotifier.notifier).updateStatusAutorize(value,"alertPublication");
              //       }
              //   },
              // ),
              // Divider(color: Colors.grey.shade300,),
              // SizedBox(height: 10),
              // Notifications Section
              // Text(
              //   'Media',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 10),
              // _buildSwitchTile(
              //   title: 'Partage de contenu',
              //   subtitle: "Autorise vos amis à télécharger vos photos et vidéos.",
              //   value: notifier.MydataPersiste!.partageMedia,
              //   onChanged: (value) {
              //     // setState(() {
              //     //   priceDrops = value;
              //     // });
              //     if(mounted){
              //         ref.read(infoUserStateNotifier.notifier).updateStatusAutorize(value,"partageMedia");
              //     }
              //   },
              // ),
            ],
          );
          },
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title.tr, style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500)),
          subtitle: subtitle != null ? Text(subtitle.tr) : null,
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kPrimaryColor,
          ),
        ),
        // Divider(color: Colors.grey.shade300,),
      ],
    );
  }
}
final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;