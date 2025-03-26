import 'dart:async';
import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:natify/features/User/presentation/widget/lieuvente.dart';

class MapsMarketPlace extends ConsumerStatefulWidget {
  final Position currentPosition;
  final String lieuAdress;
  MapsMarketPlace(
      {super.key, required this.currentPosition, required this.lieuAdress});

  @override
  ConsumerState<MapsMarketPlace> createState() => _MapsMarketPlaceState();
}

class _MapsMarketPlaceState extends ConsumerState<MapsMarketPlace>
    with AutomaticKeepAliveClientMixin<MapsMarketPlace> {
  bool get wantKeepAlive => true;
  final Completer<GoogleMapController> _controller = Completer();
  Timer? _debounce;
  late Position currentPosition;
  double radius = 10000; // Rayon par défaut
  double zoom = 11.2; // Zoom par défaut
  bool _isLoading = false; // Indicateur de chargement
  Map<String, Marker> markers = {};
  late String lieuAdress = "";

  @override
  void initState() {
    super.initState();
    currentPosition = widget.currentPosition;
    lieuAdress = widget.lieuAdress;
    _getCurrentLocationMarket();
  }

  Future<void> _getCurrentLocationMarket() async {
    setState(() {
      _isLoading = true; // Afficher "Chargement..."
    });

    try {
      final marker = Marker(
        markerId: MarkerId("current_location"),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          markers['currentLocation'] = marker;
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      final markersd = Marker(
        markerId: MarkerId("current_location"),
        position: LatLng(position!.latitude, position!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      double levelZoom = zoom;
      if (radius > 10000) {
        double radiusElevated = radius + radius / 2;
        double scale = radiusElevated / 500;
        levelZoom = 16 - log(scale) / log(2);
      }
      var zooms = levelZoom.toStringAsFixed(1);
      double zoomParse = double.parse(zooms);
      _debounce = Timer(const Duration(milliseconds: 1000), () async {
        if (_controller.isCompleted) {
          final GoogleMapController mapController = await _controller.future;
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position!.latitude, position!.longitude),
                zoom: zoomParse,
              ),
            ),
          );
        }
      });
      setState(() {
        markers['current_location'] = markersd;
        currentPosition = position;
        zoom = zoomParse;
      });
      // setState(() {
      //   _isLoading = false;
      //   currentPosition = position;
      // });
    } catch (e) {}
  }

  void _addMarkerOnTap(LatLng tappedPosition) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    final marker = Marker(
      markerId: MarkerId('current_location'), // ID unique
      position: tappedPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: "Marqueur ajouté"),
    );
    Position positionNews = Position(
      latitude: tappedPosition.latitude,
      longitude: tappedPosition.longitude,
      accuracy: 0.0, // Précision, vous pouvez ajuster cette valeur
      altitude: 0.0, // Altitude par défaut
      heading: 0.0, // Direction par défaut
      speed: 0.0, // Vitesse par défaut
      speedAccuracy: 0.0, // Précision de la vitesse
      timestamp: DateTime.now(),
      altitudeAccuracy: 0.0, // Ajoutez l'altitudeAccuracy par défaut
      headingAccuracy: 0.0,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
        tappedPosition.latitude, tappedPosition.longitude);

    Placemark place = placemarks.first;
    String codePostal = place.postalCode.toString() ?? '';
    String locality = place.subLocality.toString() ?? '';
    String administrativeArea = place.administrativeArea.toString() ?? '';
    String adresse =
        "${place.postalCode} $locality $administrativeArea"; // Ex: "Antananarivo, Madagascar"

    double levelZoom = zoom;
    if (radius > 10000) {
      double radiusElevated = radius + radius / 2;
      double scale = radiusElevated / 500;
      levelZoom = 16 - log(scale) / log(2);
    }
    var zooms = levelZoom.toStringAsFixed(1);
    double zoomParse = double.parse(zooms);
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (_controller.isCompleted) {
        final GoogleMapController mapController = await _controller.future;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  LatLng(tappedPosition!.latitude, tappedPosition!.longitude),
              zoom: zoomParse,
            ),
          ),
        );
      }
    });

    setState(() {
      markers['current_location'] = marker;
      currentPosition = positionNews;
      zoom = zoomParse;
      lieuAdress = adresse;
    });
  }

  Future<void> refreshRadius(double radus) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    double levelZoom = zoom;
    if (radus > 10000) {
      double radiusElevated = radus + radus / 2;
      double scale = radiusElevated / 500;
      levelZoom = 16 - log(scale) / log(2);
    }
    var zooms = levelZoom.toStringAsFixed(1);
    double zoomParse = double.parse(zooms);
    setState(() {
      zoom = zoomParse;
      radius = radus;
    });
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (_controller.isCompleted) {
        final GoogleMapController mapController = await _controller.future;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  LatLng(currentPosition!.latitude, currentPosition!.longitude),
              zoom: zoomParse,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('ferme le page');
        var lat = currentPosition.latitude;
        var lon = currentPosition.longitude;
        var nameSelected = lieuAdress;
        // Retourner les informations du lieu
        List<Map<String, dynamic>> donnerGet = [
          {
            'latitude': lat,
            'longitude': lon,
            'lieu': nameSelected.toString(),
          }
        ];
        Navigator.pop(context, donnerGet);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: (_isLoading == true)
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
              )) // Chargement en attente de la position
            : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentPosition!.latitude,
                          currentPosition!.longitude),
                      zoom: zoom,
                    ),
                    onTap: (LatLng tappedPosition) {
                      _addMarkerOnTap(tappedPosition);
                    },
                    circles: {
                      Circle(
                        circleId: CircleId('search_circle'),
                        center: LatLng(currentPosition!.latitude,
                            currentPosition!.longitude),
                        radius: radius, // Mise à jour du rayon dynamique
                        fillColor: Colors.blue.withOpacity(0.3),
                        strokeColor: Colors.blue,
                        strokeWidth: 2,
                      ),
                    },
                    markers: Set<Marker>.of(markers
                        .values), // Conversion de Map en Set // Affichage des marqueurs
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                    },
                  ),
                  Positioned(
                    bottom: 100,
                    right: 11,
                    child: InkWell(
                      onTap: () async {
                        if (_controller.isCompleted) {
                          _getCurrentLocation();
                        }
                      },
                      child: Container(
                        width: 37,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              newColorBlueElevate,
                              newColorGreenDarkElevate
                            ],
                          ),
                        ),
                        child: Center(
                          child: FaIcon(FontAwesomeIcons.crosshairs,
                              size: 22, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
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
                              final selectedLieux = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrouverParLieux(),
                                ),
                              );

                              if (selectedLieux != null) {
                                print('le lieux est $selectedLieux');
                                var lat = double.parse(
                                    selectedLieux[0]['latitude'].toString());
                                var lon = double.parse(
                                    selectedLieux[0]['longitude'].toString());
                                LatLng tappedPosition = LatLng(lat, lon);
                                _addMarkerOnTap(tappedPosition);
                                setState(() {
                                  lieuAdress = selectedLieux[0]['lieu'];
                                });
                              }
                            },
                            readOnly: true,
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.w200),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
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
                              hintText: lieuAdress.isNotEmpty
                                  ? "${lieuAdress}"
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
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 20),
                            child: Row(
                              children: [
                                Text('Proximité'.tr,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 5),
                                Text('${(radius / 1000).toInt()} Km',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Slider(
                            min: 10000,
                            max: 500000,
                            value: radius,
                            onChanged: (value) {
                              refreshRadius(value);
                            },
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
