import 'package:cached_network_image/cached_network_image.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ContactCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> contactSource;
  final VoidCallback onTap;
  final bool isAbonne;

  const ContactCard({
    super.key,
    required this.contactSource,
    required this.onTap,
    required this.isAbonne,
  });

  @override
  _ContactCardState createState() => _ContactCardState();
}

class _ContactCardState extends ConsumerState<ContactCard> {
  late bool isFollowed = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isFollowed = widget.isAbonne;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  _showMoreOption4(String userUid, BuildContext context) async {
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
                        onTap: () async {
                          Navigator.pop(context);
                          // SlideNavigation.slideToPage(context, AllUserFollower(uid: widget.uid,));
                          setState(() {
                            isFollowed = !isFollowed; // Change l'état du suivi
                          });
                          await Future.delayed(const Duration(seconds: 1), () {
                            if (isFollowed == true) {
                              ref
                                  .read(infoUserStateNotifier.notifier)
                                  .abonner(widget.contactSource['uid'], 'dd');
                            } else {
                              ref
                                  .read(infoUserStateNotifier.notifier)
                                  .desabonner(
                                      widget.contactSource['uid'], 'dd');
                            }
                          });
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
                                child: isFollowed
                                    ? FaIcon(FontAwesomeIcons.userSlash,
                                        size: 17, color: Colors.black)
                                    : FaIcon(FontAwesomeIcons.userPlus,
                                        size: 17, color: Colors.black))),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFollowed ? "Suivi(e)".tr : "Suivre".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isFollowed
                                  ? "Vous_suivez_déjà".tr
                                  : "Soyez_informe".tr,
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
                          if (widget.contactSource['hiddenPosition'] == false &&
                              widget.contactSource['hiddenPosition'] != null) {
                            _showUserLocationModal(
                                context,
                                widget.contactSource['position']['geopoint'],
                                widget.contactSource['profilePic'],
                                widget.contactSource['pays'],
                                widget.contactSource['nationalite'],
                                widget.contactSource['flag']);
                          }
                        },
                        leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.grey.shade300,
                            ),
                            child: (widget.contactSource['hiddenPosition'] ==
                                        false &&
                                    widget.contactSource['hiddenPosition'] !=
                                        null)
                                ? Center(
                                    child: FaIcon(
                                    FontAwesomeIcons.locationDot,
                                    size: 17,
                                    color: Colors.black,
                                  ))
                                : Center(
                                    child: FaIcon(
                                    FontAwesomeIcons.locationPinLock,
                                    size: 17,
                                    color: Colors.black,
                                  ))),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (widget.contactSource['hiddenPosition'] == false &&
                                    widget.contactSource['hiddenPosition'] !=
                                        null)
                                ? Text(
                                    'Voir_localisation'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    'Localisation_masquée'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            (widget.contactSource['hiddenPosition'] == false &&
                                    widget.contactSource['hiddenPosition'] !=
                                        null)
                                ? Text(
                                    "choisi_partager_localisation".tr,
                                    style: TextStyle(fontSize: 15),
                                  )
                                : Text(
                                    "préféré_ne_pas_partager_localisation".tr,
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

  @override
  Widget build(BuildContext context) {
    String uidUser = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uidUser != widget.contactSource['uid']) {
      return ListTile(
        onLongPress: () =>
            _showMoreOption4(widget.contactSource['uid'], context),
        key: ValueKey(widget.contactSource['uid']),
        onTap: widget.onTap,
        contentPadding: const EdgeInsets.only(left: 15, right: 15, top: 2),
        leading: Stack(
          children: [
            widget.contactSource['profilePic'].isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.contactSource['profilePic'],
                    imageBuilder: (context, imageProvider) => Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      height: 50.0,
                      width: 50.0,
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
                      margin: const EdgeInsets.only(right: 8.0),
                      height: 50.0,
                      width: 50.0,
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
                    errorWidget: (context, url, error) => Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      height: 50.0,
                      width: 50.0,
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
                  )
                : Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/noimage.png'),
                        fit: BoxFit.cover,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
            Positioned(
              bottom: 0,
              right: 10,
              child: Text(
                widget.contactSource['flag'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            )
          ],
        ),
        title: Text(
          widget.contactSource['name'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
            onPressed: () =>
                _showMoreOption4(widget.contactSource['uid'], context),
            icon: FaIcon(
              FontAwesomeIcons.ellipsis,
              size: 20,
            )),
      );
    } else {
      return const SizedBox();
    }
  }
}

// ZegoSendCallInvitationButton buttonAppelAudio(String uidUser, String nameUser,
//     Color? color, Color? colorIcon, double sizeIcon) {
//   return ZegoSendCallInvitationButton(
//     isVideoCall: false,
//     resourceID: "zegouikit_call",
//     invitees: [
//       ZegoUIKitUser(
//         id: uidUser,
//         name: nameUser,
//       ),
//     ],
//     icon: ButtonIcon(
//       icon: FaIcon(
//         FontAwesomeIcons.phone,
//         size: sizeIcon,
//         color: colorIcon,
//       ),
//     ),
//     buttonSize: const Size(35, 35),
//     clickableBackgroundColor: color ?? Colors.grey.shade200,
//     borderRadius: 30,
//     iconSize: const Size(20, 20),
//     onPressed: (String code, String message, List<String> errorInvitees) {
//       // Gestion des erreurs...
//     },
//   );
// }

// ZegoSendCallInvitationButton buttonAppelVideo(String uidUser, String nameUser,
//     Color? color, Color? colorIcon, double sizeIcon) {
//   return ZegoSendCallInvitationButton(
//     isVideoCall: true,
//     resourceID: "zegouikit_call",
//     invitees: [
//       ZegoUIKitUser(
//         id: uidUser,
//         name: nameUser,
//       ),
//     ],
//     icon: ButtonIcon(
//       icon: FaIcon(
//         FontAwesomeIcons.video,
//         size: sizeIcon,
//         color: colorIcon,
//       ),
//     ),
//     buttonSize: const Size(35, 35),
//     borderRadius: 30,
//     iconSize: const Size(20, 20),
//     clickableBackgroundColor: color ?? Colors.grey.shade200,
//     onPressed: (String code, String message, List<String> errorInvitees) {
//       // Gestion des erreurs...
//     },
//   );
// }

Future<BitmapDescriptor> loadMarkerFromUrl(String url) async {
  try {
    final BitmapDescriptor icon = await MarkerIcon.downloadResizePictureCircle(
      url,
      size: 120,
      addBorder: true,
      borderColor: Colors.red,
      borderSize: 20,
    );
    return icon;
  } catch (e) {
    print("Erreur : $e");
    return BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(550, 550)),
      'assets/pointer.png',
    ); // Retourne un marqueur par défaut en cas d'erreur
  }
}

void _showUserLocationModal(BuildContext context, GeoPoint pos, String photo,
    String pays, String nationalite, String flag) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FutureBuilder<BitmapDescriptor>(
        future: loadMarkerFromUrl(photo), // Charge l'icône du marqueur
        builder: (context, snapshot) {
          // Affiche un indicateur de chargement tant que la future n'est pas terminée
          if (!snapshot.hasData) {
            return SizedBox(
              height: 250,
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }

          // Une fois l'icône chargée, on affiche la carte avec le marqueur
          final currentPositionMarker = Marker(
            markerId: MarkerId('current_position'),
            position: LatLng(pos.latitude, pos.longitude),
            icon: snapshot.data!, // Utilise l'icône chargée
          );

          return Padding(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        GoogleMap(
                          circles: <Circle>{
                            Circle(
                              circleId: CircleId('search_circle'),
                              center: LatLng(pos.latitude, pos.longitude),
                              radius: 7000,
                              fillColor: Colors.blue.withOpacity(0.1),
                              strokeColor: Colors.blue,
                              strokeWidth: 1,
                            ),
                          },
                          zoomControlsEnabled:
                              false, // Désactive les boutons de zoom
                          scrollGesturesEnabled:
                              true, // Autorise le déplacement de la carte
                          rotateGesturesEnabled:
                              false, // Désactive la rotation de la carte
                          tiltGesturesEnabled:
                              false, // Désactive l'inclinaison de la carte
                          myLocationButtonEnabled:
                              false, // Désactive le bouton "ma position"
                          initialCameraPosition: CameraPosition(
                            target: LatLng(pos.latitude, pos.longitude),
                            zoom: 10.5,
                          ),
                          markers: {currentPositionMarker},
                        ),
                        if (snapshot.hasData)
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FaIcon(FontAwesomeIcons.locationDot,
                                            color: Colors.red, size: 14),
                                        SizedBox(width: 5),
                                        Text(pays,
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text("$flag $nationalite",
                                        style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                            top: 10,
                            left: 10,
                            child: Text(
                              'Approximation',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
