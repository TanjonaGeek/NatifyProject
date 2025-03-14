import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/langues/langueController.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/pages/langues.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:natify/features/User/presentation/pages/politiqueConfidentialite.dart';
import 'package:natify/features/User/presentation/pages/politiqueUtilisation.dart';
import 'package:natify/features/User/presentation/pages/termsCondition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUserPage extends ConsumerStatefulWidget {
  const AuthUserPage({super.key});

  @override
  _AuthUserPageState createState() => _AuthUserPageState();
}

class _AuthUserPageState extends ConsumerState<AuthUserPage> {
  bool _isAccepted = false;
  bool _isAcceptedUpdate = false;
  final languageController = Get.find<LanguageController>();
  @override
  void initState() {
    super.initState();
    _checkAcceptance();
  }

  // Vérifier si les conditions ont déjà été acceptées
  Future<void> _checkAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAccepted = prefs.getBool('termsAccepted') ?? false;
      _isAcceptedUpdate = prefs.getBool('termsAccepted') ?? false;
    });
  }

  // Enregistrer l'acceptation
  Future<void> _acceptTerms(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('termsAccepted', value);
    setState(() {
      _isAccepted = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    String decouvrer = "Des Nouveaux Amis Partout Où Vous Allez".tr;
    String avec = "avec".tr;
    String faciliter = "Facilite la recherche d'amis".tr;
    String connecter = "Se connecter avec Google".tr;
    String jaccepter = "J'accepte les conditions d'utilisation".tr;
    String utilisant = "En utilisant cette application, vous acceptez nos".tr;
    String notre = ", notre".tr;
    String ainsi = "ainsi que notre".tr;
    String langue = "Langues".tr;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 150,
            right: 10,
            left: 10,
            child: Image.asset(
              'assets/landingPage2Union.png',
              // fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            left: 20,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 350, // Hauteur max, ajuste selon ton design
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "$decouvrer $avec",
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' Natify',
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                    textScaler:
                        TextScaler.noScaling, // Empêche la mise à l'échelle
                  ),
                  Text(
                    faciliter,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                    textScaler:
                        TextScaler.noScaling, // Empêche la mise à l'échelle
                  ),
                  if (_isAccepted == true) SizedBox(height: 40),
                  if (_isAccepted == true)
                    ElevatedButton.icon(
                      icon: FaIcon(
                        FontAwesomeIcons.google,
                        size: 20,
                        color: Colors.red,
                      ),
                      label: Text(
                        connecter,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _isAccepted
                          ? () {
                              ref
                                  .read(userAuthStateNotifier.notifier)
                                  .signInOrSignUp(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  SizedBox(height: 1),
                  if (_isAcceptedUpdate == false && _isAccepted == false)
                    Row(
                      children: [
                        Checkbox(
                          value: _isAccepted,
                          onChanged: (value) {
                            _acceptTerms(value!);
                          },
                          checkColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          activeColor: kPrimaryColor,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Logique pour ouvrir les conditions d'utilisation
                            },
                            child: Text(
                              jaccepter,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 16,
                              ),
                              textScaler: TextScaler
                                  .noScaling, // Empêche la mise à l'échelle
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_isAcceptedUpdate == false && _isAccepted == false)
                    Padding(
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14),
                          children: [
                            TextSpan(text: utilisant),
                            TextSpan(
                              text: "Conditions d'utilisation".tr,
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  SlideNavigation.slideToPage(context,
                                      TermeCondition()); // Navigue vers la page Conditions d'utilisation
                                },
                            ),
                            TextSpan(text: notre),
                            TextSpan(
                              text: "Politique de confidentialité".tr,
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  SlideNavigation.slideToPage(context,
                                      PolitiqueConfidentialite()); // Navigue vers la page Politique de confidentialité
                                },
                            ),
                            TextSpan(text: ainsi),
                            TextSpan(
                              text:
                                  "Politique d'utilisation acceptable de Natify"
                                      .tr,
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  SlideNavigation.slideToPage(context,
                                      PolitiqueUtilisation()); // Navigue vers la page Politique d'utilisation acceptable
                                },
                            ),
                            TextSpan(text: "."),
                          ],
                        ),
                        textScaler:
                            TextScaler.noScaling, // Empêche la mise à l'échelle
                      ),
                    ),
                ],
              ),
            ),
          ),
          Obx(() {
            return Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  SlideNavigation.slideToPage(context, Langues());
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
                  child: Text(
                    '$langue - ${Helpers.countryCodeToEmoji(languageController.currentLocale.value.countryCode.toString())}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                    textScaler: TextScaler.noScaling,
                  ),
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
