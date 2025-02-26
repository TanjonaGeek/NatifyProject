import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:natify/features/Chat/presentation/widget/galleryphoto.dart';
import 'package:natify/features/Chat/presentation/widget/giphy.dart';
import 'package:natify/features/Chat/presentation/widget/message_reply_preview.dart';
import 'package:natify/features/Chat/presentation/widget/ondeSonnore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

class MessageInputField extends ConsumerStatefulWidget {
  final String userUid;
  final String colorSender;
  final String colorMe;
  final String themeApply;
  const MessageInputField(
      {super.key,
      required this.userUid,
      required this.colorSender,
      required this.colorMe,
      required this.themeApply});
  @override
  ConsumerState<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends ConsumerState<MessageInputField>
    with SingleTickerProviderStateMixin {
  bool _showEmojiPicker = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _emojiAnimationController;
  late Animation<double> _emojiAnimation;
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  Timer? _timer;
  int _recordDuration = 0;

  String? selectedTheme;
  late ValueNotifier<bool> isShowOptionNotifier = ValueNotifier<bool>(false);

  List<Map<String, dynamic>> themes = [
    {
      'name': 'ART',
      'colorSender': "f3dbcb",
      'colorMe': "e59b8b",
      'image': 'assets/theme_chat/art.png',
    },
    {
      'name': 'EDUCATION',
      'colorSender': "e6efec",
      'colorMe': "7bab9a",
      'image': 'assets/theme_chat/education.png',
    },
    {
      'name': 'FASHION',
      'colorSender': "fde3e4",
      'colorMe': "d08676",
      'image': 'assets/theme_chat/fashion.jpg',
    },
    {
      'name': 'YOGA',
      'colorSender': "ab7c63",
      'colorMe': "ebb484",
      'image': 'assets/theme_chat/yoga.jpg',
    },
    {
      'name': 'MUSIC',
      'colorSender': "bfa682",
      'colorMe': "84695e",
      'image': 'assets/theme_chat/music.png',
    },
    {
      'name': 'FLOOR',
      'colorSender': "754b33",
      'colorMe': "d2bca4",
      'image': 'assets/theme_chat/floor.jpg',
    },
    {
      'name': 'HALLOWEEN',
      'colorSender': "f0f0f2",
      'colorMe': "0f3c51",
      'image': 'assets/theme_chat/halloween.jpg',
    },
    {
      'name': 'ROSE',
      'colorSender': "f7bdbc",
      'colorMe': "cc748c",
      'image': 'assets/theme_chat/rose.jpg',
    },
    {
      'name': 'MARIAH CARREY',
      'colorSender': "ebe1c3",
      'colorMe': "e38c8c",
      'image': 'assets/theme_chat/mariacarrey.png',
    },
    {
      'name': 'HIVERNAL',
      'colorSender': "c9cdce",
      'colorMe': "637888",
      'image': 'assets/theme_chat/hivernal.jpg',
    },
    {
      'name': 'BUFFERFLY',
      'colorSender': "f5f5f1",
      'colorMe': "90c390",
      'image': 'assets/theme_chat/bufferfly.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _recorder!.openRecorder();
    _player!.openPlayer();
    _emojiAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _emojiAnimation = CurvedAnimation(
        parent: _emojiAnimationController, curve: Curves.easeIn);
    isShowOptionNotifier = ValueNotifier(false);

    // Écouteur pour gérer le focus sur le TextField
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _hideEmojiPicker();
      }
    });
  }

  @override
  void dispose() {
    isShowOptionNotifier.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _emojiAnimationController.dispose();
    _recorder!.closeRecorder();
    _player!.closePlayer();
    _recorder = null;
    _player = null;
    _timer?.cancel();
    super.dispose();
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      _hideEmojiPicker();
      FocusScope.of(context).requestFocus(_focusNode); // Show keyboard
    } else {
      _focusNode.unfocus(); // Hide keyboard
      _emojiAnimationController.forward();
      setState(() {
        _showEmojiPicker = true;
      });
    }
  }

  void _hideEmojiPicker() {
    if (_showEmojiPicker) {
      _emojiAnimationController.reverse();
      setState(() {
        _showEmojiPicker = false;
      });
    }
  }

  Future<void> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      Directory appDir = await getApplicationDocumentsDirectory();
      _filePath = "${appDir.path}/audio_message.aac";

      await _recorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
      );
      isShowOptionNotifier.value = false;
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });

      _startTimer();
    }
  }

  Future<void> stopRecording() async {
    await _recorder!.stopRecorder();
    _timer?.cancel();

    setState(() {
      _isRecording = false;
    });

    // Enregistrement terminé
    print("Enregistrement terminé, fichier sauvegardé à : $_filePath");
  }

  Future<void> playRecording() async {
    if (_filePath != null && !_isPlaying) {
      await _player!.startPlayer(
        fromURI: _filePath,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );

      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> stopPlayback() async {
    await _player!.stopPlayer();

    setState(() {
      _isPlaying = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _resetToInitial() {
    stopPlayback();
    setState(() {
      _filePath = null;
      _isRecording = false;
      _recordDuration = 0;
      _isPlaying = false;
    });
  }

  Widget optionsMenu() {
    return Container(
      // width: 350,
      padding: const EdgeInsets.only(top: 5, left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white),
                ),
              ),
              IconButton(
                  icon: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.transparent,
                      ),
                      child: Center(
                          child: FaIcon(FontAwesomeIcons.close,
                              size: 16, color: Colors.white))),
                  onPressed: () {
                    isShowOptionNotifier.value = false;
                  }),
            ],
          ),
          SizedBox(
            height: 1,
          ),
          Wrap(
            spacing: 8, // Espace horizontal entre les chips
            runSpacing: 8, // Espace vertical entre les chips
            children: [
              _buildOptionChip("vocal", Icons.mic, onTap: startRecording),
              _buildOptionChip("gif", Icons.gif, onTap: () {
                final double appBarHeight = AppBar().preferredSize.height;
                final double statusBarHeight =
                    MediaQuery.of(context).padding.top;
                final double screenHeight = MediaQuery.of(context).size.height;
                isShowOptionNotifier.value = false;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return Container(
                      height:
                          screenHeight - (appBarHeight + statusBarHeight) - 50,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(7)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GifPicker(
                            uid: widget.userUid,
                          )),
                    );
                  },
                );
              }),
              _buildOptionChip("Gallery photo", Icons.photo, onTap: () {
                isShowOptionNotifier.value = false;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GalleryPhoto(
                      uid: widget.userUid,
                    ),
                  ),
                );
              }),
              _buildOptionChip("theme", Icons.palette, onTap: () {
                isShowOptionNotifier.value = false;
                _showThemeSelection(
                    widget.themeApply, context, themes, ref, widget.userUid);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(String label, IconData icon,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.white), // Bordure
        ),
        backgroundColor: Colors.white, // Fond transparent
        labelPadding: EdgeInsets.symmetric(horizontal: 10),
        avatar: Container(
          padding: EdgeInsets.all(1),
          child: Icon(icon,
              size: 20,
              color: Color(int.parse("0xFF${widget.colorMe}"))), // Icône
        ),
        label: Text(
          label.tr,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(chatStateNotifier(widget.userUid));
    return Column(
      children: [
        notifier.messageReply.isNotEmpty
            ? MessageReplyPreview(
                uid: widget.userUid,
                colorMe: widget.colorMe,
                colorSender: widget.colorSender,
              )
            : const SizedBox(),
        ValueListenableBuilder<bool>(
            valueListenable: isShowOptionNotifier,
            builder: (context, isShowing, child) {
              return isShowing && notifier.messageReply.isEmpty
                  ? optionsMenu()
                  : SizedBox.shrink();
            }),
        if (_isRecording) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.trashArrowUp,
                    size: 19,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    stopRecording();
                    _resetToInitial();
                  },
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 15,
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                            child: SoundWave(
                          width: 160.0,
                          height: 6.0,
                          color: Color(int.parse("0xFF${widget.colorMe}")),
                          isPlaying: _isRecording,
                        )),
                        SizedBox(width: 8.0),
                        Text(
                          _formatDuration(_recordDuration),
                          style: TextStyle(
                              color: Color(int.parse("0xFF${widget.colorMe}")),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                        SizedBox(width: 6.0),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.stop,
                    size: 21,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    stopRecording();
                  },
                ),
              ],
            ),
          ),
        ] else if (_filePath != null) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: _isPlaying
                      ? FaIcon(
                          FontAwesomeIcons.pause,
                          size: 21,
                          color: Color(int.parse("0xFF${widget.colorMe}")),
                        )
                      : FaIcon(
                          FontAwesomeIcons.play,
                          size: 21,
                          color: Color(int.parse("0xFF${widget.colorMe}")),
                        ),
                  onPressed: () {
                    _isPlaying ? stopPlayback() : playRecording();
                  },
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 15,
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                            child: SoundWave(
                          width: 160.0,
                          height: 6.0,
                          color: Color(int.parse("0xFF${widget.colorMe}")),
                          isPlaying: _isPlaying,
                        )),
                        SizedBox(width: 8.0),
                        Text(
                          _formatDuration(_recordDuration),
                          style: TextStyle(
                              color: Color(int.parse("0xFF${widget.colorMe}")),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                        SizedBox(width: 6.0),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.trashArrowUp,
                    size: 19,
                    color: Colors.red,
                  ),
                  onPressed: _resetToInitial,
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.solidPaperPlane,
                    color: Color(int.parse("0xFF${widget.colorMe}")),
                  ),
                  onPressed: () {
                    // Logique pour envoyer l'enregistrement
                    String messageText = _controller.text.trim();
                    List<File> fileSend = [];
                    fileSend.add(File(_filePath!));
                    _controller.clear();
                    if (mounted) {
                      ref
                          .read(chatStateNotifier(widget.userUid).notifier)
                          .sendMessage(
                              context,
                              messageText,
                              widget.userUid,
                              notifier.messageReply,
                              MessageEnum.audio,
                              fileSend,
                              '');
                      if (notifier.messageReply.isNotEmpty) {
                        ref
                            .read(chatStateNotifier(widget.userUid).notifier)
                            .cancelReply();
                      }
                    }
                    _resetToInitial();
                  },
                ),
              ],
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.plus,
                    size: 19,
                    color: Color(int.parse("0xFF${widget.colorMe}")),
                  ),
                  onPressed: () {
                    isShowOptionNotifier.value = true;
                  },
                ),
                // IconButton(
                //   icon: FaIcon(FontAwesomeIcons.microphone,size: 19,color: Color(int.parse("0xFF${widget.colorMe}")),),
                //   onPressed: startRecording,
                // ),
                // IconButton(
                //   icon: FaIcon(FontAwesomeIcons.gift,size: 19,color: Color(int.parse("0xFF${widget.colorMe}")),),
                //   onPressed: () {
                //       final double appBarHeight = AppBar().preferredSize.height;
                //       final double statusBarHeight = MediaQuery.of(context).padding.top;
                //       final double screenHeight = MediaQuery.of(context).size.height;
                //       showModalBottomSheet(
                //         context: context,
                //         isScrollControlled: true,
                //         builder: (context) {
                //           return Container(
                //             height: screenHeight - (appBarHeight + statusBarHeight) - 50,
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                //             ),
                //             child: Padding(
                //               padding: const EdgeInsets.all(5.0),
                //               child: GifPicker(uid: widget.userUid,)
                //             ),
                //           );
                //         },
                //       );
                //   },
                // ),
                //  IconButton(
                //   icon: FaIcon(FontAwesomeIcons.image,size: 19,color: Color(int.parse("0xFF${widget.colorMe}")),),
                //   onPressed: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (context) => GalleryPhoto(uid: widget.userUid,),
                //       ),
                //     );
                //   },
                // ),
                //  IconButton(
                //   icon: FaIcon(FontAwesomeIcons.themeco,size: 21,color: Color(int.parse("0xFF${widget.colorMe}")),),
                //   onPressed: () => _showThemeSelection(widget.themeApply,context,themes,ref,widget.userUid),
                // ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 4, left: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextField(
                      maxLines:
                          null, // Permet au champ de s'étendre verticalement
                      keyboardType: TextInputType
                          .multiline, // Permet la saisie multi-ligne
                      controller: _controller,
                      focusNode: _focusNode,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Votre message'.tr,
                        hintStyle: TextStyle(
                            color: Colors.black45, fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.solidFaceSmile,
                            color: Color(int.parse("0xFF${widget.colorMe}")),
                          ),
                          onPressed: _toggleEmojiPicker,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.solidPaperPlane,
                    color: Color(int.parse("0xFF${widget.colorMe}")),
                  ),
                  onPressed: () {
                    if (_controller.text.isEmpty) {
                    } else {
                      String messageText = _controller.text.trim();
                      _controller.clear();
                      if (mounted) {
                        ref
                            .read(chatStateNotifier(widget.userUid).notifier)
                            .sendMessage(
                                context,
                                messageText,
                                widget.userUid,
                                notifier.messageReply,
                                MessageEnum.text,
                                [],
                                '');
                        if (notifier.messageReply.isNotEmpty) {
                          ref
                              .read(chatStateNotifier(widget.userUid).notifier)
                              .cancelReply();
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: _emojiAnimation,
            axisAlignment: -1.0,
            child: _showEmojiPicker
                ? EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _controller.text += emoji.emoji;

                      // Éviter de ramener le focus sur le TextField
                      _focusNode.unfocus();
                    },
                    config: Config(
                      height: 320,
                      checkPlatformCompatibility: true,
                      skinToneConfig: const SkinToneConfig(),
                      categoryViewConfig: const CategoryViewConfig(
                          initCategory: Category.SMILEYS),
                      bottomActionBarConfig: const BottomActionBarConfig(
                          enabled: false,
                          showBackspaceButton: false,
                          showSearchViewButton: false),
                      searchViewConfig: const SearchViewConfig(),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ]
      ],
    );
  }
}

void _showThemeSelection(
  String themeApply,
  BuildContext context,
  List<Map<String, dynamic>> themes,
  WidgetRef ref,
  String uidUserSender,
) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: Text(
              "theme".tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ),
          Divider(thickness: 0.7),
          // Grille des thèmes disponibles
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 170,
            ),
            itemCount: themes.length,
            itemBuilder: (context, index) {
              var theme = themes[index];
              bool isApplied = theme['name'] == themeApply;

              return GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  List<Map<String, String>> dataThemeMessage = [];
                  dataThemeMessage.add({
                    'name': theme['name'],
                    'colorSender': theme['colorSender'],
                    'colorMe': theme['colorMe'],
                    'image': theme['image'].toString(),
                  });
                  await Future.delayed(Duration(seconds: 1));
                  await ref
                      .read(chatStateNotifier(uidUserSender).notifier)
                      .changeThemeMessage(dataThemeMessage, uidUserSender)
                      .then((_) {
                    ref.read(themesStateNotifier.notifier).updateThemeMessage();
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(theme['image']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          theme['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Icône check si le thème est appliqué
                    if (isApplied)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.check_circle,
                          color: kPrimaryColor,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
