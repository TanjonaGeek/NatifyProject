import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:natify/core/utils/my_date_util.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Storie/domaine/entities/storie_entities.dart';
import 'package:natify/features/Storie/presentation/provider/storie_provider.dart';
import 'package:natify/features/Storie/presentation/widget/emojiReaction.dart';
import 'package:natify/features/Storie/presentation/widget/storieView/story_view.dart';
import 'package:natify/features/Storie/presentation/widget/storieView/widgets/user_info_story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class StoryViewForAll extends ConsumerStatefulWidget {
  final int indexJump;
  final List<StorieEntity> stories;
  const StoryViewForAll(
      {super.key, required this.indexJump, required this.stories});
  @override
  ConsumerState<StoryViewForAll> createState() => _StoryViewForAllState();
}

class _StoryViewForAllState extends ConsumerState<StoryViewForAll> {
  final StoryController controllerStorieView = StoryController();
  final CarouselSliderController _controller = CarouselSliderController();
  GlobalKey keys = GlobalKey();
  final firestore = FirebaseFirestore.instance;
  late final StreamSubscription<bool> _keyboardSubscription;
  final ValueNotifier<String> _uidPropritaireStory = ValueNotifier("");
  final ValueNotifier<String> _urlPhotoStory = ValueNotifier("");
  final ValueNotifier<String> _typeStory = ValueNotifier("");

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible == true) {
        controllerStorieView.pause();
      } else {
        controllerStorieView.play();
      }
    });
  }

  @override
  void dispose() {
    // Annulez la souscription pour libérer les ressources
    _keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            CarousselWidget(
              controller: _controller,
              widget: widget,
              controllerStorieView: controllerStorieView,
              onStoryShow: (s, index, uid) {
                _uidPropritaireStory.value = uid;
                _urlPhotoStory.value = s.url;
                _typeStory.value = s.type;
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReactionEmoji(
                  emojiAssets: [
                    'assets/0.gif',
                    'assets/1.gif',
                    'assets/2.gif',
                    'assets/3.gif',
                    'assets/4.gif',
                    'assets/5.gif',
                    'assets/6.gif',
                  ],
                  onReactionSelected: (emojiAsset) async {
                    List<String> pathParts = emojiAsset.split('/');
                    String fileName = pathParts[1];
                    List<String> fileParts = fileName.split('.');
                    int emojiSelect = int.parse(fileParts[0]);
                    final List<ConnectivityResult> connectivityResult =
                        await (Connectivity().checkConnectivity());
                    if (connectivityResult.contains(ConnectivityResult.none)) {
                      showCustomSnackBar("Pas de connexion internet");
                      return;
                    }
                    if (mounted) {
                      ref.read(storieStateNotifier.notifier).ReactStory(
                          _uidPropritaireStory.value,
                          emojiSelect,
                          _urlPhotoStory.value);
                    }
                  },
                  onPress: (String message) async {
                    final List<ConnectivityResult> connectivityResult =
                        await (Connectivity().checkConnectivity());
                    if (connectivityResult.contains(ConnectivityResult.none)) {
                      showCustomSnackBar("Pas de connexion internet");
                      return;
                    }
                    if (message != "") {
                      ref.read(storieStateNotifier.notifier).RepondreStory(
                          message,
                          _uidPropritaireStory.value,
                          _urlPhotoStory.value,
                          _typeStory.value);
                    }
                  },
                ),
              ),
            ),
          ],
        ));
  }
}

class CarousselWidget extends ConsumerWidget {
  const CarousselWidget({
    super.key,
    required CarouselSliderController controller,
    required this.widget,
    required this.controllerStorieView,
    required this.onStoryShow,
  }) : _controller = controller;

  final CarouselSliderController _controller;
  final StoryViewForAll widget;
  final StoryController controllerStorieView;
  final Function(StoryItem, int, String) onStoryShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<String> indexStoryShow = ValueNotifier("");
    return CarouselSlider.builder(
      carouselController: _controller,
      itemCount: widget.stories.length,
      itemBuilder: (context, index, realIndex) {
        // Construire les éléments de l'histoire
        final story = widget.stories[index];
        final List<StoryItem> storyItems = story.photoUrl?.map((photo) {
              final url = photo['url'] as String? ?? '';
              final type = photo['type'] as String?;
              if (type == "video") {
                return StoryItem.pageVideo(url,
                    controller: controllerStorieView,
                    duration: Duration(seconds: 30));
              } else {
                return StoryItem.pageImage(
                    url: url,
                    controller: controllerStorieView,
                    duration: Duration(seconds: 7));
              }
            }).toList() ??
            [];

        // Vérifier si des histoires sont disponibles
        if (storyItems.isEmpty) {
          return const Center(
            child: Text(
              "Aucune story disponible",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        // Afficher FlutterStoryView pour chaque histoire
        return ValueListenableBuilder<String>(
            valueListenable: indexStoryShow,
            builder: (context, value, child) {
              return StoryView(
                controller: controllerStorieView,
                storyItems: storyItems,
                onComplete: () {
                  _controller.nextPage();
                },
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    Navigator.pop(context);
                  }
                },
                userInfo: UserInfoStory(
                  uid: story.uid,
                  username: story.username ?? "Utilisateur inconnu",
                  profileUrl: story.profilePic ?? "",
                ),
                onStoryShow: (s, index) {
                  Future.microtask(() {
                    int timeCreatedAt = story.photoUrl?[index]['timeSent'];
                    var timeParsing =
                        DateTime.fromMillisecondsSinceEpoch(timeCreatedAt);
                    String timePosting =
                        MyDateUtil.timeAgoSinceDate3(timeParsing.toString());

                    indexStoryShow.value =
                        timePosting; // Met à jour de manière asynchrone
                  });

                  onStoryShow(s, index, story.uid.toString());
                  ref
                      .read(storieStateNotifier.notifier)
                      .ViewStory(story.uid.toString(), s.url.toString());
                },
                createdAt: value,
              );
            });
      },
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height,
        initialPage: widget.indexJump,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        autoPlay: false,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          debugPrint("Page de carousel changée à : $index");
        },
      ),
    );
  }
}
