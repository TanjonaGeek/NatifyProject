import 'package:animated_dashed_circle/animated_dashed_circle.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/Chat/presentation/pages/messageDetail.dart';
import 'package:natify/features/Chat/presentation/widget/display_reply_message.dart';
import 'package:natify/features/Storie/domaine/entities/storie_entities.dart';
import 'package:natify/features/Storie/presentation/pages/storieViewForMe.dart';
import 'package:natify/features/Storie/presentation/pages/storyViewForAll.dart';
import 'package:natify/features/User/presentation/pages/map/filterListOfUser.dart';
import 'package:natify/features/User/presentation/pages/userProfilePage.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class Listeutilisateuraproximite extends ConsumerStatefulWidget {
  const Listeutilisateuraproximite({super.key});
  @override
  _ListeutilisateuraproximiteState createState() =>
      _ListeutilisateuraproximiteState();
}

class _ListeutilisateuraproximiteState
    extends ConsumerState<Listeutilisateuraproximite> {
  bool isUserSubscribed(String uid, List<dynamic> subscribedUids) {
    // Convertir la List<dynamic> en Set<String> pour améliorer les performances
    Set<String> subscribedUidsSet =
        Set<String>.from(subscribedUids.whereType<String>());

    return subscribedUidsSet.contains(uid);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(mapsUserStateNotifier);
    String uidUsers = FirebaseAuth.instance.currentUser?.uid ?? "";
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Proximité'.tr,
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Center(
                    child: FaIcon(FontAwesomeIcons.chevronLeft, size: 20))),
            onPressed: () {
              // Action for the back button
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: FaIcon(FontAwesomeIcons.filterCircleXmark, size: 20),
              onPressed: () {
                SlideNavigation.slideToPage(context, FilterPage());
              },
            ),
          ],
        ),
        body: Consumer(
          builder: ((context, ref, child) {
            return notifier.listAllUserApproximite.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 130,
                              height: 130,
                              child: Image.asset('assets/earth.png',
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Aucun résultat".tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "Personne n'a été trouvé dans votre zone. Essayez de modifier vos critères de recherche."
                                  .tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Utilisateurs proches de vous, visibles dans la zone sélectionnée pour faciliter les connexions."
                              .tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Container(
                        child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 5.0,
                                    crossAxisSpacing: 5.0,
                                    mainAxisExtent: 220),
                            padding: const EdgeInsets.all(8.0),
                            itemCount: notifier.listAllUserApproximite.length,
                            itemBuilder: (context, index) {
                              bool estAbonne = isUserSubscribed(
                                  uidUsers,
                                  notifier.listAllUserApproximite[index]
                                      ['abonnee']);
                              return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  columnCount: 3,
                                  child: SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: CardUserProximity(
                                          notifiers:
                                              notifier.listAllUserApproximite,
                                          index: index,
                                          isAbonne: estAbonne,
                                        ),
                                      )));
                            }),
                      )
                    ],
                  );
          }),
        ),
      ),
    );
  }

  Widget _buildOption({
    required Widget icon,
    required String title,
    required int value,
  }) {
    return ListTile(
      leading: icon,
      title: Text(title),
      trailing: Icon(Icons.arrow_right_sharp),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 1.0, horizontal: 7.0),
    );
  }
}

class CardUserProximity extends ConsumerStatefulWidget {
  const CardUserProximity({
    super.key,
    required this.index,
    required this.notifiers,
    required this.isAbonne,
  });

  final int index;
  final List<Map<String, dynamic>> notifiers;
  final bool isAbonne;

  @override
  ConsumerState<CardUserProximity> createState() => _CardUserProximityState();
}

class _CardUserProximityState extends ConsumerState<CardUserProximity> {
  late bool isFollowed = false;
  String uidUser = FirebaseAuth.instance.currentUser?.uid ?? "";
  @override
  void initState() {
    super.initState();
    setState(() {
      isFollowed = widget.isAbonne;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            //  color: Colors.white,
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(color: Colors.transparent)
                : Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.all(Radius.circular(6))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<Map<String, dynamic>>(
                future: ref
                    .read(allUserListStateNotifier.notifier)
                    .checkifHasStorie(widget.notifiers[widget.index]['uid']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Shimmer.fromColors(
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

                  bool hasStorie = snapshot.data!['hasStorie'];
                  return GestureDetector(
                    onTap: () async {
                      List<StorieEntity> storieList = [];
                      if (hasStorie == true) {
                        StorieEntity storie = StorieEntity(
                          uid: snapshot.data!['data'].uid,
                          username: snapshot.data!['data'].username,
                          photoUrl: List<Map<String, dynamic>>.from(snapshot
                              .data!['data']
                              .photoUrl), // Utiliser les photos complètes pour l'entité
                          createdAt: snapshot.data!['data'].createdAt,
                          profilePic: snapshot.data!['data'].profilePic,
                          statusId: snapshot.data!['data'].statusId,
                          QuivoirStorie: List<Map<String, dynamic>>.from(
                              snapshot.data!['data'].QuivoirStorie),
                          storyAvailableForUser: List<String>.from(
                              snapshot.data!['data'].storyAvailableForUser),
                        );
                        List<Map<String, dynamic>> photoUrl =
                            snapshot.data!['data'].photoUrl;
                        storieList.add(storie);
                        await Future.delayed(const Duration(milliseconds: 50));
                        _showMoreOption2(
                            widget.notifiers[widget.index]['uid'],
                            widget.notifiers[widget.index]['photoUser']
                                .toString(),
                            photoUrl.last['url'],
                            storieList);
                      } else {
                        SlideNavigation.slideToPage(
                            context,
                            DetailScreen(
                              filename: widget.notifiers[widget.index]
                                      ['photoUser']
                                  .toString(),
                              extension: '.no',
                            ));
                      }
                    },
                    child: Stack(
                      children: [
                        hasStorie
                            ? AnimatedDashedCircle().show(
                                image: widget.notifiers[widget.index]
                                            ['photoUser']
                                        .toString()
                                        .isEmpty
                                    ? AssetImage('assets/noimage.png')
                                    : CachedNetworkImageProvider(
                                        "${widget.notifiers[widget.index]['photoUser']}"),
                                contentPadding: 04,
                                autoPlay: true,
                                duration: const Duration(seconds: 5),
                                height: 100,
                                borderWidth: 8,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors
                                          .white, // Condition pour la bordure bleue
                                      width: 3, // Épaisseur de la bordure
                                    ),
                                    shape: BoxShape.circle),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    key: ValueKey(
                                        widget.notifiers[widget.index]['uid']),
                                    imageUrl:
                                        '${widget.notifiers[widget.index]['photoUser']}',
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      // margin: EdgeInsets.only(right: 8.0),
                                      height: 90.0,
                                      width: 90.0,
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
                                      // margin: EdgeInsets.only(right: 8.0),
                                      height: 90.0,
                                      width: 90.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        image: DecorationImage(
                                          image:
                                              AssetImage('assets/noimage.png'),
                                          fit: BoxFit.cover,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      // margin: EdgeInsets.only(right: 8.0),
                                      height: 90.0,
                                      width: 90.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        image: DecorationImage(
                                          image:
                                              AssetImage('assets/noimage.png'),
                                          fit: BoxFit.cover,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 10,
                          child: Text(
                            '${widget.notifiers[widget.index]['flag']}',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  );
                }),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(
                        uid: widget.notifiers[widget.index]['uid'].toString()),
                  ),
                );
              },
              child: Text(
                '${widget.notifiers[widget.index]['name']}',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            widget.notifiers[widget.index]['hiddenPosition'] == false
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gesture_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${widget.notifiers[widget.index]['distance']} Km',
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ],
                  )
                : FaIcon(FontAwesomeIcons.locationPinLock,
                    size: 14, color: Colors.grey.shade500),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                              child: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          isFollowed =
                                              !isFollowed; // Change l'état du suivi
                                        });
                                        await Future.delayed(
                                            const Duration(seconds: 1), () {
                                          if (isFollowed == true) {
                                            ref
                                                .read(infoUserStateNotifier
                                                    .notifier)
                                                .abonner(
                                                    widget.notifiers[
                                                        widget.index]['uid'],
                                                    'dd');
                                          } else {
                                            ref
                                                .read(infoUserStateNotifier
                                                    .notifier)
                                                .desabonner(
                                                    widget.notifiers[
                                                        widget.index]['uid'],
                                                    'dd');
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: isFollowed
                                                ? Colors.transparent
                                                : kPrimaryColor,
                                            border: Border.all(
                                                color: isFollowed
                                                    ? Colors.white
                                                    : kPrimaryColor),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Text(
                                                  isFollowed
                                                      ? "Suivi(e)".tr
                                                      : "Suivre".tr,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: isFollowed
                                                          ? Colors.white
                                                          : Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          isFollowed =
                                              !isFollowed; // Change l'état du suivi
                                        });
                                        await Future.delayed(
                                            const Duration(seconds: 1), () {
                                          if (isFollowed == true) {
                                            ref
                                                .read(infoUserStateNotifier
                                                    .notifier)
                                                .abonner(
                                                    widget.notifiers[
                                                        widget.index]['uid'],
                                                    'dd');
                                          } else {
                                            ref
                                                .read(infoUserStateNotifier
                                                    .notifier)
                                                .desabonner(
                                                    widget.notifiers[
                                                        widget.index]['uid'],
                                                    'dd');
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: isFollowed
                                                ? Colors.transparent
                                                : kPrimaryColor,
                                            border: Border.all(
                                                color: isFollowed
                                                    ? Colors.black45
                                                    : kPrimaryColor),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Text(
                                                  isFollowed
                                                      ? "Suivi(e)".tr
                                                      : "Suivre".tr,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: isFollowed
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                          SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) => MessageDetail(
                                    urlPhoto: widget.notifiers[widget.index]
                                            ['photoUser']
                                        .toString(),
                                    uid: widget.notifiers[widget.index]['uid']
                                        .toString(),
                                    name: widget.notifiers[widget.index]['name']
                                        .toString(),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Border.all(color: Colors.white)
                                        : Border.all(color: Colors.black54),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: FaIcon(FontAwesomeIcons.message,
                                      size: 18,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : newColorGreenDarkElevate),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  _showMoreOption2(String uid, String urlPhoto, String urlPhotoStorie,
      List<StorieEntity> storieList) async {
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
            Padding(
              padding: const EdgeInsets.only(left: 1, top: 1),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  SlideNavigation.slideToPage(
                    context,
                    DetailScreen(
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
                    color: Colors.grey.shade200,
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
                      'Voir Photo de profil',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 1, top: 1),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  if (uid == uidUser) {
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
                    color: Colors.grey.shade200,
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
                      'Voir la storie',
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
