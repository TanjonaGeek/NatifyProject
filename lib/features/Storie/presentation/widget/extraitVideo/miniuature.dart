import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
    _thumbnailFuture = _generateThumbnail(widget.videoUrl);
  }

  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      // Téléchargement de la vidéo
      final file = await DefaultCacheManager().getSingleFile(videoUrl);
      // Génération de la miniature
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: file.path,
        thumbnailPath: file.parent.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1400, // Ajuste pour des miniatures plus grandes

        quality: 75,
      );
      return thumbnail;
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
          );
        } else {
          return Center(child: Text('Aucune miniature disponible'));
        }
      },
    );
  }
}
