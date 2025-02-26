import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/info/fill/isFillAgePage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class Isfillsexepage extends ConsumerStatefulWidget {
  const Isfillsexepage({super.key});

  @override
  _IsfillsexepageState createState() => _IsfillsexepageState();
}

class _IsfillsexepageState extends ConsumerState<Isfillsexepage> {
  String selectedGender = 'homme';

  Future<void> navigateToNextStep() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      if (mounted) {
        ref.read(infoUserStateNotifier.notifier).updateInfoUser(
            FirebaseAuth.instance.currentUser!.uid, 'sexe', selectedGender, '');
      }
      SlideNavigation.slideToPagePushRemplacement(context, Isfillagepage());
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisissez votre sexe'.tr,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                textAlign: TextAlign.center,
                'Veuillez sélectionner le sexe qui correspond le mieux à votre identité afin de personnaliser votre expérience.'
                    .tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: GenderCard(
                    gender: 'homme',
                    icon: Icons.male,
                    isSelected: selectedGender == 'homme',
                    onTap: () {
                      setState(() {
                        selectedGender = 'homme';
                      });
                    },
                    color: kPrimaryColor,
                  ),
                ),
                SizedBox(width: 7),
                Flexible(
                  child: GenderCard(
                    gender: 'femme',
                    icon: Icons.female,
                    isSelected: selectedGender == 'femme',
                    onTap: () {
                      setState(() {
                        selectedGender = 'femme';
                      });
                    },
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GenderCard extends StatelessWidget {
  final String gender;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const GenderCard({
    super.key,
    required this.gender,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              SizedBox(height: 10),
              Text(
                gender.tr,
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
