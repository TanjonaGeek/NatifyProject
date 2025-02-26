import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

class VideoStoryPlayer extends StatefulWidget {
  final String videoUrl;

  const VideoStoryPlayer({super.key, required this.videoUrl});

  @override
  _VideoStoryPlayerState createState() => _VideoStoryPlayerState();
}

class _VideoStoryPlayerState extends State<VideoStoryPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      File? videoFile;

      // Check if the video is already cached
      final fileInfo =
          await DefaultCacheManager().getFileFromCache(widget.videoUrl);

      if (fileInfo != null && fileInfo.file.existsSync()) {
        videoFile = fileInfo.file;
      } else {
        // Download the video and cache it
        final file = await DefaultCacheManager().getSingleFile(widget.videoUrl);
        videoFile = file;
      }

      _videoPlayerController = VideoPlayerController.file(videoFile);

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        showOptions: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowMuting: false,
        allowFullScreen: true,
        customControls: const MaterialControls(),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading video: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CupertinoActivityIndicator(color: Colors.white))
        : Chewie(controller: _chewieController!);
  }
}
