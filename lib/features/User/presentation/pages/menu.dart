import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/core/utils/widget/show_loading_dialog.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:natify/features/Storie/presentation/provider/storie_provider.dart';
import 'package:natify/features/User/presentation/pages/auth/AuthUserPage.dart';
import 'package:natify/features/User/presentation/pages/langues.dart';
import 'package:natify/features/User/presentation/pages/parametre.dart';
import 'package:natify/features/User/presentation/pages/politiqueConfidentialite.dart';
import 'package:natify/features/User/presentation/pages/politiqueUtilisation.dart';
import 'package:natify/features/User/presentation/pages/sous-menu-supprimer.dart';
import 'package:natify/features/User/presentation/pages/termsCondition.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Menu extends ConsumerWidget {
  const Menu({super.key});

  Future<void> signOut(WidgetRef ref, BuildContext context) async {
    try {
      String uidUser = FirebaseAuth.instance.currentUser!.uid;
      // Vérification de la connectivité
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion Internet.");
        return;
      }
      // Vérification si l'utilisateur est connecté via Google
      if (FirebaseAuth.instance.currentUser?.providerData[0].providerId ==
          "google.com") {
        showLoadingDialog(context: context, message: 'deconnexion_en_cours');

        // Mise à jour de l'état de l'utilisateur (si nécessaire)
        // ref.read(authControllerProvider).setUserState(false);
        // ZegoUIKitPrebuiltCallInvitationService().uninit();
        ref.read(userAuthStateNotifier.notifier).signOut(true);
        // Déconnexion de Firebase et Google Sign-In, en attente de leur fin
        await Future.wait([
          FirebaseAuth.instance.signOut(),
          GoogleSignIn().signOut(),
        ]).then((value) {
          ref
              .read(infoUserStateNotifier.notifier)
              .updateStatusUser(false, uidUser);
        });
        // Ajout d'un délai pour améliorer la fluidité de l'expérience utilisateur
        await Future.delayed(const Duration(milliseconds: 1000));
        // Remettre à jour l'état de déconnexion dans le StateNotifier
        ref.read(userAuthStateNotifier.notifier).signOut(false);
        // Naviguer après la déconnexion
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthUserPage()),
          (Route<dynamic> route) => false,
        );

        // Après navigation, invalider les Providers
        WidgetsBinding.instance.addPostFrameCallback((_) {
          invalidateAllProviders(ref);
        });
        print("Déconnexion réussie.");
      }
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  void invalidateAllProviders(WidgetRef ref) {
    ref.invalidate(chatStateNotifier);
    ref.invalidate(userAuthStateNotifier);
    ref.invalidate(allUserListStateNotifier);
    ref.invalidate(infoUserStateNotifier);
    ref.invalidate(mapsUserStateNotifier);
    ref.invalidate(storieStateNotifier);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(infoUserStateNotifier);
    return ThemeSwitchingArea(
      child: Scaffold(
        // backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text('Menu'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
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
              // Profile Picture and Name
              Center(
                child: Column(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: notifier.MydataPersiste!.profilePic == null
                            ? ''
                            : notifier.MydataPersiste!.profilePic.toString(),
                        placeholder: (context, url) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 100,
                              height: 100,
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
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      notifier.MydataPersiste!.name == null
                          ? ''
                          : '${notifier.MydataPersiste!.name}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser == null
                          ? ""
                          : "${FirebaseAuth.instance.currentUser!.email}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Menu Items
              // _buildMenuItem(
              //   icon: Icons.person,
              //   text: 'Mon profile',
              //   onTap: (){
              //     Navigator.of(context, rootNavigator: true).push(
              //     MaterialPageRoute(
              //       builder: (context) => UserProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
              //       ),
              //     );
              //   }
              // ),
              _buildMenuItem(
                  context: context,
                  icon: Icons.lock,
                  text: 'Securite',
                  iconColor: kPrimaryColor,
                  onTap: () {
                    SlideNavigation.slideToPage(context, SousMenuSupprimer());
                  }),
              // _buildMenuItem(
              //   icon: Icons.notifications,
              //   text: 'Notifications',
              //   onTap: (){}
              // ),
              _buildMenuItem(
                  context: context,
                  icon: Icons.settings,
                  text: 'Parametre',
                  iconColor: kPrimaryColor,
                  onTap: () {
                    SlideNavigation.slideToPage(context, Parametre());
                  }),
              _buildMenuItem(
                  context: context,
                  icon: Icons.language,
                  text: 'Langues',
                  iconColor: kPrimaryColor,
                  onTap: () {
                    SlideNavigation.slideToPage(context, Langues());
                  }),
              _buildMenuItem(
                  context: context,
                  icon: Icons.article,
                  text: "Conditions d'utilisation",
                  iconColor: kPrimaryColor,
                  onTap: () {
                    SlideNavigation.slideToPage(context, TermeCondition());
                  }),
              _buildMenuItem(
                  context: context,
                  icon: Icons.article,
                  text: "Politique de confidentialité",
                  iconColor: kPrimaryColor,
                  onTap: () {
                    SlideNavigation.slideToPage(
                        context, PolitiqueConfidentialite());
                  }),
              _buildMenuItem(
                  context: context,
                  icon: Icons.article,
                  iconColor: kPrimaryColor,
                  text: "Politique d'utilisation acceptable de Natify",
                  onTap: () {
                    SlideNavigation.slideToPage(
                        context, PolitiqueUtilisation());
                  }),
              _buildMenuItem(
                  context: context,
                  icon: Icons.logout,
                  text: 'Deconnexion',
                  iconColor: kPrimaryColor,
                  onTap: () => signOut(ref, context)),
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
