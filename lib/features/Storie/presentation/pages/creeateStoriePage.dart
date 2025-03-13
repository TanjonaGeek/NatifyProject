import 'dart:io';
import 'dart:typed_data';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Storie/domaine/entities/storie_entities.dart';
import 'package:natify/features/Storie/presentation/widget/StorieEditor.dart';
import 'package:natify/features/Storie/presentation/widget/textEditorPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<AssetEntity> assets = [];
  File? _image;
  TextEditingController notitre = TextEditingController();

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      List<File> imageGet = [];
      imageGet.add(_image!);
      SlideNavigation.slideToPage(
          context,
          StorieeditorPage(
            isStorie: true,
            isEdit: false,
            mediaFile: imageGet,
            type: 'image',
            titreCollection: notitre,
            collectionId: '',
            dataActually: [],
            createdAt: 0,
          ));
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
      type: RequestType
          .all, // Changer RequestType.image en RequestType.all pour inclure vidéos
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        videoOption: const FilterOption(
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
        return type == AssetType.image || type == AssetType.video;
      }).toList();
    });
  }

  Future<void> _handleAssetTap(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      String type = asset.type == AssetType.video ? 'video' : 'image';
      // Vérifier la taille seulement pour les vidéos
      if (type == 'video') {
        const int maxSizeInMB = 90;
        const int maxSizeInBytes = maxSizeInMB * 1024 * 1024;

        if (file.lengthSync() > maxSizeInBytes) {
          showCustomSnackBar(
              "La vidéo dépasse 90 Mo. Choisissez-en une plus légère"); // Affiche une alerte si la vidéo est trop lourde
          return;
        }
      }
      SlideNavigation.slideToPage(
          context,
          StorieeditorPage(
            isStorie: true,
            isEdit: false,
            mediaFile: [file],
            type: type,
            titreCollection: notitre,
            collectionId: '',
            dataActually: [],
            createdAt: 0,
          ));
    }
  }

  void openTextEditorStorie() {
    SlideNavigation.slideToPage(context, Texteditorpage());
  }

  Future<List<StorieEntity>> fetchYourStoryStream() async {
    // Calcul de la limite de temps (24 heures en arrière)
    final cutoffTime =
        DateTime.now().subtract(Duration(hours: 24)).millisecondsSinceEpoch;

    // Effectuer la requête Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection('status')
        .where('uid',
            isEqualTo: FirebaseAuth.instance.currentUser!
                .uid) // Assurez-vous de vérifier que currentUser n'est pas null
        .where('createdAt', isGreaterThanOrEqualTo: cutoffTime)
        .get(); // Remplacé snapshots() par get() pour un appel direct

    // Convertir les documents en objets StorieEntity
    return querySnapshot.docs.map((doc) {
      final data = doc.data(); // Récupérer les données du document

      return StorieEntity(
        uid: data['uid']
            as String?, // Assurez-vous que ces champs existent et correspondent aux types
        username: data['username'] as String?,
        photoUrl: (data['photoUrl'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList(),
        createdAt: data['createdAt'] as int?,
        profilePic: data['profilePic'] as String?,
        statusId: data['statusId'] as String?,
        QuivoirStorie: (data['QuivoirStorie'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList(),
        storyAvailableForUser: data['storyAvailableForUser'] != null
            ? List<String>.from(data['storyAvailableForUser'] as List<dynamic>)
            : [],
      );
    }).toList();
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
          title: Text('Créez des Story'.tr,
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
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  // Flexible(
                  //   child: _buildOptionCard(
                  //     icon: FaIcon(FontAwesomeIcons.camera, size: 30, color: kPrimaryColor),
                  //     label: 'Camera'.tr,
                  //     onTap: _pickImageFromCamera,
                  //   ),
                  // ),
                  Flexible(
                    child: _buildOptionCard(
                      icon: SizedBox(
                          width: 70,
                          height: 70,
                          child: Image.asset(
                            'assets/police-de-caractere.png',
                            color: Colors.white,
                          )),
                      onTap: openTextEditorStorie,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: _buildOptionCard(
                      icon: SizedBox(
                          width: 70,
                          height: 70,
                          child: Image.asset(
                            'assets/camera.png',
                            color: Colors.white,
                          )),
                      onTap: () {
                        _pickImageFromCamera();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Collection de photos et vidéos".tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () => _handleAssetTap(assets[index]),
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
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          border: Border.all(
                                              color: Colors.grey.shade100,
                                              width: 1), // Add border here
                                        ),
                                      ),
                                    );
                                  }
                                  // Afficher un indicateur pour les vidéos
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(bytes, fit: BoxFit.cover),
                                      if (assets[index].type == AssetType.video)
                                        Center(
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          )));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({required Widget icon, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[newColorBlueElevate, newColorGreenDarkElevate],
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
          ],
        ),
      ),
    );
  }
}
