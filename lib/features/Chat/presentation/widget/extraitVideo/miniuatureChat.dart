import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class StoryThumbnail extends StatefulWidget {
  final String videoUrl;

  const StoryThumbnail({super.key, required this.videoUrl});

  @override
  _StoryThumbnailState createState() => _StoryThumbnailState();
}

class _StoryThumbnailState extends State<StoryThumbnail> {
  late Future<String?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = _getCachedThumbnail(widget.videoUrl);
  }

  Future<String?> _getCachedThumbnail(String videoUrl) async {
    try {
      // Utiliser DefaultCacheManager pour stocker et récupérer la miniature
      final cache = DefaultCacheManager();
      final cacheKey = 'thumbnail_${videoUrl.hashCode}';

      // Vérifier si la miniature est déjà dans le cache
      final fileInfo = await cache.getFileFromCache(cacheKey);
      if (fileInfo != null) {
        // Si elle existe, retourner le chemin du fichier
        return fileInfo.file.path;
      }

      // Sinon, générer la miniature et l'ajouter au cache
      final file = await cache.getSingleFile(videoUrl);
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: file.path,
        thumbnailPath: tempDir.path, // Sauvegarder dans le répertoire temporaire
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1400,
        quality: 75,
      );

      if (thumbnailPath != null) {
        // Stocker la miniature dans le cache
        final thumbnailFile = File(thumbnailPath);
        await cache.putFile(cacheKey, thumbnailFile.readAsBytesSync());
      }

      return thumbnailPath;
    } catch (e) {
      print('Erreur lors de la génération de la miniature: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur de chargement'));
        } else if (snapshot.hasData && snapshot.data != null) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(snapshot.data!)),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            // child: Center(
            //   child: Container(
            //     width: 50,
            //     height: 50,
            //     decoration: BoxDecoration(
            //       color: Colors.grey.shade400,
            //       borderRadius: BorderRadius.all(Radius.circular(30)),
            //     ),
            //     child: Center(
            //       child: FaIcon(FontAwesomeIcons.play, size: 20, color: Colors.white),
            //     ),
            //   ),
            // ),
          );
        } else {
          return Center(child: Text('Aucune miniature disponible'));
        }
      },
    );
  }
}
