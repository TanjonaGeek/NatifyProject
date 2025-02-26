import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/core/utils/widget/loading.dart';
import 'package:natify/features/Chat/presentation/widget/extraitVideo/miniuatureChat.dart';
import 'package:natify/features/Storie/domaine/entities/storie_entities.dart';
import 'package:natify/features/Storie/presentation/pages/storieViewForMe.dart';
import 'package:natify/features/Storie/presentation/pages/storyViewForAll.dart';
import 'package:natify/features/Storie/presentation/pages/creeateStoriePage.dart';
import 'package:natify/features/Storie/presentation/provider/storie_provider.dart';
import 'package:natify/features/Storie/presentation/widget/shimmer/shimmerStoryGrid.dart';
import 'package:natify/features/User/presentation/provider/state/info_state_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SectionListAllOfStorie extends ConsumerStatefulWidget {
  final InfoStateUser notifier;
  const SectionListAllOfStorie({required this.notifier, super.key});

  @override
  ConsumerState<SectionListAllOfStorie> createState() =>
      _SectionListAllOfStorieState();
}

class _SectionListAllOfStorieState
    extends ConsumerState<SectionListAllOfStorie> {
  final int cutoffTime =
      DateTime.now().subtract(const Duration(hours: 24)).millisecondsSinceEpoch;
  final String uidUser = auth.currentUser?.uid ?? "";
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserStream() {
    // Vérification si l'utilisateur courant est null
    if (auth.currentUser == null) {
      // Retourner un stream vide si l'utilisateur n'est pas connecté
      return Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('status')
        .where('storyAvailableForUser', arrayContains: uidUser)
        .where('createdAt', isGreaterThanOrEqualTo: cutoffTime)
        .orderBy('createdAt')
        .snapshots();
  }

  Stream<List<StorieEntity>> fetchYourStoryStream() {
    final cutoffTime =
        DateTime.now().subtract(Duration(hours: 24)).millisecondsSinceEpoch;

    return FirebaseFirestore.instance
        .collection('status')
        .where('uid',
            isEqualTo:
                uidUser) // Ajusté en 'isEqualTo' si vous voulez un utilisateur spécifique
        .where('createdAt',
            isGreaterThanOrEqualTo:
                cutoffTime) // Filtrez par l'UID de l'utilisateur
        .snapshots() // Écoute les mises à jour
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Convertir chaque document en une instance de votre modèle
        return StorieEntity(
          uid: doc['uid'] as String? ?? '', // Valeur par défaut vide si null
          username: doc['username'] as String? ??
              'Anonymous', // Valeur par défaut 'Anonymous'
          photoUrl: (doc['photoUrl'] as List<dynamic>?)
                  ?.map((e) => Map<String, dynamic>.from(e))
                  .toList() ??
              [],
          createdAt:
              doc['createdAt'] as int? ?? 0, // Valeur par défaut 0 si null
          profilePic: doc['profilePic'] as String? ??
              '', // Valeur par défaut vide si null
          statusId: doc['statusId'] as String? ??
              '', // Valeur par défaut vide si null
          QuivoirStorie: (doc['QuivoirStorie'] as List<dynamic>?)
                  ?.map((e) => Map<String, dynamic>.from(e))
                  .toList() ??
              [],
          storyAvailableForUser: doc['storyAvailableForUser'] != null
              ? List<String>.from(doc['storyAvailableForUser'] as List)
              : [], // Si null, liste vide
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: ref
          .read(storieStateNotifier.notifier)
          .getAllStory(80, false), // Appeler le Future ici sans initState
      builder: (context, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }
        if (futureSnapshot.hasError) {
          return Center(
              child: Text(
                  "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer."
                      .tr));
        }
        if (futureSnapshot.hasData) {
          return const Center(child: Text(""));
        }

        // Le Future est résolu, maintenant on écoute le Stream
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: getUserStream(),
          builder: (context, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return SizedBox.shrink();
            }
            if (streamSnapshot.hasError) {
              return Center(child: Text('Erreur : ${streamSnapshot.error}'));
            }
            if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
              return StreamBuilder<List<StorieEntity>>(
                  stream: fetchYourStoryStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Erreur lors de la récupération de la story'));
                    }
                    final story = snapshot.data;
                    return story!.isEmpty
                        ? Container(
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  child: Container(
                                    width: 200,
                                    height: 300,
                                    margin: EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        SlideNavigation.slideToPage(
                                            context, GalleryPage());
                                      },
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              SlideNavigation.slideToPage(
                                                  context, GalleryPage());
                                            },
                                            child: CachedNetworkImage(
                                              height: 200,
                                              imageUrl: widget.notifier
                                                  .MydataPersiste!.profilePic
                                                  .toString(),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  12),
                                                          topLeft:
                                                              Radius.circular(
                                                                  12)),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  ShimmerLoadingCard(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  image: const DecorationImage(
                                                    image: AssetImage(
                                                        'assets/noimage.png'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(8)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // Bouton +
                                          Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: kPrimaryColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 2),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // Texte "Créez une story"
                                          Text(
                                            'Ajouter storie'.tr,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 2),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  child: SizedBox(
                                      width: 200,
                                      height: 300,
                                      child:
                                          AnimationConfiguration.staggeredGrid(
                                        position: 1,
                                        duration:
                                            const Duration(milliseconds: 375),
                                        columnCount: 2,
                                        child: SlideAnimation(
                                          horizontalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: Stack(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: story.first.photoUrl!
                                                              .last['type'] ==
                                                          'video'
                                                      ? StoryThumbnail(
                                                          videoUrl: story
                                                                      .first
                                                                      .photoUrl
                                                                      ?.last[
                                                                  'url'] ??
                                                              "")
                                                      : CachedNetworkImage(
                                                          imageUrl: story
                                                                      .first
                                                                      .photoUrl
                                                                      ?.last[
                                                                  'url'] ??
                                                              "",
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade100,
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          8)),
                                                            ),
                                                          ),
                                                          placeholder: (context,
                                                                  url) =>
                                                              ShimmerLoadingCard(),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade100,
                                                              image:
                                                                  const DecorationImage(
                                                                image: AssetImage(
                                                                    'assets/noimage.png'),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          8)),
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    SlideNavigation.slideToPage(
                                                        context,
                                                        StoryViewForMe(
                                                            indexJump: 0,
                                                            stories: story));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  8)),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 10,
                                                  left: 10,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      SlideNavigation
                                                          .slideToPage(context,
                                                              GalleryPage());
                                                    },
                                                    child: CircleAvatar(
                                                        radius: 20,
                                                        backgroundColor:
                                                            newColorBlueElevate,
                                                        child: FaIcon(
                                                          FontAwesomeIcons.plus,
                                                          size: 24,
                                                          color: Colors.white,
                                                        )),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 15,
                                                  left: 10,
                                                  child: Text(
                                                    'Ajouter storie'.tr,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          );
                  });
            }
            List<StorieEntity> storieList = [];
            final stories = streamSnapshot.data!.docs;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0,
                  mainAxisExtent: 300),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final data = stories[index].data();
                // Récupérer la liste des photos
                List<dynamic> photoUrls = data['photoUrl'];
                List<dynamic> photosNonVues = [];
                // Vérifiez chaque photo dans photoUrl
                for (var photo in photoUrls) {
                  String photoUrl = photo[
                      'url']; // Supposons que 'url' est la clé dans chaque photo

                  // Vérification si l'utilisateur a déjà vu cette photo
                  bool vue = (data['QuivoirStorie'] as List).any((item) {
                    return item['uid'] == uidUser &&
                        item['photoUrl'] == photoUrl;
                  });

                  if (!vue) {
                    // Ajouter à la liste des photos non vues
                    photosNonVues.add(photo);
                  }
                }

                // Si toutes les photos sont déjà vues, ne pas afficher cette story
                if (photosNonVues.isEmpty) {
                  String uidUserRemoveMe = data['uid'];
                  ref
                      .read(storieStateNotifier.notifier)
                      .removeUidFromStory(uidUserRemoveMe);
                  return const SizedBox
                      .shrink(); // Rien ne retourner pour cette story, cela évite un espace vide
                }

                // Sélectionnez la dernière photo non vue
                var lastPhotoNonVue = photosNonVues.last;

                // Construisez la StorieEntity avec uniquement les photos non vues
                StorieEntity storie = StorieEntity(
                  uid: data['uid'] as String? ??
                      '', // Valeur par défaut vide si 'uid' est null
                  username: data['username'] as String? ??
                      'Unknown', // Valeur par défaut 'Unknown' si 'username' est null
                  photoUrl: (data['photoUrl'] as List<dynamic>?)
                          ?.map((e) => Map<String, dynamic>.from(e))
                          .toList() ??
                      [], // Liste vide par défaut si 'photoUrl' est null
                  createdAt: data['createdAt'] as int? ??
                      0, // Valeur par défaut 0 si 'createdAt' est null
                  profilePic: data['profilePic'] as String? ??
                      '', // Valeur par défaut vide si 'profilePic' est null
                  statusId: data['statusId'] as String? ??
                      '', // Valeur par défaut vide si 'statusId' est null
                  QuivoirStorie: (data['QuivoirStorie'] as List<dynamic>?)
                          ?.map((e) => Map<String, dynamic>.from(e))
                          .toList() ??
                      [], // Liste vide par défaut si 'QuivoirStorie' est null
                  storyAvailableForUser: (data['storyAvailableForUser']
                              as List<dynamic>?)
                          ?.map((e) => e as String)
                          .toList() ??
                      [], // Liste vide par défaut si 'storyAvailableForUser' est null
                );

                // Ajoutez la story à storieList si elle n'y est pas déjà
                if (!storieList.any((existingStorie) =>
                    existingStorie.statusId == storie.statusId)) {
                  storieList.add(storie);
                }
                // Continuez avec la logique de construction de l'interface utilisateur
                String typeStorie = lastPhotoNonVue[
                    'type']; // Type de la dernière photo non vue
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: typeStorie == 'video'
                                ? StoryThumbnail(
                                    videoUrl: lastPhotoNonVue['url'])
                                : CachedNetworkImage(
                                    imageUrl: lastPhotoNonVue['url'],
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        ShimmerLoadingCard(),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        image: const DecorationImage(
                                          image:
                                              AssetImage('assets/noimage.png'),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                    ),
                                  ),
                          ),
                          InkWell(
                            onTap: () {
                              // SlideNavigation.slideToPage(context,StoryDesignOther(storieUrlSpecific:  lastPhotoNonVue['url'],stories:storieList));
                              SlideNavigation.slideToPage(
                                  context,
                                  StoryViewForAll(
                                      indexJump: index, stories: storieList));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: InkWell(
                              onTap: () async {
                                // Handle tap
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: newColorBlueElevate,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 18,
                                  backgroundImage:
                                      data['profilePic'].toString().isEmpty
                                          ? AssetImage('assets/noimage.png')
                                          : CachedNetworkImageProvider(
                                              data['profilePic'].toString()),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            left: 10,
                            child: InkWell(
                              onTap: () async {
                                // Handle tap
                              },
                              child: Text(
                                data['username'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

final firestore = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;
