import 'dart:io';
import 'dart:typed_data';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Storie/presentation/widget/StorieEditor.dart';
import 'package:natify/features/Storie/presentation/widget/textEditorPage.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

class Editerhighlight extends ConsumerStatefulWidget {
  final AssetType? type; // Paramètre pour spécifier le type (photo ou vidéo)
  final TextEditingController title;
  final List dataActually;
  final String collectionId;
  final int createdAt;
  const Editerhighlight(
      {required this.type,
      required this.title,
      required this.dataActually,
      required this.collectionId,
      required this.createdAt,
      super.key});
  @override
  ConsumerState<Editerhighlight> createState() => _EditerhighlightState();
}

class _EditerhighlightState extends ConsumerState<Editerhighlight> {
  List<AssetEntity> assets = [];
  File? _image;
  late TextEditingController titre = TextEditingController();
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
            isEdit: true,
            mediaFile: imageGet,
            type: 'image',
            titreCollection: titre,
            collectionId: widget.collectionId,
            dataActually: widget.dataActually,
            createdAt: widget.createdAt,
          ),
        ),
      );
    }
  }

  Future<void> _fetchAssets() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
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
        // Filtrer les actifs en fonction du type spécifié (photo ou vidéo)
        this.assets = assets.where((asset) {
          if (widget.type == null) {
            return asset.type == AssetType.image ||
                asset.type == AssetType.video;
          } else {
            return asset.type ==
                widget.type; // Affiche uniquement le type spécifié
          }
        }).toList();
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<void> _handleAssetTap(AssetEntity asset, int index) async {
    final file = await asset.file;

    if (file != null) {
      // Vérifier le type du fichier sélectionné
      if (currentType == null) {
        currentType =
            asset.type; // Enregistrer le type du premier fichier sélectionné
      } else if (currentType != asset.type) {
        // Si le type du fichier actuel est différent
        showCustomSnackBar(
            "Veuillez vous assurer que tous les fichiers sélectionnés sont du même type.");
        return;
      }

      setState(() {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
          removeFile(file);

          // Si la liste devient vide, réinitialiser currentType
          if (selectedFiles.isEmpty) {
            print(
                "Réinitialisation de currentType car selectedFiles est vide.");
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
      print("Contenu de selectedFiles avant la suppression :");
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
        print("Le fichier à désélectionner n'a pas été trouvé.");
      } else {
        print("Le fichier à désélectionner a été supprimé.");
      }
    } else {
      print("selectedFiles est nul ou vide.");
    }
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
    setState(() {
      titre = widget.title;
    });
    _fetchAssets();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(infoUserStateNotifier);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        // title: Text('HighLight'.toUpperCase(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        title: TextFormField(
          controller: titre,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Ajouter un titre'.tr,
            hintStyle: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            border: InputBorder.none, // Pas de bordure
          ),
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold), // Style du texte
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Center(
                child: FaIcon(FontAwesomeIcons.chevronLeft,
                    size: 20, color: Colors.black)),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.check, size: 20, color: Colors.black),
            onPressed: () {
              // selectedFiles.isNotEmpty && selectedIndexes.isNotEmpty
              if (selectedFiles.isEmpty && selectedIndexes.isEmpty) {
                if (mounted) {
                  UserModel? myCurrentData = notifier.MydataPersiste;
                  ref.read(infoUserStateNotifier.notifier).editerHighLigth([],
                      myCurrentData!.profilePic.toString(),
                      titre.text.toString(),
                      widget.collectionId,
                      widget.dataActually,
                      widget.createdAt,
                      context);
                }
                Navigator.pop(context);
              } else if (selectedFiles.isNotEmpty &&
                  selectedIndexes.isNotEmpty) {
                String type =
                    currentType == AssetType.video ? 'video' : 'image';
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StorieeditorPage(
                      isStorie: false,
                      isEdit: true,
                      mediaFile: selectedFiles,
                      type: type,
                      titreCollection: titre,
                      collectionId: widget.collectionId,
                      dataActually: widget.dataActually,
                      createdAt: widget.createdAt,
                    ),
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
                color: Colors.black54,
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
                          child: Icon(Icons.play_circle_fill,
                              color: Colors.white, size: 60),
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
    );
  }
}
