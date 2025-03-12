import 'package:animated_dashed_circle/animated_dashed_circle.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/core/utils/widget/loading.dart';
import 'package:natify/features/Chat/presentation/pages/messageDetail.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:natify/features/Chat/presentation/widget/display_text_image_gif.dart';
import 'package:natify/features/Chat/presentation/widget/extraitVideo/miniuatureChat.dart';
import 'package:natify/features/Storie/domaine/entities/storie_entities.dart';
import 'package:natify/features/Storie/presentation/pages/storieViewForMe.dart';
import 'package:natify/features/Storie/presentation/pages/storyViewForAll.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/entities/highlight_entity.dart';
import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:natify/features/User/presentation/pages/createHighLight.dart';
import 'package:natify/features/User/presentation/pages/editerhighlight.dart';
import 'package:natify/features/User/presentation/pages/highlightViewForAll.dart';
import 'package:natify/features/User/presentation/pages/highlightViewForMe.dart';
import 'package:natify/features/User/presentation/pages/informationprofile.dart';
import 'package:natify/features/User/presentation/pages/menu.dart';
import 'package:natify/features/User/presentation/pages/modifierProfiles.dart';
import 'package:natify/features/User/presentation/pages/signaler_profile.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/OverlappingAvatars.dart';
import 'package:natify/features/User/presentation/widget/list/listFollowingAndFollowers.dart';
import 'package:natify/features/User/presentation/widget/list/shimmer/shimmerProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String uid;

  const UserProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ValueNotifier<bool> isFollowedNotifier = ValueNotifier<bool>(false);
  late ValueNotifier<String> userProfilePic = ValueNotifier<String>("");
  late ValueNotifier<String> userName = ValueNotifier<String>("");
  late ValueNotifier<String> userUid = ValueNotifier<String>("");
  late ValueNotifier<bool> isShowNotificationFollow =
      ValueNotifier<bool>(false);
  late ValueNotifier<List<UserEntity>> userDataGet =
      ValueNotifier<List<UserEntity>>([]);
  String debloquer = "Debloquer conversation avec".tr;
  String optionpermet = "Cette option permet à".tr;
  String appeler = "de vous envoyer des messages ou de vous appeler.".tr;
  String bloquer = "Bloquer conversation avec".tr;
  String optionempecher = "Cette option empêche".tr;
  final String uidUser = FirebaseAuth.instance.currentUser?.uid ?? "";
  bool isUserSubscribed(String uid, List<String> subscribedUids) {
    // Convertir la List<dynamic> en Set<String> pour améliorer les performances
    Set<String> subscribedUidsSet =
        Set<String>.from(subscribedUids.whereType<String>());
    return subscribedUidsSet.contains(uid);
  }

  final ValueNotifier<List<String>> imageUrlsNotifier = ValueNotifier([]);

  Future<void> fetchFollowingAndFollowersPics(String userId) async {
    try {
      // Récupère le document de l'utilisateur
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Récupère les listes d'UID de following et followers
      List<dynamic> following = userDoc.data()?['abonnee'] ?? [];
      List<dynamic> followers = userDoc.data()?['abonnement'] ?? [];

      // Prend les 5 premiers éléments de chaque liste
      List<String> firstFiveFollowing =
          following.take(10).cast<String>().toList();
      List<String> firstFiveFollowers =
          followers.take(10).cast<String>().toList();

      // Combine les deux listes et filtre les doublons
      Set<String> combinedUids = {...firstFiveFollowing, ...firstFiveFollowers};

      // Limite à 5 utilisateurs maximum
      List<String> limitedUids = combinedUids.take(10).toList();

      // Récupère les documents des utilisateurs correspondants
      List<String> profilePics = [];
      for (String uid in limitedUids) {
        final userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userSnapshot.exists) {
          String? profilePic = userSnapshot.data()?['profilePic'];
          profilePics.add(profilePic!);
        }
      }
      imageUrlsNotifier.value = profilePics;
    } catch (e) {
      print('Erreur : $e');
    }
  }

  Future<List<UserEntity>> _initializeFollowState() async {
    if (widget.uid != uidUser) {
      final users = await ref
          .read(infoUserStateNotifier.notifier)
          .getInfoUser(widget.uid);
      if (mounted && users.isNotEmpty) {
        bool estAbonne = isUserSubscribed(uidUser, users.first.abonnee ?? []);
        isFollowedNotifier.value = estAbonne;
        isShowNotificationFollow.value = estAbonne;

        // Ajouter la logique de visite ici si nécessaire
        final notifier = ref.read(infoUserStateNotifier);
        UserModel? myCurrentData = notifier.MydataPersiste;
        await ref.read(infoUserStateNotifier.notifier).addNewVisiter(
              myCurrentData?.name ?? "",
              myCurrentData?.profilePic ?? "",
              myCurrentData?.uid ?? "",
              widget.uid,
              users.first,
              myCurrentData?.nationalite ?? "",
              myCurrentData?.flag ?? "",
            );
      }
      return users;
    } else {
      final users = await ref
          .read(infoUserStateNotifier.notifier)
          .getInfoUser(widget.uid);
      return users;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFollowingAndFollowersPics(widget.uid);
    isFollowedNotifier = ValueNotifier(false);
    isShowNotificationFollow = ValueNotifier(false);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    isFollowedNotifier.dispose();
    isShowNotificationFollow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(infoUserStateNotifier);
    List<HighlightEntity> HighLightList = [];
    return ThemeSwitchingArea(
      child: Scaffold(
        body: RefreshIndicator(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          onRefresh: () async {
            setState(() {
              _initializeFollowState();
            });
          },
          child: FutureBuilder<List<UserEntity>>(
            future: Future.delayed(Duration(milliseconds: 500), () {
              return _initializeFollowState();
            }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ShimmerProfilePage(
                  uid: widget.uid,
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'Erreur : ${snapshot.error}')); // Gérer les erreurs
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final users = snapshot.data!;
                userProfilePic.value = users.first.profilePic!.toString();
                userName.value = users.first.name!.toString();
                userUid.value = users.first.uid!.toString();
                userDataGet.value = users;
                return CustomScrollView(
                  slivers: [
                    // SliverAppBar avec un effet de scroll
                    SliverAppBar(
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                newColorBlueElevate,
                                newColorGreenDarkElevate
                              ],
                            ),
                          ),
                        ),
                        title: Text(
                          users.first.name?.toString() ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      leading: IconButton(
                        icon: FaIcon(FontAwesomeIcons.chevronLeft,
                            size: 20, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      actions: [
                        widget.uid == uidUser
                            ? Row(
                                children: [
                                  // IconButton(
                                  //   icon: FaIcon(FontAwesomeIcons.penToSquare,
                                  //       size: 20, color: Colors.white),
                                  //   onPressed: () {
                                  //     Navigator.of(context, rootNavigator: true)
                                  //         .push(
                                  //       MaterialPageRoute(
                                  //           builder: (context) => Editerprofile(
                                  //                 uid: widget.uid,
                                  //                 myOwnData:
                                  //                     notifier.MydataPersiste!,
                                  //               )),
                                  //     );
                                  //   },
                                  // ),
                                  IconButton(
                                    icon: FaIcon(FontAwesomeIcons.bars,
                                        size: 20, color: Colors.white),
                                    onPressed: () {
                                      SlideNavigation.slideToPage(
                                          context, Menu());
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  ValueListenableBuilder<bool>(
                                      valueListenable: isShowNotificationFollow,
                                      builder: (context, isFollowed, child) {
                                        return isFollowed
                                            ? IconButton(
                                                icon: FaIcon(
                                                    FontAwesomeIcons.bell,
                                                    size: 20,
                                                    color: Colors.white),
                                                onPressed: () =>
                                                    _showMoreOptionNotification(
                                                        widget.uid,
                                                        users.first
                                                            .availableSendNotification!),
                                              )
                                            : SizedBox();
                                      }),
                                  IconButton(
                                    icon: FaIcon(FontAwesomeIcons.bars,
                                        size: 20, color: Colors.white),
                                    onPressed: () => _showMoreOption(
                                      widget.uid,
                                      users.first.name?.toString() ?? "",
                                      users,
                                      users.first.abonnee!.length.toString(),
                                      users.first.abonnement!.length.toString(),
                                    ),
                                  )
                                ],
                              )
                      ],
                    ),

                    // Informations sur le profil (SliverToBoxAdapter pour des widgets non-Sliver)
                    SliverToBoxAdapter(
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Informations de base du profil
                              Row(
                                children: [
                                  FutureBuilder<Map<String, dynamic>>(
                                      future: ref
                                          .read(
                                              allUserListStateNotifier.notifier)
                                          .checkifHasStorie(widget.uid),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Shimmer.fromColors(
                                            key: ValueKey(users.first.profilePic
                                                    ?.toString() ??
                                                ""),
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: ClipOval(
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        bool hasStorie =
                                            snapshot.data!['hasStorie'] ??
                                                false;
                                        return GestureDetector(
                                          onTap: () async {
                                            List<StorieEntity> storieList = [];
                                            if (hasStorie == true) {
                                              StorieEntity storie =
                                                  StorieEntity(
                                                uid: snapshot
                                                        .data?['data']?.uid ??
                                                    "",
                                                username: snapshot.data?['data']
                                                        ?.username ??
                                                    "",
                                                photoUrl: snapshot.data?['data']
                                                            ?.photoUrl !=
                                                        null
                                                    ? List<
                                                            Map<String,
                                                                dynamic>>.from(
                                                        snapshot.data!['data']
                                                            .photoUrl)
                                                    : [],
                                                createdAt: snapshot
                                                        .data?['data']
                                                        ?.createdAt ??
                                                    DateTime.now(),
                                                profilePic: snapshot
                                                        .data?['data']
                                                        ?.profilePic ??
                                                    '',
                                                statusId: snapshot.data?['data']
                                                        ?.statusId ??
                                                    '',
                                                QuivoirStorie: snapshot
                                                            .data?['data']
                                                            ?.QuivoirStorie !=
                                                        null
                                                    ? List<
                                                            Map<String,
                                                                dynamic>>.from(
                                                        snapshot.data!['data']
                                                            .QuivoirStorie)
                                                    : [],
                                                storyAvailableForUser: snapshot
                                                            .data?['data']
                                                            ?.storyAvailableForUser !=
                                                        null
                                                    ? List<String>.from(snapshot
                                                        .data!['data']
                                                        .storyAvailableForUser)
                                                    : [],
                                              );
                                              List<Map<String, dynamic>>
                                                  photoUrl = snapshot
                                                      .data!['data'].photoUrl;
                                              storieList.add(storie);
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 50));
                                              _showMoreOption2(
                                                  users.first.profilePic
                                                          ?.toString() ??
                                                      "",
                                                  photoUrl.last['url'],
                                                  storieList,
                                                  widget.uid);
                                            } else {
                                              _showMoreOption2(
                                                  users.first.profilePic
                                                          ?.toString() ??
                                                      "",
                                                  "",
                                                  [],
                                                  widget.uid);
                                            }
                                          },
                                          child: Stack(
                                            children: [
                                              hasStorie
                                                  ? AnimatedDashedCircle().show(
                                                      image: users
                                                              .first
                                                              .profilePic!
                                                              .isEmpty
                                                          ? AssetImage(
                                                              'assets/noimage.png')
                                                          : CachedNetworkImageProvider(
                                                              users.first
                                                                  .profilePic
                                                                  .toString()),
                                                      contentPadding: 04,
                                                      autoPlay: true,
                                                      duration: const Duration(
                                                          seconds: 5),
                                                      height: 100,
                                                      borderWidth: 8,
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors
                                                                .white, // Condition pour la bordure bleue
                                                            width:
                                                                3, // Épaisseur de la bordure
                                                          ),
                                                          shape:
                                                              BoxShape.circle),
                                                      child: ClipOval(
                                                        child:
                                                            CachedNetworkImage(
                                                          key: ValueKey(users
                                                                  .first
                                                                  .profilePic
                                                                  ?.toString() ??
                                                              ""),
                                                          imageUrl: users.first
                                                                  .profilePic
                                                                  ?.toString() ??
                                                              "",
                                                          placeholder:
                                                              (context, url) {
                                                            return Shimmer
                                                                .fromColors(
                                                              key: ValueKey(users
                                                                      .first
                                                                      .profilePic
                                                                      ?.toString() ??
                                                                  ""),
                                                              baseColor: Colors
                                                                  .grey[300]!,
                                                              highlightColor:
                                                                  Colors.grey[
                                                                      100]!,
                                                              child: ClipOval(
                                                                child:
                                                                    Container(
                                                                  width: 100,
                                                                  height: 100,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              image:
                                                                  const DecorationImage(
                                                                image: AssetImage(
                                                                    'assets/noimage.png'),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          ),
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                              Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Text(users.first.flag
                                                          ?.toString() ??
                                                      ""))
                                            ],
                                          ),
                                        );
                                      }),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        // SingleChildScrollView(
                                        //   scrollDirection: Axis.horizontal,
                                        //   child: Row(
                                        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        //     children: [
                                        //       ProfileStat(count: "${users.first.abonnee!.length}", label: 'Followers'.tr,onTap: () =>  SlideNavigation.slideToPage(context, AllUserFollower(uid: widget.uid,)),),
                                        //       SizedBox(width: 10,),
                                        //       ProfileStat(count: "${users.first.abonnement!.length}", label: 'Following'.tr ,onTap: () =>  SlideNavigation.slideToPage(context, AllUserFollowing(uid: widget.uid,)),),
                                        //     ],
                                        //   ),
                                        // ),
                                        // SizedBox(height: 20),
                                        widget.uid == uidUser
                                            ? Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: <Color>[
                                                      newColorBlueElevate,
                                                      newColorGreenDarkElevate
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                          8)), // Bords arrondis
                                                ),
                                                child: ElevatedButton.icon(
                                                  icon: SizedBox.shrink(),
                                                  onPressed: () {
                                                    SlideNavigation.slideToPage(
                                                        context,
                                                        ProfileInformation(
                                                          uid: widget.uid,
                                                          MyOwnData: users,
                                                        ));
                                                  },
                                                  label: Text("Information".tr,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .transparent, // Fond transparent pour laisser voir le gradient
                                                    shadowColor: Colors
                                                        .transparent, // Supprime l'ombre
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 40),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .all(Radius.circular(
                                                              8)), // Angle carré
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    isFollowedNotifier,
                                                builder: (context, isFollowed,
                                                    child) {
                                                  return Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: <Color>[
                                                          newColorBlueElevate,
                                                          newColorGreenDarkElevate
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius
                                                          .all(Radius.circular(
                                                              8)), // Bords arrondis
                                                    ),
                                                    child: ElevatedButton.icon(
                                                      icon: isFollowed
                                                          ? FaIcon(
                                                              FontAwesomeIcons
                                                                  .userSlash,
                                                              size: 15,
                                                              color:
                                                                  Colors.white)
                                                          : FaIcon(
                                                              FontAwesomeIcons
                                                                  .userPlus,
                                                              size: 14,
                                                              color:
                                                                  Colors.white),
                                                      onPressed: () async {
                                                        isFollowedNotifier
                                                                .value =
                                                            !isFollowedNotifier
                                                                .value;
                                                        // Définition d'une attente pour simuler un délai
                                                        // Vérifie si le widget est monté avant d'effectuer des actions
                                                        if (mounted) {
                                                          if (isFollowedNotifier
                                                              .value) {
                                                            // Appel de la fonction abonner
                                                            await ref
                                                                .read(infoUserStateNotifier
                                                                    .notifier)
                                                                .abonner(
                                                                    widget.uid,
                                                                    'dd')
                                                                .then(
                                                                    (onValue) {
                                                              isShowNotificationFollow
                                                                      .value =
                                                                  isFollowedNotifier
                                                                      .value;
                                                            });
                                                          } else {
                                                            // Appel de la fonction desabonner
                                                            await ref
                                                                .read(infoUserStateNotifier
                                                                    .notifier)
                                                                .desabonner(
                                                                    widget.uid,
                                                                    'dd')
                                                                .then(
                                                                    (onValues) {
                                                              isShowNotificationFollow
                                                                      .value =
                                                                  isFollowedNotifier
                                                                      .value;
                                                            });
                                                          }
                                                        }
                                                      },
                                                      label: Text(
                                                          isFollowed
                                                              ? "Suivi(e)".tr
                                                              : "Suivre".tr,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Colors
                                                            .transparent, // Fond transparent pour laisser voir le gradient
                                                        shadowColor: Colors
                                                            .transparent, // Supprime l'ombre
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 40),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      8)), // Angle carré
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Description du profil
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      users.first.name?.toString() ?? "",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(users.first.bio?.toString() ?? ""),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  SlideNavigation.slideToPage(
                                      context,
                                      ListFollowingAndFollowers(
                                        nombrefollower: users
                                            .first.abonnee!.length
                                            .toString(),
                                        nombrefollowing: users
                                            .first.abonnement!.length
                                            .toString(),
                                        uid: widget.uid,
                                        nom: userName.value,
                                        optionSelected: "Followers",
                                      ));
                                },
                                child: ValueListenableBuilder<List<String>>(
                                  valueListenable: imageUrlsNotifier,
                                  builder: (context, imageUrls, child) {
                                    return Text(
                                      "${users.first.abonnee!.length} Followers . ${users.first.abonnement!.length} Following",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  SlideNavigation.slideToPage(
                                      context,
                                      ListFollowingAndFollowers(
                                        nombrefollower: users
                                            .first.abonnee!.length
                                            .toString(),
                                        nombrefollowing: users
                                            .first.abonnement!.length
                                            .toString(),
                                        uid: widget.uid,
                                        nom: userName.value,
                                        optionSelected: "Followers",
                                      ));
                                },
                                child: ValueListenableBuilder<List<String>>(
                                  valueListenable: imageUrlsNotifier,
                                  builder: (context, imageUrls, child) {
                                    return OverlappingAvatars(
                                      imageUrls: imageUrls,
                                      imageSize: 30,
                                      overlapOffset: 20,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // SliverPersistentHeader pour le TabBar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          indicatorColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          controller: _tabController,
                          tabs: [
                            Tab(
                                icon: Icon(
                              Icons.grid_on_outlined,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            )),
                            Tab(
                                icon: Icon(
                              Icons.image_outlined,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            )),
                          ],
                        ),
                      ),
                    ),

                    // Contenu des onglets
                    SliverFillRemaining(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Première section - affichage en grille
                          FirestorePagination(
                            isLive: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            limit: 15, // Defaults to 10.
                            viewType: ViewType.grid,
                            bottomLoader: SizedBox(),
                            initialLoader: Loading(),
                            query: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('HighLight')
                                .orderBy(FieldPath.documentId,
                                    descending: true),
                            itemBuilder: (context, documentSnapshot, index) {
                              final data = documentSnapshot.data()
                                  as Map<String, dynamic>?;
                              if (data == null) return Container();
                              // Récupération sécurisée des données de `collectionData`
                              var collectionData = data;
                              var collectionDataInside =
                                  (collectionData['data'] is List &&
                                          collectionData['data'].isNotEmpty)
                                      ? collectionData['data'][0]
                                      : {};

                              // Sécurisation des champs avec valeurs par défaut
                              String type =
                                  collectionData['type']?.toString() ??
                                      'Inconnu';
                              var collectionDataViewer =
                                  collectionData['QuivoirCollection'] ?? [];

                              String titre =
                                  collectionDataInside['titre']?.toString() ??
                                      'Titre inconnu';
                              int timesent =
                                  collectionDataInside['createdAt'] is int
                                      ? collectionDataInside['createdAt']
                                      : DateTime.now().millisecondsSinceEpoch;

                              String collectionID =
                                  collectionDataInside['collectionId']
                                          ?.toString() ??
                                      'ID inconnu';

                              var photoCollect =
                                  (collectionDataInside['ImagePath'] is List &&
                                          collectionDataInside['ImagePath']
                                              .isNotEmpty)
                                      ? collectionDataInside['ImagePath'][0]
                                                  ['path']
                                              ?.toString() ??
                                          ''
                                      : '';

                              List DataphotoCollect =
                                  collectionDataInside['ImagePath'] is List
                                      ? collectionDataInside['ImagePath']
                                      : [];

                              List QuivoirCollection =
                                  collectionDataViewer is List
                                      ? collectionDataViewer
                                      : [];

                              // Construire l'entité HighlightEntity avec des vérifications
                              HighlightEntity highlight = HighlightEntity(
                                data: collectionData['data'] is List
                                    ? [collectionData['data'][0]]
                                    : [collectionData['data'] ?? {}],
                                profilePic:
                                    data['profilePic']?.toString() ?? '',
                                QuivoirCollection: QuivoirCollection.map((e) =>
                                    e is Map<String, dynamic>
                                        ? e
                                        : <String, dynamic>{}).toList(),
                                type: type,
                              );

                              // Vérifiez si l'élément existe déjà dans la liste
                              if (!HighLightList.contains(highlight)) {
                                HighLightList.add(highlight);
                              }
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                columnCount: 3,
                                child: SlideAnimation(
                                  horizontalOffset: 50.0,
                                  child: FadeInAnimation(
                                      child: Stack(
                                    children: [
                                      type == "video"
                                          ? SizedBox(
                                              key: ValueKey(index),
                                              width: 180,
                                              height: 180,
                                              child: StoryThumbnail(
                                                  videoUrl: photoCollect))
                                          : Container(
                                              decoration: BoxDecoration(
                                                //  border: Border.all(color: Colors.grey.shade100, width: 2), // White border
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        1), // Rounded corners
                                              ),
                                              child: ClipRRect(
                                                key: ValueKey(index),
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                                child: CachedNetworkImage(
                                                  key: ValueKey(index),
                                                  imageUrl: photoCollect,
                                                  placeholder: (context, url) {
                                                    return Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300]!,
                                                      highlightColor:
                                                          Colors.grey[100]!,
                                                      child: Container(
                                                        width:
                                                            180, // Set width of each image
                                                        height: 180,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(1),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      image:
                                                          const DecorationImage(
                                                        image: AssetImage(
                                                            'assets/noimage.png'),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                  width:
                                                      180, // Set width of each image
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                      GestureDetector(
                                        onTap: () {
                                          if (widget.uid == uidUser) {
                                            // SlideNavigation.slideToPage(context, HighKightViewForMe(collectionId: collectionID,viewerCollection: QuivoirCollection,titre: titre,data: DataphotoCollect,name: users.first.name.toString(),profile: profilePic,timesent: timesent,type: type,uid: widget.uid,));
                                            SlideNavigation.slideToPage(
                                                context,
                                                HighlightViewForMe(
                                                  uid: widget.uid,
                                                  name: titre,
                                                  stories: HighLightList,
                                                  indexJump: index,
                                                ));
                                          } else {
                                            // SlideNavigation.slideToPage(context, HighlightViewForAll(collectionId: collectionID,viewerCollection: QuivoirCollection,titre: titre,data: DataphotoCollect,name: users.first.name.toString(),profile: profilePic,timesent: timesent,type: type,uid: widget.uid,));
                                            SlideNavigation.slideToPage(
                                                context,
                                                HighlightViewForAll(
                                                  uid: widget.uid,
                                                  name: titre,
                                                  stories: HighLightList,
                                                  indexJump: index,
                                                ));
                                          }
                                        },
                                        child: Container(
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                      ),
                                      Positioned(
                                          top: 6,
                                          left: 12,
                                          child: Text(
                                            DataphotoCollect.length > 1
                                                ? '+ ${DataphotoCollect.length}'
                                                : '',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Positioned(
                                          bottom: 6,
                                          left: 12,
                                          child: Text(
                                            titre.length > 10
                                                ? titre.substring(0, 8)
                                                : titre,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      if (widget.uid == uidUser)
                                        Positioned(
                                            top: 6,
                                            right: 10,
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) => Editerhighlight(
                                                            title:
                                                                TextEditingController(
                                                                    text:
                                                                        titre),
                                                            type:
                                                                type == "image"
                                                                    ? AssetType
                                                                        .image
                                                                    : AssetType
                                                                        .video,
                                                            collectionId:
                                                                collectionID,
                                                            dataActually:
                                                                DataphotoCollect,
                                                            createdAt:
                                                                timesent)),
                                                  );
                                                },
                                                child: FaIcon(
                                                    FontAwesomeIcons
                                                        .penToSquare,
                                                    size: 15,
                                                    color: Colors.white))),
                                    ],
                                  )),
                                ),
                              );
                            },
                            onEmpty: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 130,
                                        height: 130,
                                        child: Image.asset(
                                          'assets/galerie-dimages (1).png',
                                        )),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    // Text(
                                    //   textAlign: TextAlign.center,
                                    //   "Aucun Photo".tr,
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.bold,
                                    //       fontSize: 20),
                                    // ),
                                    // SizedBox(
                                    //   height: 2,
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(
                                        "Il n'y a pas encore de highlights à découvrir en ce moment"
                                            .tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16),
                                      ),
                                    ),
                                    if (widget.uid == uidUser)
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Createhighlight(),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              "Créer nouveau".tr,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: kPrimaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Container(
                                              width: 40,
                                              height: 3,
                                              decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15))),
                                            )
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 5.0,
                                    crossAxisSpacing: 3.0,
                                    mainAxisExtent: 180),
                          ),

                          // Deuxième section - pour les reels ou autres contenus
                          FirestorePagination(
                            isLive: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            limit: 15, // Defaults to 10.
                            viewType: ViewType.grid,
                            bottomLoader: SizedBox(),
                            initialLoader: Loading(),
                            query: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('photoProfile')
                                .orderBy('timeCreated', descending: true),
                            itemBuilder: (context, documentSnapshot, index) {
                              final data = documentSnapshot.data()
                                  as Map<String, dynamic>?;
                              if (data == null) return Container();
                              // Récupération sécurisée de `urlPhoto` avec une valeur par défaut
                              String urlPhoto =
                                  data['urlPhoto']?.toString() ?? '';

                              // Récupération sécurisée de `timeCreated` avec une valeur par défaut (timestamp actuel si null ou invalide)
                              int timeCreated = data['timeCreated'] is int
                                  ? data['timeCreated']
                                  : DateTime.now().millisecondsSinceEpoch;

                              // Conversion en `DateTime` en utilisant le `timeCreated`
                              DateTime dateTime =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      timeCreated);

                              // Formatage de la date avec `DateFormat`, par exemple "Sep 22, 2024"
                              String dateCreer =
                                  DateFormat.yMMMd().format(dateTime);

                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                columnCount: 3,
                                child: SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      1), // Rounded corners
                                            ),
                                            child: ClipRRect(
                                              key: ValueKey(index),
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                              child: CachedNetworkImage(
                                                key: ValueKey(index),
                                                imageUrl: urlPhoto,
                                                placeholder: (context, url) {
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      width: 180,
                                                      height: 180,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(1),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    image:
                                                        const DecorationImage(
                                                      image: AssetImage(
                                                          'assets/noimage.png'),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                                width:
                                                    180, // Set width of each image
                                                height:
                                                    180, // Set height of each image
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              SlideNavigation.slideToPage(
                                                  context,
                                                  DetailScreen(
                                                    uidUser: widget.uid,
                                                    isProfilePhoto: true,
                                                    filename: urlPhoto,
                                                    extension: '.no',
                                                  ));
                                            },
                                            child: Container(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 6,
                                              left: 12,
                                              child: Text(
                                                dateCreer.toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ))
                                        ],
                                      ),
                                    )),
                              );
                            },
                            onEmpty: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 110,
                                        height: 110,
                                        child: Image.asset(
                                          'assets/galerie-dimages.png',
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      textAlign: TextAlign.center,
                                      "Aucun Photo".tr,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    // SizedBox(
                                    //   height: 2,
                                    // ),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(
                                    //       horizontal: 15),
                                    //   child: Text(
                                    //     "Il n'y a pas encore de photo à découvrir en ce moment"
                                    //         .tr,
                                    //     textAlign: TextAlign.center,
                                    //     style: TextStyle(
                                    //         fontWeight: FontWeight.w400,
                                    //         fontSize: 16),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            //  SizedBox(height: 5,),
                            //  Text( titre.length > 9 ? '${titre.substring(0, 9)}...' : titre)
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 1.0,
                                    crossAxisSpacing: 1.0,
                                    mainAxisExtent: 180),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Center(child: Text("Aucune donnée disponible".tr));
              }
            },
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.endDocked, // Centre en bas
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: FloatingActionButton(
            backgroundColor: kPrimaryColor,
            onPressed: () => widget.uid == uidUser
                ? _showMoreOption(
                    widget.uid,
                    userName.value,
                    userDataGet.value,
                    notifier.MydataPersiste!.abonnee!.length.toString(),
                    notifier.MydataPersiste!.abonnement!.length.toString(),
                  )
                : Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => MessageDetail(
                        urlPhoto: userProfilePic.value,
                        uid: userUid.value,
                        name: userName.value,
                      ),
                    ),
                  ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Coins arrondis
            ),
            heroTag: null,
            child: widget.uid == uidUser
                ? FaIcon(
                    FontAwesomeIcons.ellipsis,
                    size: 20,
                    color: Colors.white,
                  )
                : SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset(
                      'assets/message-de-chat.png',
                      color: Colors.white,
                    )), // Utilisé pour éviter les conflits de héros
          ),
        ),
      ),
    );
  }

  _showMoreOptionNotification(
      String userUid, List<String> dataSendNotificationByUser) async {
    // Vérifie si le userUid est dans la liste
    bool isSubscribed = dataSendNotificationByUser.contains(uidUser);

    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 5,
            right: 5,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                  child: Text(
                    "Notification".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                Divider(thickness: 0.7),

                // Option "Tout"
                Padding(
                  padding: const EdgeInsets.only(left: 1, top: 1),
                  child: ListTile(
                    onTap: () async {
                      Navigator.pop(context);
                      await ref
                          .read(infoUserStateNotifier.notifier)
                          .addReceiveNotification(widget.uid, 'dd');
                    },
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.grey.shade300,
                      ),
                      child: Center(
                        child: FaIcon(FontAwesomeIcons.solidBell,
                            size: 17, color: Colors.black),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tout'.tr,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            if (isSubscribed) Icon(Icons.check),
                          ],
                        ),
                        Text(
                          "Recevoir_toutes_notifications".tr,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 5),

                // Option "Aucune"
                Padding(
                  padding: const EdgeInsets.only(left: 1, top: 1),
                  child: ListTile(
                    onTap: () async {
                      Navigator.pop(context);
                      await ref
                          .read(infoUserStateNotifier.notifier)
                          .removeReceiveNotification(widget.uid, 'dd');
                    },
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.grey.shade300,
                      ),
                      child: Center(
                        child: FaIcon(FontAwesomeIcons.solidBellSlash,
                            size: 17, color: Colors.black),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Aucune'.tr,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            if (!isSubscribed) Icon(Icons.check),
                          ],
                        ),
                        Text(
                          "Désactiver_toutes_notifications".tr,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 5),

                // Option "Se désabonner"
                Padding(
                  padding: const EdgeInsets.only(left: 1, top: 1),
                  child: ListTile(
                    onTap: () async {
                      Navigator.pop(context);
                      await ref
                          .read(infoUserStateNotifier.notifier)
                          .desabonner(widget.uid, 'dd')
                          .then((onValues) {
                        isFollowedNotifier.value = false;
                        isShowNotificationFollow.value = false;
                      });
                      // setState(() {});
                    },
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.grey.shade300,
                      ),
                      child: Center(
                        child: FaIcon(FontAwesomeIcons.userSlash,
                            size: 17, color: Colors.black),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('desabonner'.tr,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          "Annuler_abonnement".tr,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showMoreOption(String userUid, String name, List<UserEntity> MyOwnData,
      String nombrefollower, String nombrefollowing) async {
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
                    if (userUid != uidUser)
                      StreamBuilder(
                          stream: ref
                              .read(chatStateNotifier(userUid).notifier)
                              .getStatusBlock(userUid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox();
                            }
                            var statusBlock = snapshot.data ?? false;
                            return statusBlock == true
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(left: 1, top: 1),
                                    child: ListTile(
                                      onTap: () {
                                        if (mounted) {
                                          ref
                                              .read(chatStateNotifier(userUid)
                                                  .notifier)
                                              .debloquerConversation(userUid);
                                        }
                                        Navigator.pop(context);
                                      },
                                      leading: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                            color: Colors.grey.shade300,
                                          ),
                                          child: Center(
                                              child: FaIcon(
                                            FontAwesomeIcons.solidTrashCan,
                                            size: 17,
                                            color: Colors.black,
                                          ))),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$debloquer $name',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "$optionpermet $name $appeler",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding:
                                        const EdgeInsets.only(left: 1, top: 1),
                                    child: ListTile(
                                      onTap: () {
                                        if (mounted) {
                                          ref
                                              .read(chatStateNotifier(userUid)
                                                  .notifier)
                                              .bloquerConversation(userUid);
                                        }
                                        Navigator.pop(context);
                                      },
                                      leading: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                            color: Colors.grey.shade300,
                                          ),
                                          child: Center(
                                              child: FaIcon(
                                            FontAwesomeIcons.solidTrashCan,
                                            size: 17,
                                            color: Colors.black,
                                          ))),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$bloquer $name',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "$optionpermet $name $appeler",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                          }),
                    if (userUid == uidUser)
                      SizedBox(
                        height: 2.0,
                      ),
                    if (userUid == uidUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 1, top: 1),
                        child: ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            SlideNavigation.slideToPage(
                                context,
                                ListFollowingAndFollowers(
                                  uid: widget.uid,
                                  nom: userName.value,
                                  nombrefollower: nombrefollower,
                                  nombrefollowing: nombrefollowing,
                                  optionSelected: "Followers",
                                ));
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
                                FontAwesomeIcons.person,
                                size: 17,
                                color: Colors.black,
                              ))),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Followers'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Découvrez les personnes qui vous suivent et sont intéressées par vos activités."
                                    .tr,
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (userUid == uidUser)
                      SizedBox(
                        height: 2.0,
                      ),
                    if (userUid == uidUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 1, top: 1),
                        child: ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            SlideNavigation.slideToPage(
                                context,
                                ListFollowingAndFollowers(
                                  uid: widget.uid,
                                  nom: userName.value,
                                  nombrefollower: nombrefollower,
                                  nombrefollowing: nombrefollowing,
                                  optionSelected: "Following",
                                ));
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
                                FontAwesomeIcons.person,
                                size: 17,
                                color: Colors.black,
                              ))),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Following'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Découvrez les liste des personnes que vous suivez pour rester connecté à leurs dernières actualités."
                                    .tr,
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (userUid == uidUser)
                      SizedBox(
                        height: 2.0,
                      ),
                    if (userUid == uidUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 1, top: 1),
                        child: ListTile(
                          onTap: () async {
                            Navigator.pop(context);
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (context) => Createhighlight(),
                              ),
                            );
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
                                FontAwesomeIcons.photoFilm,
                                size: 17,
                                color: Colors.black,
                              ))),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Créez et partagez vos HighLight'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Ajoutez vos meilleurs souvenirs à vos Highlights"
                                    .tr,
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 1, top: 1),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          SlideNavigation.slideToPage(
                              context,
                              ProfileInformation(
                                uid: widget.uid,
                                MyOwnData: MyOwnData,
                              ));
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
                              FontAwesomeIcons.person,
                              size: 17,
                              color: Colors.black,
                            ))),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Information'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Découvrez les détails essentiels".tr,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (userUid != uidUser)
                      SizedBox(
                        height: 2.0,
                      ),
                    if (userUid != uidUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 1, top: 1),
                        child: ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            SlideNavigation.slideToPage(
                                context,
                                SignalerProfile(
                                  uidSignal: userUid,
                                ));
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
                                FontAwesomeIcons.person,
                                size: 17,
                                color: Colors.black,
                              ))),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Signaler_profil'.tr,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Indiquez_raison".tr,
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      )
                  ]),
            ),
          )),
    );
  }

  _showMoreOption4(
    String userUid,
    String nombrefollower,
    String nombrefollowing,
  ) async {
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
                          SlideNavigation.slideToPage(
                              context,
                              ListFollowingAndFollowers(
                                nombrefollower: nombrefollower,
                                nombrefollowing: nombrefollowing,
                                uid: widget.uid,
                                nom: userName.value,
                                optionSelected: "Followers",
                              ));
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
                              FontAwesomeIcons.userPlus,
                              size: 17,
                              color: Colors.black,
                            ))),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Followers'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Découvrez les personnes qui vous suivent et sont intéressées par vos activités."
                                  .tr,
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
                          SlideNavigation.slideToPage(
                              context,
                              ListFollowingAndFollowers(
                                nombrefollower: nombrefollower,
                                nombrefollowing: nombrefollowing,
                                uid: widget.uid,
                                nom: userName.value,
                                optionSelected: "Following",
                              ));
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
                              FontAwesomeIcons.userPlus,
                              size: 17,
                              color: Colors.black,
                            ))),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Following'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Découvrez les liste des personnes que vous suivez pour rester connecté à leurs dernières actualités."
                                  .tr,
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

  _showMoreOption2(String urlPhoto, String urlPhotoStorie,
      List<StorieEntity> storieList, String userUid) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Wrap(
          children: [
            if (urlPhoto.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 1, top: 1),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    SlideNavigation.slideToPage(
                      context,
                      DetailScreen(
                        uidUser: widget.uid,
                        isProfilePhoto: true,
                        filename: urlPhoto.toString(),
                        extension: '.no',
                      ),
                    );
                  },
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.grey.shade300,
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.eye,
                        size: 17,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voir_photo_profile'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 5),
            if (widget.uid == uidUser)
              Padding(
                padding: const EdgeInsets.only(left: 1, top: 1),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    SlideNavigation.slideToPage(
                      context,
                      Modifierprofile(
                        uid: widget.uid,
                        profilePic: urlPhoto,
                      ),
                    );
                  },
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.grey.shade300,
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.pencil,
                        size: 17,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modifier_photo_profile'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 5),
            if (urlPhotoStorie.isNotEmpty && storieList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 1, top: 1),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.uid == uidUser) {
                      SlideNavigation.slideToPage(context,
                          StoryViewForMe(indexJump: 0, stories: storieList));
                    } else {
                      SlideNavigation.slideToPage(context,
                          StoryViewForAll(indexJump: 0, stories: storieList));
                    }
                  },
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.grey.shade300,
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.image,
                        size: 17,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voir les story'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.uid == uidUser) SizedBox(height: 5),
            if (widget.uid == uidUser && urlPhoto.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 1, top: 1),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    if (mounted) {
                      ref
                          .read(infoUserStateNotifier.notifier)
                          .deletePhotProfile(userUid, "");
                    }
                  },
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.grey.shade300,
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.trash,
                        size: 17,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'supprimer'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Delegate pour SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Widget pour les statistiques du profil
class ProfileStat extends StatelessWidget {
  final String count;
  final String label;
  final GestureTapCallback onTap;

  const ProfileStat(
      {super.key,
      required this.count,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }
}
