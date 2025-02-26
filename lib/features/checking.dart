import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/widget/loading.dart';
import 'package:natify/features/HomeScreen.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/info/fill/IsFillSexePage.dart';
import 'package:natify/features/User/presentation/widget/info/fill/isFillAgePage.dart';
import 'package:natify/features/User/presentation/widget/info/fill/isFillNationalitePage.dart';
import 'package:natify/features/User/presentation/widget/info/fill/isFillPaysPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Cheking extends ConsumerStatefulWidget {
  const Cheking({super.key});

  @override
  ConsumerState<Cheking> createState() => _ChekingState();
}

class _ChekingState extends ConsumerState<Cheking> {
  String tokenReload = "";
  String _appVersion = "";

  // Récupérer la version locale
  Future<void> _getLocalVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

  // Récupérer les versions valides depuis Firestore
  Stream<List<String>> _getVersionStream() {
    return FirebaseFirestore.instance
        .collection('app_version')
        .snapshots()
        .map((snapshot) {
      List<String> allVersions = [];
      for (var doc in snapshot.docs) {
        // Si le champ 'Version' est une liste, on l'ajoute à notre liste allVersions
        if (doc['Version'] is List) {
          allVersions.addAll(List<String>.from(doc['Version']));
        } else {
          allVersions.add(doc['Version'].toString());
        }
      }
      return allVersions;
    });
  }

  Widget erroPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              width: 100,
              height: 100,
              child: Image.asset('assets/warning.png',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer."
                  .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              var signalId = const Uuid().v1();
              setState(() {
                tokenReload = signalId;
              });
            },
            child: Column(
              children: [
                Text(
                  "Réessayer".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: kPrimaryColor),
                ),
                SizedBox(
                  height: 2,
                ),
                Container(
                  width: 30,
                  height: 2,
                  decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getLocalVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<List<String>>(
      stream: _getVersionStream(),
      builder: (context, versionSnapshot) {
        if (versionSnapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        } else if (versionSnapshot.hasError) {
          return Center(child: Text('Erreur : ${versionSnapshot.error}'));
        } else if (versionSnapshot.hasData) {
          final validVersions = versionSnapshot.data!;
          if (validVersions.contains(_appVersion)) {
            // La version locale est valide
            return Scaffold(
              body: FutureBuilder(
                key: ValueKey(tokenReload),
                future: ref.read(infoUserStateNotifier.notifier).isFilled(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Loading();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    if (snapshot.data == "FillCompleted") {
                      return HomeScreen(index: 0);
                    } else if (snapshot.data == "FillPageSexe") {
                      return Isfillsexepage();
                    } else if (snapshot.data == "FillPageAge") {
                      return Isfillagepage();
                    } else if (snapshot.data == "FillPageNationalite") {
                      return Isfillnationalitepage();
                    } else if (snapshot.data == "FillPagePays") {
                      return Isfillpayspage();
                    } else {
                      return erroPage();
                    }
                  } else {
                    return Center(child: Text('Aucun résultat trouvé.'));
                  }
                },
              ),
            );
          } else {
            // La version est obsolète
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.asset('assets/update.png',
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Version_obsolete".tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'message_version_obselete'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    GestureDetector(
                      onTap: () {
                        print('mise a jour terminer');
                      },
                      child: Column(
                        children: [
                          Text(
                            "Mettre à jour".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: kPrimaryColor),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Container(
                            width: 30,
                            height: 2,
                            decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          return Center(child: Text('Impossible de récupérer les données.'));
        }
      },
    ));
  }
}
