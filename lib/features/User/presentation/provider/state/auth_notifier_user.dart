import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:natify/core/Services/emailService.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSignIn.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSignUp.dart';
import 'package:natify/features/User/presentation/provider/state/auth_state_user.dart';
import 'package:natify/features/checking.dart';
import 'package:natify/injector.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final UseCaseSignIn _signInUseCase = injector.get<UseCaseSignIn>();
  final UseCaseSignUp _signUpUseCase = injector.get<UseCaseSignUp>();
  Timer? _debounce;

  AuthNotifier() : super(const AuthState.initial());

  bool get isFetching => state.state != AuthConcreteState.loading;

  Future<void> signInOrSignUp(BuildContext context) async {
    final emailService = EmailService();
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    try {
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print("Pas de connexion Internet.");
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      // Annuler le debounce si actif
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      // Démarrer la connexion Google
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Vérification si l'utilisateur Google est valide
      if (googleUser == null) {
        print(
            'Erreur : L\'utilisateur Google est nul ou l\'utilisateur a annulé la connexion.');
        return;
      }

      // Authentification Google
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      // Mise à jour de l'état si nécessaire
      if (isFetching) {
        // Utilisation du debounce pour temporiser l'exécution
        _debounce = Timer(const Duration(milliseconds: 100), () async {
          try {
            // Création des credentials pour Firebase
            AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            UserCredential? userCredential;
            try {
              userCredential =
                  await FirebaseAuth.instance.signInWithCredential(credential);
              await storeInfoAfetLogin(context);
            } catch (e) {
              if (FirebaseAuth.instance.currentUser != null) {
                storeInfoAfetLogin(context);
              } else {
                // showCustomSnackBar(
                //     "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
                // return;
              }
            }
          } catch (e) {
            if (FirebaseAuth.instance.currentUser != null) {
              storeInfoAfetLogin(context);
            } else {
              // showCustomSnackBar(
              //     "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
              // return;
            }
          }
        });
      }
    } catch (e) {
      if (FirebaseAuth.instance.currentUser != null) {
        storeInfoAfetLogin(context);
      } else {
        // showCustomSnackBar(
        //     "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
        // return;
      }
    }
  }

  Future<void> signOut(bool status) async {
    state = state.copyWith(
      isLogout: status,
    );
  }

  Future<bool> checkIfUserIsNew(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return !doc
        .exists; // Si le document n'existe pas, c'est un nouvel utilisateur
  }

  Future<void> storeInfoAfetLogin(BuildContext context) async {
    final emailService = EmailService();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String? email = FirebaseAuth.instance.currentUser!.email;
    String? name = FirebaseAuth.instance.currentUser!.displayName;
    String? photoURL = FirebaseAuth.instance.currentUser!.photoURL;
    bool isNewUser = await checkIfUserIsNew(uid);
    if (isNewUser) {
      showCustomSnackBar("connexion_en_cours");
      await _signUpUseCase
          .call(uid.toString(), name.toString(), photoURL.toString())
          .then((onValue) async {
        await emailService.sendLoginNotification(
            email.toString(), name.toString(), context);
        SlideNavigation.slideToPagePushRemplacement(context, Cheking());
      });
    } else {
      showCustomSnackBar("connexion_en_cours");
      await _signInUseCase.call(uid).then((onValue) async {
        await emailService.sendLoginNotification(
            email.toString(), name.toString(), context);
        SlideNavigation.slideToPagePushRemplacement(context, Cheking());
      });
    }
  }
}
