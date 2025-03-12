import 'dart:io';
import 'dart:typed_data';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

class Imagegallery extends ConsumerStatefulWidget {
  const Imagegallery({super.key});

  @override
  ConsumerState<Imagegallery> createState() => _ImagegalleryState();
}

class _ImagegalleryState extends ConsumerState<Imagegallery> {
  List<AssetEntity> assets = [];
  File? _image;
  int? selectedIndex;
  List<File> selectedFiles = [];
  AssetType? currentType;
  bool showSendButton = false;

  Future<void> _requestPermissionsAndLoadAssets() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend(
            requestOption: PermissionRequestOption(
                androidPermission: AndroidPermission(
                    type: RequestType.image, mediaLocation: true)));

    if (permission == PermissionState.authorized) {
      // Autorisation complète
      await _fetchAssets();
    } else if (permission == PermissionState.limited) {
      // Accès limité
      await PhotoManager.presentLimited();
      await _fetchAssets();
    } else {
      // Permission refusée
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Permission refusée. Impossible d'accéder aux médias.")),
      );
    }
  }

  Future<void> _fetchAssets() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType
          .common, // Changer RequestType.image en RequestType.all pour inclure vidéos
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      ),
    );

    // Sélectionne le premier album (qui est normalement le "Recent")
    final List<AssetEntity> assets =
        await albums[0].getAssetListRange(start: 0, end: 300);

    setState(() {
      this.assets = assets.where((asset) {
        final type = asset.type;
        return type == AssetType.image;
      }).toList();
    });
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Navigator.pop(context, _image);
    }
  }

  Future<void> _handleAssetTap(AssetEntity asset, int index) async {
    final file = await asset.file;

    if (file != null) {
      // setState(() {
      //   if (selectedIndex == index) {
      //     // Désélectionner si déjà sélectionné
      //     selectedIndex = null;
      //     selectedFiles.clear();
      //     currentType = null;
      //     showSendButton = false;
      //   } else {
      //     // Sélectionner un nouvel élément
      //     selectedIndex = index;
      //     selectedFiles = [file];
      //     currentType = asset.type;
      //     showSendButton = true;
      //   }
      // });
      Navigator.pop(context, file);
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadAssets();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gallery photo'.tr,
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
          actions: [],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Explorez votre galerie et sélectionnez une image à utiliser ou vous souhaitez partager dans notre application."
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                ),
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    key: ValueKey(index),
                    onTap: () {
                      _handleAssetTap(assets[index], index);
                    },
                    child: FutureBuilder<Uint8List?>(
                      future: assets[index].thumbnailData,
                      builder: (_, snapshot) {
                        final bytes = snapshot.data;
                        if (bytes == null) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              decoration: BoxDecoration(
                                // color: Colors.grey[200], // Background color to show shimmer effect
                                borderRadius: BorderRadius.circular(1),
                                border: Border.all(
                                    color: Colors.grey.shade100,
                                    width: 1), // Add border here
                              ),
                            ),
                          );
                        }

                        // Afficher un indicateur pour les vidéos
                        return Stack(
                          key: ValueKey(index),
                          fit: StackFit.expand,
                          children: [
                            Image.memory(bytes, fit: BoxFit.cover),
                            if (assets[index].type == AssetType.video)
                              Center(
                                child: Icon(Icons.play_circle_fill,
                                    color: Colors.white, size: 60),
                              ),
                            if (selectedIndex ==
                                index) // Affiche l'icône si sélectionné
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            onPressed: _pickImageFromCamera,
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: FaIcon(FontAwesomeIcons.camera, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
