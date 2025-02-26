import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

class Imagegallery extends StatefulWidget {
  const Imagegallery({super.key});

  @override
  State<Imagegallery> createState() => _ImagegalleryState();
}

class _ImagegalleryState extends State<Imagegallery> {
  List<AssetEntity> assets = [];
  Future<void> _fetchAssets() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      // Utiliser RequestType.image pour ne récupérer que les images
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
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
        // Ne garder que les images
        this.assets =
            assets.where((asset) => asset.type == AssetType.image).toList();
      });
    } else {
      // Les permissions n'ont pas été accordées
      PhotoManager.openSetting();
    }
  }

  Future<void> _handleAssetTap(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      Navigator.pop(context, file);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery photo'.tr.toUpperCase(),
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
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                return GestureDetector(
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
                        fit: StackFit.expand,
                        children: [
                          Image.memory(bytes, fit: BoxFit.cover),
                          if (assets[index].type == AssetType.video)
                            Center(
                              child: Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 60),
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
    );
  }
}
