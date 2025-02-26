import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SignalerProfile extends ConsumerStatefulWidget {
  final String uidSignal;
  const SignalerProfile({required this.uidSignal, super.key});

  @override
  ConsumerState<SignalerProfile> createState() => _SignalerProfileState();
}

class _SignalerProfileState extends ConsumerState<SignalerProfile> {
  String? _selectedOption;
  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Signaler_profil'.tr,
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
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "Veuillez_selectionner".tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "Choisissez_raison".tr,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500),
                ),
              ),
              SizedBox(height: 2),
              Divider(
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildOption("Usurpation d'identité"),
                    _buildOption("Faux_compte"),
                    _buildOption("Faux_nom"),
                    _buildOption("Publication_inappropriés"),
                    _buildOption("Harcèlement_intimidation"),
                    _buildOption("Autre"),
                    SizedBox(height: 2),
                    Divider(
                      color: Colors.grey.shade300,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        "Mesures".tr,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 2),
                    ListTile(
                      leading: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                              child: FaIcon(
                            FontAwesomeIcons.ban,
                            size: 17,
                            color: Colors.black87,
                          ))),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Désactivation_compte'.tr,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "compte_desactiver".tr,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2),
                    ListTile(
                      leading: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                              child: FaIcon(
                            FontAwesomeIcons.trash,
                            size: 17,
                            color: Colors.black87,
                          ))),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suppression_compte'.tr,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "cas_violation".tr,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_selectedOption!.isNotEmpty) {
                        if (mounted) {
                          ref
                              .read(infoUserStateNotifier.notifier)
                              .signalProfile(widget.uidSignal,
                                  _selectedOption.toString(), '');
                        }
                        await Future.delayed(Duration(seconds: 1), () {});
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    child: Text(
                      "Terminer".tr,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        text.tr,
        style: TextStyle(fontSize: 16),
      ),
      leading: Radio<String>(
        value: text,
        groupValue: _selectedOption, // Valeur sélectionnée
        onChanged: (String? value) {
          setState(() {
            _selectedOption = value; // Mettre à jour la sélection
          });
        },
      ),
    );
  }
}
