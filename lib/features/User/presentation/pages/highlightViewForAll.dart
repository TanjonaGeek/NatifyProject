import 'package:carousel_slider/carousel_slider.dart';
import 'package:natify/core/utils/my_date_util.dart';
import 'package:natify/features/Storie/presentation/widget/storieView/story_view.dart';
import 'package:natify/features/Storie/presentation/widget/storieView/widgets/user_info_story.dart';
import 'package:natify/features/User/domaine/entities/highlight_entity.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HighlightViewForAll extends ConsumerStatefulWidget {
  final int indexJump;
  final List<HighlightEntity> stories;
  final String name;
  final String uid;
  const HighlightViewForAll(
      {super.key,
      required this.indexJump,
      required this.stories,
      required this.name,
      required this.uid});
  @override
  ConsumerState<HighlightViewForAll> createState() =>
      _HighlightViewForAllState();
}

class _HighlightViewForAllState extends ConsumerState<HighlightViewForAll> {
  final StoryController controllerStorieView = StoryController();
  final CarouselSliderController _controller = CarouselSliderController();
  GlobalKey keys = GlobalKey();
  final firestore = FirebaseFirestore.instance;
  final ValueNotifier<String> _uidPropritaireStory = ValueNotifier("");
  final ValueNotifier<String> _urlPhotoStory = ValueNotifier("");
  final ValueNotifier<String> _typeStory = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  final HighlightViewForAll widget;
  final StoryController controllerStorieView;
  final Function(StoryItem, int, String) onStoryShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<bool> statusFinPage = ValueNotifier(false);
    return CarouselSlider.builder(
      carouselController: _controller,
      itemCount: widget.stories.length,
      itemBuilder: (context, index, realIndex) {
        // Construire les éléments de l'histoire
        final story = widget.stories[index];
        final List<StoryItem> storyItems =
            (story.data![0]['ImagePath'] as List).map<StoryItem>((photo) {
          final url = photo['path'] as String? ?? '';
          final type = story.type;

          if (type == "video") {
            return StoryItem.pageVideo(
              url,
              controller: controllerStorieView,
              duration: const Duration(seconds: 30),
            );
          } else {
            return StoryItem.pageImage(
              url: url,
              controller: controllerStorieView,
              duration: const Duration(seconds: 7),
            );
          }
        }).toList();
        // Vérifier si des histoires sont disponibles
        if (storyItems.isEmpty) {
          return const Center(
            child: Text(
              "Aucune story disponible",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        int timeCreatedAt = story.data![0]['createdAt'];
        var timeParsing = DateTime.fromMillisecondsSinceEpoch(timeCreatedAt);
        String timePosting =
            MyDateUtil.timeAgoSinceDate3(timeParsing.toString());
        // Afficher FlutterStoryView pour chaque histoire
        return StoryView(
          controller: controllerStorieView,
          storyItems: storyItems,
          onComplete: () {
            _controller.nextPage();
            if (widget.indexJump == widget.stories.length - 1) {
              Navigator.pop(context);
            }
            if (statusFinPage.value == true) {
              Navigator.pop(context);
            }
          },
          onVerticalSwipeComplete: (direction) {
            if (direction == Direction.down) {
              Navigator.pop(context);
            }
          },
          userInfo: UserInfoStory(
            uid: widget.uid,
            username: story.data![0]['titre'] ?? "Utilisateur inconnu",
            profileUrl: story.profilePic ?? "",
          ),
          onStoryShow: (s, index) {
            onStoryShow(s, index, story.data![0]['collectionId'].toString());
            ref.read(infoUserStateNotifier.notifier).voirCollection(
                story.QuivoirCollection!.cast<dynamic>(),
                widget.uid,
                story.data![0]['collectionId'],
                s.url.toString());
          },
          createdAt: timePosting,
        );
      },
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height,
        initialPage: widget.indexJump,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        autoPlay: false,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          debugPrint(
              "Page de carousel changée à : $index avec taille ${widget.stories.length}");
          if (index < widget.stories.length - 1) {
          } else {
            statusFinPage.value = true;
          }
        },
      ),
    );
  }
}
