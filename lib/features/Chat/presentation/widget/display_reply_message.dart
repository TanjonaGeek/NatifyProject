import 'package:cached_network_image/cached_network_image.dart';
import 'package:natify/core/Services/downloadService.dart';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/presentation/widget/extraitVideo/miniuatureChat.dart';
import 'package:natify/features/Chat/presentation/widget/videoPlayer/videoPlayer.dart';
import 'package:natify/features/Chat/presentation/widget/voiceMessage/voice_controller.dart';
import 'package:natify/features/Chat/presentation/widget/voiceMessage/voice_message_view.dart';
import 'package:flutter/material.dart';

class DisplayReplyMessage extends StatelessWidget {
  final String message;
  final String check;
  final MessageEnum type;
  const DisplayReplyMessage({
    super.key,
    required this.message,
    required this.type,
    required this.check,
  });

  @override
  Widget build(BuildContext context) {
    return type == MessageEnum.text
        ? Text(
            message,
            style: TextStyle(
                fontSize: 13,
                color: check == "me" ? Colors.black : Colors.white,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none),
          )
        : type == MessageEnum.audio
            ? SizedBox(
                width: 250,
                height: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  //  child: Text('dfdffdfdfd')
                  child: Material(
                    color: Colors.transparent,
                    child: VoiceMessageView(
                      controller: VoiceController(
                        audioSrc: message,
                        maxDuration: const Duration(seconds: 10),
                        isFile: false,
                        onComplete: () {
                          /// do something on complete
                        },
                        onPause: () {
                          /// do something on pause
                        },
                        onPlaying: () {
                          /// do something on playing
                        },
                        onError: (err) {
                          /// do somethin on error
                        },
                      ),
                      innerPadding: 12,
                      cornerRadius: 20,
                    ),
                  ),
                ),
              )
            : type == MessageEnum.video
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => VideoStoryPlayer(
                              videoUrl: message,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                          width: 180,
                          height: 300,
                          child: StoryThumbnail(videoUrl: message)),
                    ),
                  )
                : type == MessageEnum.document
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                Container(
                                  width: 130,
                                  color: Colors.black,
                                  height: 80,
                                ),
                                Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.document_scanner,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Document',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xff3f3f3f)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                                height: 40,
                                child: IconButton(
                                    icon: Icon(Icons.download,
                                        color: Color(0xff3f3f3f)),
                                    onPressed: () {}))
                          ],
                        ),
                      )
                    : type == MessageEnum.music
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: <Widget>[
                                    Container(
                                      width: 130,
                                      color: Colors.black,
                                      height: 80,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.headphones,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Music',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xff3f3f3f)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: 40,
                                    child: IconButton(
                                        icon: Icon(Icons.download,
                                            color: Color(0xff3f3f3f)),
                                        onPressed: () {}))
                              ],
                            ),
                          )
                        : type == MessageEnum.gif
                            ? SizedBox(
                                width: 180,
                                height: 120,
                                child: CachedNetworkImage(
                                  imageUrl: message,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return DetailScreen(
                                      filename: message,
                                      extension: '.no',
                                    );
                                  }));
                                },
                                child: SizedBox(
                                  width: 180,
                                  height: 300,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: message,
                                  ),
                                ),
                              );
  }

  void showVideoPlayer(parentContext, String videoUrl) async {
    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFF667781).withOpacity(.4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 20),
                Divider(
                  thickness: .5,
                  color: Color(0xFF667781).withOpacity(.3),
                ),
                // VideoPlayerWidget(videoUrl)
              ],
            ),
          ),
        );
      },
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String filename;
  final String extension;
  DetailScreen({
    super.key,
    required this.filename,
    required this.extension,
  });

  final downloadService = DownloadService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'imageHero',
                child: CachedNetworkImage(
                  imageUrl: filename,
                ),
              ),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              //   child: Text('Ajouter',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 2),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          iconSize: 30,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          )),
                      IconButton(
                          iconSize: 30, onPressed: () {}, icon: SizedBox())
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
