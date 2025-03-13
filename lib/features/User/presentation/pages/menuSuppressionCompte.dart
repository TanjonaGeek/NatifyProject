import 'package:natify/core/Services/AccountDeletionService.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ParametreSecurite extends ConsumerStatefulWidget {
  const ParametreSecurite({super.key});

  @override
  ConsumerState<ParametreSecurite> createState() => _ParametreSecuriteState();
}

class _ParametreSecuriteState extends ConsumerState<ParametreSecurite> {
  final AccountDeletionService _deleteAccountService = AccountDeletionService();
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(infoUserStateNotifier);
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Securite'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
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
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  // Profile Picture and Name
                  Center(
                    child: Column(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:
                                notifier.MydataPersiste!.profilePic == null
                                    ? ''
                                    : notifier.MydataPersiste!.profilePic
                                        .toString(),
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
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "En supprimant votre compte, les éléments suivants seront effacés de manière définitive :"
                            .tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "• Vos données personnelles (nom, adresse e-mail, etc.)"
                            .tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        "• Vos messages et conversations".tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        "• Vos paramètres et préférences".tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Cette action est irréversible. Une fois votre compte supprimé, vous ne pourrez pas récupérer vos informations."
                            .tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Si vous êtes sûr de vouloir continuer, cliquez sur 'Supprimer mon compte'."
                            .tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Button to delete account
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: () {
                // Action to delete the account
                Get.dialog(
                  AlertDialog(
                    // backgroundColor: Colors.white,
                    title: Text(
                      "confirmation".tr,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                        "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible."
                            .tr),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text("annuler".tr),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteAccount();
                        },
                        child: Text("supprimer".tr),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text(
                textAlign: TextAlign.center,
                "Supprimer mon compte".tr,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print("Pas de connexion Internet.");
        showCustomSnackBar("Pas de connexion Internet.");
        return;
      }
      await _deleteAccountService.deleteAccount(ref, context);
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
