import 'dart:io';
import 'dart:typed_data';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Storie/presentation/widget/StorieEditor.dart';
import 'package:natify/features/Storie/presentation/widget/textEditorPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

class Createhighlight extends ConsumerStatefulWidget {
  const Createhighlight({super.key});

  @override
  ConsumerState<Createhighlight> createState() => _GalleryPhotoState();
}

class _GalleryPhotoState extends ConsumerState<Createhighlight> {
  List<AssetEntity> assets = [];
  File? _image;
  TextEditingController titre = TextEditingController();
  List<File> selectedFiles = []; // Liste pour stocker les fichiers sélectionnés
  Set<int> selectedIndexes = {}; // Ensemble d'index sélectionnés
  AssetType? currentType; // Type de fichier actuel sélectionné

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      List<File> imageGet = [];
      imageGet.add(_image!);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StorieeditorPage(
              isStorie: false,
              isEdit: false,
              mediaFile: imageGet,
              type: 'image',
              titreCollection: titre,
              collectionId: '',
              dataActually: [],
              createdAt: 0),
        ),
      );
    }
  }

  Future<void> _requestPermissionsAndLoadAssets() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend(
            requestOption: PermissionRequestOption(
                androidPermission: AndroidPermission(
                    type: RequestType.common, mediaLocation: true)));

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
      type: RequestType.all,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
            sizeConstraint: SizeConstraint(ignoreSize: true)),
        videoOption: const FilterOption(
            sizeConstraint: SizeConstraint(ignoreSize: true)),
      ),
    );

    final List<AssetEntity> assets =
        await albums[0].getAssetListRange(start: 0, end: 300);

    setState(() {
      this.assets = assets.where((asset) {
        final type = asset.type;
        return type == AssetType.image || type == AssetType.video;
      }).toList();
    });
  }

  Future<void> _handleAssetTap(AssetEntity asset, int index) async {
    final file = await asset.file;

    if (file != null) {
      String type = asset.type == AssetType.video ? 'video' : 'image';
      // Vérifier la taille seulement pour les vidéos
      if (type == 'video') {
        const int maxSizeInMB = 90;
        const int maxSizeInBytes = maxSizeInMB * 1024 * 1024;

        if (file.lengthSync() > maxSizeInBytes) {
          showCustomSnackBar(
              "La_vidéo_dépasse"); // Affiche une alerte si la vidéo est trop lourde
          return;
        }
      }
      // Vérifier le type du fichier sélectionné
      if (currentType == null) {
        currentType =
            asset.type; // Enregistrer le type du premier fichier sélectionné
      } else if (currentType != asset.type) {
        // Si le type du fichier actuel est différent
        showCustomSnackBar(
            "Veuillez vous assurer que tous les fichiers sélectionnés sont du même type.");
        return; // Sortir de la méthode si le type est différent
      }

      setState(() {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
          removeFile(file);

          // Si la liste devient vide, réinitialiser currentType
          if (selectedFiles.isEmpty) {
            currentType = null;
          }
        } else {
          // Si l'index n'est pas sélectionné, l'ajouter à la liste
          selectedIndexes.add(index);
          selectedFiles.add(file);
        }
      });
    }
  }

  void removeFile(File file) {
    // Vérifiez que selectedFiles n'est pas nul ou vide
    if (selectedFiles.isNotEmpty) {
      // Déboguer le contenu de selectedFiles avant la suppression
      for (var f in selectedFiles) {
        print(f.path);
      }

      // Utilisez removeWhere pour supprimer le fichier
      selectedFiles.removeWhere((element) {
        // S'assurer que element n'est pas nul avant de vérifier
        print(
            "Vérification de l'élément : ${element.path} contre ${file.path}");
        return element.path == file.path; // Supprimez l'élément s'il correspond
        return false; // Ne rien supprimer si l'élément est nul
      });

      // Vérifiez si le fichier a été supprimé
      if (selectedFiles.contains(file)) {
      } else {}
    } else {}
  }

  void openTextEditorStorie() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Texteditorpage(),
      ),
    );
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
          // title: Text('HighLight'.toUpperCase(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          title: TextFormField(
            controller: titre,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Ajouter un titre'.tr,
              hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              border: InputBorder.none, // Pas de bordure
            ),
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold), // Style du texte
          ),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child:
                  Center(child: FaIcon(FontAwesomeIcons.chevronLeft, size: 20)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: FaIcon(FontAwesomeIcons.check, size: 20),
              onPressed: () {
                if (selectedFiles.isEmpty && selectedIndexes.isEmpty) {
                  showCustomSnackBar(
                      "Veuillez sélectionner un média. Merci de le renseigner pour continuer.");
                } else {
                  String type =
                      currentType == AssetType.video ? 'video' : 'image';
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StorieeditorPage(
                          isStorie: false,
                          isEdit: false,
                          mediaFile: selectedFiles,
                          type: type,
                          titreCollection: titre,
                          collectionId: '',
                          dataActually: [],
                          createdAt: 0),
                    ),
                  );
                }
              },
            )
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Racontez votre histoire à travers une image : téléchargez votre photo dès maintenant!"
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Photos et Vidéos".tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 2),
                  Container(
                    width: 70,
                    height: 2,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
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
                    onTap: () => _handleAssetTap(assets[index], index),
                    child: Stack(
                      key: ValueKey(index),
                      fit: StackFit.expand,
                      children: [
                        FutureBuilder<Uint8List?>(
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
                            return Image.memory(bytes, fit: BoxFit.cover);
                          },
                        ),
                        if (selectedIndexes
                            .contains(index)) // Affiche le check si sélectionné
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Icon(
                              Icons.check_circle,
                              color: kPrimaryColor,
                              size: 30,
                            ),
                          ),
                        if (assets[index].type == AssetType.video)
                          Center(
                            child: Icon(Icons.play_circle_fill, size: 60),
                          ),
                      ],
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
              borderRadius: BorderRadius.circular(30),
            ),
            child: FaIcon(FontAwesomeIcons.camera, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
