import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewMapsMarketPlace extends ConsumerStatefulWidget {
  final Position currentPosition;
  final String lieuAdress;
  ViewMapsMarketPlace(
      {super.key, required this.currentPosition, required this.lieuAdress});

  @override
  ConsumerState<ViewMapsMarketPlace> createState() =>
      _ViewMapsMarketPlaceState();
}

class _ViewMapsMarketPlaceState extends ConsumerState<ViewMapsMarketPlace>
    with AutomaticKeepAliveClientMixin<ViewMapsMarketPlace> {
  bool get wantKeepAlive => true;
  final Completer<GoogleMapController> _controller = Completer();
  late Position currentPosition;
  double zoom = 16.2; // Zoom par défaut
  bool _isLoading = false; // Indicateur de chargement
  late String lieuAdress = "";

  Future<void> initPositionMarket() async {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration(seconds: 1), () {});
    setState(() {
      currentPosition = widget.currentPosition;
      lieuAdress = widget.lieuAdress;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initPositionMarket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    target: LatLng(
                        currentPosition!.latitude, currentPosition!.longitude),
                    zoom: zoom,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('current_location'), // ID unique
                      position: LatLng(
                          currentPosition.latitude, currentPosition.longitude),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                      infoWindow: InfoWindow(title: "Marqueur ajouté"),
                    )
                  }, // Conversion de Map en Set // Affichage des marqueurs
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
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
                            hintText: "${lieuAdress}",
                            hintStyle: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
