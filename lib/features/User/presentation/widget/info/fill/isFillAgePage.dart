import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/core/utils/widget/springy_slider/springy_slider.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/info/fill/isFillNationalitePage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class Isfillagepage extends ConsumerStatefulWidget {
  static const String path = "lib/src/pages/misc/springy_slider_page.dart";

  const Isfillagepage({super.key});

  @override
  ConsumerState<Isfillagepage> createState() => _IsfillagepageState();
}

class _IsfillagepageState extends ConsumerState<Isfillagepage> {
  double sliderValue = 0.14; // Stocke la valeur du slider
  bool isChecked = false;
  _buildTextButton(String title, bool isOnLight) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      ),
      onPressed: () {},
      child: Text(title,
          style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: isOnLight ? kPrimaryColor : Colors.white)),
    );
  }

  Future<void> navigateToNextStep() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      int sliderPercentage = (sliderValue * 100).round();
      if (sliderPercentage < 14) {
        showCustomSnackBar("L'âge minimum autorisé est de 14 ans");
      } else {
        List<Map<String, dynamic>> dataAge = [];
        dataAge.add({
          'age': sliderPercentage.toString(),
          'visibilite': isChecked ? 'Moi uniquement' : 'Public',
        });
        if (mounted) {
          ref.read(infoUserStateNotifier.notifier).updateInfoUser(
              FirebaseAuth.instance.currentUser!.uid, 'age', dataAge, '');
        }
        SlideNavigation.slideToPagePushRemplacement(
            context, Isfillnationalitepage());
      }
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Indiquez-nous votre âge'.tr,
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
                    child: FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  size: 20,
                ))),
            onPressed: () {
              // Action for the back button
              Navigator.pop(context);
            },
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TextButton(
                  onPressed: navigateToNextStep,
                  child: Text('OK'.tr,
                      style: TextStyle(
                          fontSize: 17,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold)),
                )),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                textAlign: TextAlign.center,
                'Veuillez sélectionner votre âge afin de personnaliser votre expérience et garantir un contenu adapté.'
                    .tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SpringySlider(
                  markCount: 12,
                  positiveColor: kPrimaryColor,
                  negativeColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                  onSliderValueChanged: (value) {
                    // Met à jour la valeur du slider à chaque changement
                    setState(() {
                      sliderValue = value;
                    });
                  },
                ),
              ),
            ),
            Container(
              color: kPrimaryColor,
              child: Row(
                children: [
                  Checkbox(
                    activeColor: Colors.white,
                    checkColor: Colors.red,
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Ne partager mon âge qu'avec moi".tr,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
