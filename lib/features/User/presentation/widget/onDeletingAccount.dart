import 'package:natify/core/Services/AccountDeletionService.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class OndeletingAccount extends ConsumerStatefulWidget {
  const OndeletingAccount({super.key});

  @override
  ConsumerState<OndeletingAccount> createState() => _OndeletingAccountState();
}

class _OndeletingAccountState extends ConsumerState<OndeletingAccount> {
  final AccountDeletionService _deleteAccountService = AccountDeletionService();
  Future<void> _deleteAccount() async {
    try {
      await _deleteAccountService.deleteAccount(context);
    } catch (e) {
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _deleteAccount();
  }
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(infoUserStateNotifier);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Securite'.tr, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: SizedBox()
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
                            imageUrl: notifier.MydataPersiste!.profilePic == null ? '' : notifier.MydataPersiste!.profilePic.toString(),
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
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          notifier.MydataPersiste!.name == null ? '' : '${notifier.MydataPersiste!.name}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser == null ? "" : "${FirebaseAuth.instance.currentUser!.email}",
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
                        'En supprimant votre compte, les éléments suivants seront effacés de manière définitive :',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '• Vos données personnelles (nom, adresse e-mail, etc.)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        '• Vos messages et conversations',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        '• Vos paramètres et préférences',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Cette action est irréversible. Une fois votre compte supprimé, vous ne pourrez pas récupérer vos informations.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Si vous êtes sûr de vouloir continuer, cliquez sur "Supprimer mon compte".',
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: SizedBox(
                width: 15,
                height: 15,
                // margin: const EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: Colors.white,)
              )
            ),
          ),
        ],
      ),
    );
  }
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
