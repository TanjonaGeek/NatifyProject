import 'package:carousel_slider/carousel_slider.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/my_date_util.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/Chat/presentation/widget/videoPlayer/videoPlayer.dart';
import 'package:natify/features/Storie/presentation/widget/storieView/story_view.dart';
import 'package:natify/features/Storie/presentation/widget/storieView/widgets/user_info_story.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/entities/highlight_entity.dart';
import 'package:natify/features/User/presentation/pages/userProfilePage.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/list/shimmer/shimmerSpectateurs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HighlightViewForMe extends ConsumerStatefulWidget {
  final int indexJump;
  final List<HighlightEntity> stories;
  final String name;
  final String uid;
  const HighlightViewForMe(
      {super.key,
      required this.indexJump,
      required this.stories,
      required this.name,
      required this.uid});
  @override
  ConsumerState<HighlightViewForMe> createState() => _HighlightViewForMeState();
}

class _HighlightViewForMeState extends ConsumerState<HighlightViewForMe> {
  final StoryController controllerStorieView = StoryController();
  final CarouselSliderController _controller = CarouselSliderController();
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

class CarousselWidget extends ConsumerStatefulWidget {
  const CarousselWidget({
    super.key,
    required CarouselSliderController controller,
    required this.widget,
    required this.controllerStorieView,
    required this.onStoryShow,
  }) : _controller = controller;

  final CarouselSliderController _controller;
  final HighlightViewForMe widget;
  final StoryController controllerStorieView;
  final Function(StoryItem, int, String) onStoryShow;

  @override
  ConsumerState<CarousselWidget> createState() => _CarousselWidgetState();
}

class _CarousselWidgetState extends ConsumerState<CarousselWidget> {
  final ValueNotifier<bool> _showSpectateur = ValueNotifier(false);
  final ValueNotifier<String> _uidPropritaireStory = ValueNotifier("");
  final ValueNotifier<String> _urlPhotoStory = ValueNotifier("");
  final ValueNotifier<String> _typeStory = ValueNotifier("");
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final ValueNotifier<bool> _statusFinPage = ValueNotifier(false);
  final ValueNotifier<int> _indeStorieItem = ValueNotifier(0);
  String textSpectateurs = "listes_des_spectateurs".tr;
  final ScrollController _scrollController = ScrollController();
  Future<List<Map<String, dynamic>>> fetchSpectatorsData(
      List quivoirHiglight, String photoUrl) async {
    List<Map<String, dynamic>> list = [];
    try {
      // Filtrer les histoires pour obtenir celles qui correspondent à l'URL de la photo
      var data = quivoirHiglight
          .where((story) => story['photoUrl'] == photoUrl)
          .toList();

      for (var toElement in data) {
        String uid = toElement['uid'];
        try {
          final userDataSnapshot =
              await firestore.collection('users').doc(uid).get();
          if (userDataSnapshot.exists && userDataSnapshot.data() != null) {
            final userData = UserModel.fromJson(userDataSnapshot.data()!);
            list.add({
              "photoUrl": userData.profilePic ?? '',
              "nom": userData.name ?? '',
              "uid": uid
            });
          } else {
            // Handle case where user data is not found or is null
            print("User data not found for UID: $uid");
          }
        } catch (e) {
          print("Failed to fetch user data for UID: $uid, Error: $e");
        }
      }
    } catch (e) {
      print("Une erreur s'est produite: $e");
    }
    return list; // Renvoie la liste finale
  }

  void _showDeleteConfirmationDialog(
      BuildContext context,
      List dataActually,
      String uidVisiteur,
      String collectionId,
      int index,
      int createdAt,
      String titre) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            'confirmation'.tr,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content:
              Text('Êtes-vous sûr de vouloir supprimer cette highlight?'.tr),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
              },
              child: Text('annuler'.tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
              ),
              onPressed: () {
                if (mounted) {
                  print('le index est $index');
                  ref.read(infoUserStateNotifier.notifier).suprrimerCollection(
                      dataActually,
                      uidVisiteur,
                      collectionId,
                      index,
                      createdAt,
                      titre);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'supprimer'.tr,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fonction du listener qui vérifie la position
  void _scrollListener() {
    // Vérifie si la position est au sommet
    print('Défilement détecté');
    if (_scrollController.position.pixels <= 0.0) {
      _showSpectateur.value = true;
      widget.controllerStorieView.pause();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: widget._controller,
      itemCount: widget.widget.stories.length,
      itemBuilder: (context, index, realIndex) {
        // Construire les éléments de l'histoire
        final story = widget.widget.stories[index];
        final List<StoryItem> storyItems =
            (story.data![0]['ImagePath'] as List).map<StoryItem>((photo) {
          final url = photo['path'] as String? ?? '';
          final type = story.type;

          if (type == "video") {
            return StoryItem.pageVideo(
              url,
              caption: Text(
                'Glissez_vers_haut'.tr,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              controller: widget.controllerStorieView,
              duration: const Duration(seconds: 30),
            );
          } else {
            return StoryItem.pageImage(
              url: url,
              caption: Text(
                'Glissez_vers_haut'.tr,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              controller: widget.controllerStorieView,
              duration: const Duration(seconds: 7),
            );
          }
        }).toList();
        // Vérifier si des histoires sont disponibles
        if (storyItems.isEmpty) {
          return Center(
            child: Text(
              "Il n'y a pas encore de highlights à découvrir en ce moment".tr,
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        int timeCreatedAt = story.data![0]['createdAt'];
        var timeParsing = DateTime.fromMillisecondsSinceEpoch(timeCreatedAt);
        String timePosting =
            MyDateUtil.timeAgoSinceDate3(timeParsing.toString());
        // Afficher FlutterStoryView pour chaque histoire
        return Stack(
          children: [
            StoryView(
              showMenuIcon: true,
              onMenuTapListener: () {
                widget.controllerStorieView.pause();
                _showMoreOption4(
                    _showSpectateur,
                    context,
                    story.data![0]['ImagePath'],
                    widget.widget.uid,
                    story.data![0]['collectionId'],
                    _indeStorieItem.value,
                    story.data![0]['createdAt'],
                    story.data![0]['titre']);
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.up) {
                  _showSpectateur.value = true;
                  widget.controllerStorieView.pause();
                } else if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              controller: widget.controllerStorieView,
              storyItems: storyItems,
              onComplete: () {
                widget._controller.nextPage();
                if (widget.widget.indexJump ==
                    widget.widget.stories.length - 1) {
                  Navigator.pop(context);
                }
                if (_statusFinPage.value == true) {
                  Navigator.pop(context);
                }
              },
              userInfo: UserInfoStory(
                uid: widget.widget.uid,
                username: story.data![0]['titre'] ?? "Utilisateur inconnu",
                profileUrl: story.profilePic ?? "",
              ),
              onStoryShow: (s, index) {
                _urlPhotoStory.value = s.url.toString();
                _uidPropritaireStory.value = widget.widget.uid.toString();
                _typeStory.value = s.type.toString();
                _indeStorieItem.value = index;
              },
              createdAt: timePosting,
            ),
            ValueListenableBuilder<bool>(
                valueListenable: _showSpectateur,
                builder: (context, showSpectateurs, _) {
                  if (showSpectateurs) {
                    return GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dy > 0) {
                          _showSpectateur.value = false;
                          widget.controllerStorieView.play();
                        }
                      },
                      child: Container(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 300,
                                  color: Colors.grey.shade200,
                                  child: _typeStory.value == 'video'
                                      ? VideoStoryPlayer(
                                          videoUrl: _urlPhotoStory.value)
                                      : CachedNetworkImage(
                                          imageUrl: _urlPhotoStory.value,
                                          placeholder: (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                color: Colors.white,
                                              )),
                                          errorWidget: (context, url, error) =>
                                              SizedBox(),
                                          fit: BoxFit.cover),
                                ),
                                Positioned(
                                    top: 30,
                                    left: 2,
                                    child: IconButton(
                                        onPressed: () {
                                          _showSpectateur.value = false;
                                          widget.controllerStorieView.play();
                                        },
                                        icon: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: Center(
                                                child: FaIcon(
                                                    FontAwesomeIcons.close,
                                                    size: 15,
                                                    color: Colors.black54))))),
                                Positioned(
                                    top: 30,
                                    right: 2,
                                    child: IconButton(
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                              context,
                                              story.data![0]['ImagePath'],
                                              widget.widget.uid,
                                              story.data![0]['collectionId'],
                                              _indeStorieItem.value,
                                              story.data![0]['createdAt'],
                                              story.data![0]['titre']);
                                        },
                                        icon: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: Center(
                                                child: FaIcon(
                                                    FontAwesomeIcons.trash,
                                                    size: 15,
                                                    color: Colors.red))))),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 8, bottom: 2),
                              child: Container(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(textSpectateurs,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    // FaIcon(FontAwesomeIcons.solidTrashCan,size: 17,color: Colors.black87,)
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              color: Colors.grey.shade300,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                "decouvrez_qui_a_consulte".tr,
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Expanded(
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: fetchSpectatorsData(
                                    story.QuivoirCollection!.cast<dynamic>(),
                                    _urlPhotoStory
                                        .value), // Remplacez par vos paramètres
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return ShimmerLoadingSpectators(); // Afficher un indicateur de chargement
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer."
                                                .tr)); // Gérer l'erreur
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          height: 120,
                                          child:
                                              Image.asset('assets/grouper.png'),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Pas encore de vues !".tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        // SizedBox(height: 4),
                                        // Text(
                                        //   "Soyez le premier à visionner cette story".tr,
                                        //   textAlign: TextAlign.center,
                                        //   style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                                        // ),
                                      ],
                                    ); // Pas de spectateurs
                                  } else {
                                    return Expanded(
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: EdgeInsets.zero,
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          final item = snapshot.data![index];
                                          return GestureDetector(
                                            onTap: () {
                                              SlideNavigation.slideToPage(
                                                  context,
                                                  UserProfileScreen(
                                                      uid: item['uid']));
                                            },
                                            child: _buildOption(
                                              urlPhoto: item['photoUrl'],
                                              nom: item['nom'],
                                              emoji: [],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                })
          ],
        );
      },
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height,
        initialPage: widget.widget.indexJump,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        autoPlay: false,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          if (index < widget.widget.stories.length - 1) {
          } else {
            _statusFinPage.value = true;
          }
        },
      ),
    );
  }

  _showMoreOption4(
      ValueNotifier<bool> showSpectateur,
      BuildContext context,
      List dataActually,
      String uidVisiteur,
      String collectionId,
      int index,
      int createdAt,
      String titre) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Colors.transparent,
      builder: (context) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.7, // Limite à 80% de la hauteur de l'écran
          ),
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 5,
                right: 5),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                      child: Text(
                        "plus_d_options".tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 0.7,
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 1, top: 1),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmationDialog(
                              context,
                              dataActually,
                              uidVisiteur,
                              collectionId,
                              index,
                              createdAt,
                              titre);
                          // SlideNavigation.slideToPage(context, AllUserFollower(uid: widget.uid,));
                        },
                        leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.grey.shade300,
                            ),
                            child: Center(
                                child: FaIcon(
                              FontAwesomeIcons.trash,
                              size: 17,
                              color: Colors.red,
                            ))),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'suppression'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "retirez_cette_story".tr,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 1, top: 1),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          // SlideNavigation.slideToPage(context, AllUserFollowing(uid: widget.uid,));
                          showSpectateur.value = true;
                          widget.controllerStorieView.pause();
                        },
                        leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.grey.shade300,
                            ),
                            child: Center(
                                child: FaIcon(
                              FontAwesomeIcons.list,
                              size: 17,
                              color: Colors.black,
                            ))),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'voir_les_spectateurs'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "affichez_la_liste_detaillee".tr,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),
          )),
    );
  }

  Widget _buildOption({
    required String urlPhoto,
    required String nom,
    required List<dynamic> emoji,
  }) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: urlPhoto,
        imageBuilder: (context, imageProvider) => Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        placeholder: (context, url) => Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            image: const DecorationImage(
              image: AssetImage('assets/noimage.png'),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
      ),
      title: Text(nom),
      trailing: ListView.builder(
        itemCount: emoji.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image(
              width: 20,
              height: 20,
              image: AssetImage("assets/${emoji[index]}.gif"),
            ),
          );
        },
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 1.0, horizontal: 7.0),
    );
  }
}
