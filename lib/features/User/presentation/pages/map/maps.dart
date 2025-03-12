import 'dart:async';

import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/pages/map/filterListOfUser.dart';
import 'package:natify/features/User/presentation/pages/map/listeUserApproximiteParNationalite.dart';
import 'package:natify/features/User/presentation/pages/map/listeUtilisateurAproximite.dart';
import 'package:natify/features/User/presentation/pages/map/searchByPlace.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Maps extends ConsumerStatefulWidget {
  final bool statusShareDistance;
  final String photoUrl;
  const Maps(
      {super.key, required this.statusShareDistance, required this.photoUrl});

  @override
  ConsumerState<Maps> createState() => _MapsState();
}

class _MapsState extends ConsumerState<Maps>
    with AutomaticKeepAliveClientMixin<Maps> {
  final Completer<GoogleMapController> _controller = Completer();
  bool isChecked = false;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isChecked = widget.statusShareDistance;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getPosition();
    });
  }

  Future<bool> _showAlertDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(
                "annonce".tr.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                "annonce_phrase".tr,
                style: TextStyle(fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "OK".tr,
                    style: TextStyle(color: kPrimaryColor),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _getPosition() async {
    try {
      // Charger l'icône personnalisée avant d'obtenir la position
      await ref
          .read(mapsUserStateNotifier.notifier)
          .loadMarkerFromUrl(widget.photoUrl.toString())
          .then((onValue) async {
        // Obtenir la position et ajouter le marqueur
        await ref
            .read(mapsUserStateNotifier.notifier)
            .transferDataPrefToNotifer();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        double? Latitude = prefs.getDouble('latitude') ?? 0.0;
        double? Longitude = prefs.getDouble('longitude') ?? 0.0;
        if (Latitude == 0.0 && Longitude == 0.0) {
          await Future.delayed(Duration(seconds: 2));

          /// Attendre que l'UI soit prête avant d'afficher l'alerte
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAlertDialog(context);
          });
        }
      });
    } catch (e) {
      print("Erreur dans _getPosition : $e");
    }
  }

  callback2(double lat, double long) async {
    if (_controller.isCompleted) {
      final controllers = await _controller.future;
      final LatLng initialLatLng = LatLng(lat, long);
      // Met à jour la position dans le StateNotifier avec les valeurs par défaut
      ref.read(mapsUserStateNotifier.notifier).updatePosition(
          Position(
            latitude: lat,
            longitude: long,
            accuracy: 0.0, // Précision, vous pouvez ajuster cette valeur
            altitude: 0.0, // Altitude par défaut
            heading: 0.0, // Direction par défaut
            speed: 0.0, // Vitesse par défaut
            speedAccuracy: 0.0, // Précision de la vitesse
            timestamp: DateTime.now(),
            altitudeAccuracy: 0.0, // Ajoutez l'altitudeAccuracy par défaut
            headingAccuracy: 0.0,
          ),
          controllers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(mapsUserStateNotifier);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: notifier.position == null
          ? Center(
              child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/searchlocation2.gif'),
                      ),
                    ),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Text("chargement_de_votre_position".tr),
                        ],
                      ),
                    )),
                  ),
                ],
              ),
            ))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: notifier.cameraPosition ??
                      CameraPosition(
                        target: LatLng(notifier.position?.latitude ?? 0,
                            notifier.position?.longitude ?? 0),
                        zoom: notifier.zoom,
                      ),
                  circles: <Circle>{
                    Circle(
                      circleId: CircleId('search_circle'),
                      center: LatLng(notifier.position?.latitude ?? 0,
                          notifier.position?.longitude ?? 0),
                      radius: notifier.radius,
                      fillColor: Colors.blue.withOpacity(0.1),
                      strokeColor: Colors.blue,
                      strokeWidth: 2,
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) async {
                    if (!_controller.isCompleted) {
                      _controller
                          .complete(controller); // Complète le contrôleur
                      final controllers = await _controller.future;
                      // Restaurer le zoom et la position de la caméra
                      ref
                          .read(mapsUserStateNotifier.notifier)
                          .initializePosition(controllers);
                    }
                  },
                  onCameraMove: (CameraPosition newCameraPosition) {
                    ref
                        .read(mapsUserStateNotifier.notifier)
                        .updateCameraPosition(newCameraPosition);
                  },
                  onCameraIdle: () {
                    ref
                        .read(mapsUserStateNotifier.notifier)
                        .updateZoom(notifier.cameraPosition?.zoom ?? 11.2);
                    ref
                        .read(mapsUserStateNotifier.notifier)
                        .searchNearbyUsers();
                  },
                  markers: notifier.markers, // Ajouter les marqueurs ici
                  onTap: (LatLng tappedPosition) async {
                    if (_controller.isCompleted) {
                      final controllers = await _controller.future;
                      // Met à jour la position dans le StateNotifier avec les valeurs par défaut
                      ref.read(mapsUserStateNotifier.notifier).updatePosition(
                          Position(
                            latitude: tappedPosition.latitude,
                            longitude: tappedPosition.longitude,
                            accuracy:
                                0.0, // Précision, vous pouvez ajuster cette valeur
                            altitude: 0.0, // Altitude par défaut
                            heading: 0.0, // Direction par défaut
                            speed: 0.0, // Vitesse par défaut
                            speedAccuracy: 0.0, // Précision de la vitesse
                            timestamp: DateTime.now(),
                            altitudeAccuracy:
                                0.0, // Ajoutez l'altitudeAccuracy par défaut
                            headingAccuracy: 0.0,
                          ),
                          controllers);
                    }
                  },
                ),
                Positioned(
                    bottom: 100,
                    right: 11,
                    child: InkWell(
                      // onTap: () => showDialogListeUserAproximite(context,ref),
                      onTap: () async {
                        if (_controller.isCompleted) {
                          final controllers = await _controller.future;
                          ref
                              .read(mapsUserStateNotifier.notifier)
                              .resetToCurrentPosition(controllers);
                        }
                      },
                      child: Container(
                        width: 37,
                        height: 50,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  newColorBlueElevate,
                                  newColorGreenDarkElevate
                                ]),
                            borderRadius: BorderRadius.all(Radius.circular(1))),
                        child: Center(
                            child: FaIcon(FontAwesomeIcons.crosshairs,
                                size: 22, color: Colors.white)),
                      ),
                    )),
                Positioned(
                    bottom: 217,
                    right: 11,
                    child: InkWell(
                      // onTap: () => showDialogListeUserAproximite(context,ref),
                      onTap: () async {
                        SlideNavigation.slideToPage(context, FilterPage());
                      },
                      child: Container(
                        width: 37,
                        height: 50,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  newColorBlueElevate,
                                  newColorGreenDarkElevate
                                ]),
                            borderRadius: BorderRadius.all(Radius.circular(1))),
                        child: Center(
                            child: FaIcon(FontAwesomeIcons.filter,
                                size: 15, color: Colors.white)),
                      ),
                    )),
                Positioned(
                    bottom: 155,
                    right: 11,
                    child: InkWell(
                      // onTap: () => showDialogListeUserAproximite(context,ref),
                      onTap: () async {
                        SlideNavigation.slideToPage(
                            context, Listeutilisateuraproximite());
                      },
                      child: Container(
                        width: 37,
                        height: 50,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  newColorBlueElevate,
                                  newColorGreenDarkElevate
                                ]),
                            borderRadius: BorderRadius.all(Radius.circular(1))),
                        child: Center(
                            child: FaIcon(FontAwesomeIcons.userGroup,
                                size: 15, color: Colors.white)),
                      ),
                    )),
                Positioned(
                    bottom: 190,
                    right: 10,
                    child: InkWell(
                      onTap: () {
                        SlideNavigation.slideToPage(
                            context, Listeutilisateuraproximite());
                      },
                      child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: Center(
                              child: Text(
                                  notifier.listAllUserApproximite.length < 10
                                      ? '${notifier.listAllUserApproximite.length}'
                                      : '9+',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)))),
                    )),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextFormField(
                          onTap: () async {
                            SlideNavigation.slideToPage(context,
                                TrouverParPlace(callbackFunction: callback2));
                          },
                          readOnly: true,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.w200),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            contentPadding: EdgeInsets.only(
                                left: 10, right: 10, top: 3, bottom: 3),
                            hintText: notifier.adressMaps != ""
                                ? notifier.adressMaps
                                : "Rechercher".tr,
                            hintStyle: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 10,
                  right: 10,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: double.infinity,
                    ),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Row(
                            children: [
                              Flexible(
                                  child: Text(
                                'Proximité'.tr,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                notifier.radius >= 100000
                                    ? '${notifier.radius.toString().substring(0, 3)} Km'
                                    : '${notifier.radius.toString().substring(0, 2)} Km',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        Slider(
                          min: 10000,
                          max: 500000,
                          // divisions: 9,
                          value: notifier.radius,
                          label: notifier.radius >= 100000
                              ? '${notifier.radius.toString().substring(0, 3)} Km'
                              : '${notifier.radius.toString().substring(0, 2)} Km',
                          activeColor: newColorBlueElevate,
                          inactiveColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.grey.withOpacity(0.2),
                          onChanged: (value) async {
                            if (_controller.isCompleted) {
                              final controllers = await _controller.future;
                              ref
                                  .read(mapsUserStateNotifier.notifier)
                                  .updateRadius(value, controllers);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 195,
                  left: 15,
                  right: 15,
                  child: SizedBox(
                    height: notifier.nationaliteCounts.isNotEmpty ? 50 : 0,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: notifier.isLoading
                          ? 1
                          : notifier.nationaliteCounts.length,
                      itemBuilder: (context, index) {
                        // Si le chargement est en cours
                        if (notifier.isLoading) {
                          return Center(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: SizedBox.shrink()),
                          );
                        }
                        String nationalite =
                            notifier.nationaliteCounts.keys.elementAt(index);
                        int count =
                            notifier.nationaliteCounts[nationalite]!['count'];
                        String flag =
                            notifier.nationaliteCounts[nationalite]!['flag'];
                        var users =
                            notifier.nationaliteCounts[nationalite]!['users'];
                        return GestureDetector(
                          onTap: () {
                            SlideNavigation.slideToPage(context,
                                UtilisateuraproximiteNationalite(users: users));
                          },
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 2),
                              child: AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: SizedBox(
                                          width: 60,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  child: Text(
                                                    flag,
                                                    style: TextStyle(
                                                      fontSize: 27,
                                                    ),
                                                  )),
                                              Positioned(
                                                  bottom: 0,
                                                  right: 13,
                                                  child: Transform(
                                                    transform:
                                                        Matrix4.skewX(-0.2),
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color:
                                                                    Colors.red),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 1),
                                                          child: Center(
                                                              child: Text(
                                                            '$count',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12),
                                                          )),
                                                        )),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      )))),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                    bottom: 15,
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: kPrimaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            Checkbox(
                              side: BorderSide(color: Colors.white, width: 2),
                              activeColor: Colors.white,
                              checkColor: Colors.red,
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                                if (mounted) {
                                  ref
                                      .read(infoUserStateNotifier.notifier)
                                      .updateDistancePosition(isChecked);
                                }
                              },
                            ),
                            FaIcon(FontAwesomeIcons.locationPinLock,
                                size: 22, color: Colors.white)
                          ],
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
