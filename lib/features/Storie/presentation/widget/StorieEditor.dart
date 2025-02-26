import 'dart:io';
import 'package:natify/core/Services/NotificationService.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Storie/presentation/provider/storie_provider.dart';
import 'package:natify/features/Storie/presentation/widget/ImageAndVideoEditor/flutter_story_editor.dart';
import 'package:natify/features/Storie/presentation/widget/ImageAndVideoEditor/src/controller/controller.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class StorieeditorPage extends ConsumerStatefulWidget {
  final bool isStorie;
  final List<File>? mediaFile;
  final String type;
  final TextEditingController titreCollection;
  final bool isEdit;
  final String collectionId;
  final List dataActually;
  final int createdAt;
  const StorieeditorPage(
      {required this.isStorie,
      required this.mediaFile,
      required this.type,
      required this.titreCollection,
      required this.isEdit,
      required this.collectionId,
      required this.dataActually,
      required this.createdAt,
      super.key});

  @override
  ConsumerState<StorieeditorPage> createState() => _StorieeditorPageState();
}

class _StorieeditorPageState extends ConsumerState<StorieeditorPage>
    with SingleTickerProviderStateMixin {
  FlutterStoryEditorController controller = FlutterStoryEditorController();
  final TextEditingController _captionController = TextEditingController();
  NotificationService notificationService = NotificationService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlutterStoryEditor(
            controller: controller,
            captionController: _captionController,
            selectedFiles: widget.mediaFile,
            trimVideoOnAdjust: true,
            onSaveClickListener: (files) async {
              final notifier = ref.watch(infoUserStateNotifier);
              final List<ConnectivityResult> connectivityResult =
                  await (Connectivity().checkConnectivity());
              if (widget.isStorie == true && widget.isEdit == false) {
                if (connectivityResult.contains(ConnectivityResult.none)) {
                  showCustomSnackBar("Pas de connexion internet");
                  return;
                }
                if (mounted) {
                  String message = "Votre story a été créée avec succès.".tr;
                  UserModel? myCurrentData = notifier.MydataPersiste;
                  ref
                      .read(storieStateNotifier.notifier)
                      .CreateStory(files, widget.type)
                      .then((onValue) async {
                    notificationService.sendNotification(
                        myCurrentData!, message, myCurrentData.name.toString());
                  });
                }
                Navigator.pop(context);
              } else if (widget.isStorie == false && widget.isEdit == true) {
                if (connectivityResult.contains(ConnectivityResult.none)) {
                  showCustomSnackBar("Pas de connexion internet");
                  return;
                }
                if (mounted) {
                  UserModel? myCurrentData = notifier.MydataPersiste;
                  ref.read(infoUserStateNotifier.notifier).editerHighLigth(
                      files,
                      myCurrentData!.profilePic.toString(),
                      widget.titreCollection.text.toString(),
                      widget.collectionId,
                      widget.dataActually,
                      widget.createdAt,
                      context);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                if (connectivityResult.contains(ConnectivityResult.none)) {
                  showCustomSnackBar("Pas de connexion internet");
                  return;
                }
                if (mounted) {
                  UserModel? myCurrentData = notifier.MydataPersiste;
                  ref.read(infoUserStateNotifier.notifier).createHighLigth(
                      files,
                      widget.titreCollection.text.toString(),
                      myCurrentData!.profilePic.toString(),
                      widget.type,
                      context);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              }
            }));
  }
}
