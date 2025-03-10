import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/pages/menuSuppressionCompte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:natify/features/User/presentation/widget/list/listUserBlock.dart';

class SousMenuSupprimer extends ConsumerWidget {
  const SousMenuSupprimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThemeSwitchingArea(
      child: Scaffold(
        // backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text('Securite'.tr,
              style: TextStyle(fontWeight: FontWeight.bold)),
          // backgroundColor: Colors.white,
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              SizedBox(height: 10),
              _buildMenuItem(
                  context: context,
                  icon: Icons.lock,
                  text: 'Supprimer mon compte',
                  iconColor: kPrimaryColor,
                  onTap: () {
                    SlideNavigation.slideToPage(context, ParametreSecurite());
                  }),
              // _buildMenuItem(
              //   icon: Icons.notifications,
              //   text: 'Notifications',
              //   onTap: (){}
              // ),
              _buildMenuItem(
                  context: context,
                  icon: Icons.person,
                  text: 'Amies_Bloqués',
                  iconColor: kPrimaryColor,
                  onTap: () {
                    SlideNavigation.slideToPage(
                        context,
                        AllUserBlockedByme(
                            uid: FirebaseAuth.instance.currentUser?.uid ?? ""));
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    Color? iconColor, // La couleur sera optionnelle pour être flexible
    required VoidCallback onTap,
    required BuildContext context, // Ajout du context pour accéder au thème
  }) {
    // Récupérer les couleurs dynamiquement depuis le thème
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor; // Couleur de fond
    final shadowColor = theme.brightness == Brightness.light
        ? Colors.grey.shade200
        : Colors.black26; // Couleur des ombres
    final textColor = theme.textTheme.bodyMedium?.color; // Couleur du texte
    final effectiveIconColor =
        iconColor ?? theme.iconTheme.color; // Couleur des icônes

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor, // Fond selon le thème
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor, // Ombres selon le thème
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  effectiveIconColor?.withOpacity(0.2), // Cercle avec opacité
              child: Icon(icon,
                  color: effectiveIconColor), // Icône avec couleur dynamique
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text.tr, // Utilisation de la traduction si nécessaire
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor, // Texte avec couleur dynamique
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16), // Flèche
          ],
        ),
      ),
    );
  }
}
