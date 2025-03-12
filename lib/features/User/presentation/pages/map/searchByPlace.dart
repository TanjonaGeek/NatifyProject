import 'dart:async';
import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/services.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/core/utils/widget/loading.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TrouverParPlace extends ConsumerStatefulWidget {
  final Function callbackFunction;
  const TrouverParPlace({required this.callbackFunction, super.key});

  @override
  ConsumerState<TrouverParPlace> createState() => _TrouverParPlaceState();
}

class _TrouverParPlaceState extends ConsumerState<TrouverParPlace> {
  final TextEditingController fieldRechercheController =
      TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  Timer? _debounce;
  final String baseUrl = "https://nominatim.openstreetmap.org";
  final http.Client client = http.Client();

  // Future pour récupérer les lieux
  Future<List<dynamic>> fetchPlaceSuggestions(String placeInput) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showCustomSnackBar("Pas de connexion internet");
      return [];
    }

    if (placeInput.isEmpty) return [];

    try {
      final url = Uri.parse(
          '$baseUrl/search?q=$placeInput&format=json&polygon_geojson=1&addressdetails=1');
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return decodedResponse;
      } else {
        showCustomSnackBar("Erreur de requête : ${response.statusCode}");
        return [];
      }
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
      return [];
    }
  }

  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  // Callback de sélection de lieu
  void trouverPlace(BuildContext context, double lat, double lon) {
    hideKeyboard(context);
    widget.callbackFunction(lat, lon);
    Navigator.pop(context);
  }

  // Gestion du changement de texte avec debounce
  void _onChange() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        // No need for isLoading anymore
      });
    });
  }

  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    });
    fieldRechercheController.addListener(_onChange);
  }

  @override
  void dispose() {
    fieldRechercheController.dispose();
    client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('tapez_un_lieu'.tr,
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              width: 30,
              height: 30,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: Center(
                  child: FaIcon(
                FontAwesomeIcons.chevronLeft,
                size: 20,
              )),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                focusNode: searchFocusNode,
                controller: fieldRechercheController,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black26,
                        width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black26,
                        width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black26,
                        width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  contentPadding:
                      EdgeInsets.only(left: 20, right: 20, top: 3, bottom: 3),
                  hintText: 'Rechercher'.tr,
                  hintStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchPlaceSuggestions(fieldRechercheController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Loading();
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer."
                                .tr));
                  }

                  final listLocation = snapshot.data ?? [];

                  if (listLocation.isEmpty) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/localisation-de-lutilisateur.png',
                              width: 120, height: 120),
                          SizedBox(height: 10),
                          Text("Aucun résultat".tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              "pas_pu_localiser".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: listLocation.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          var lat = double.parse(listLocation[index]['lat']);
                          var lon = double.parse(listLocation[index]['lon']);
                          trouverPlace(context, lat, lon);
                        },
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: newColorGreyElevate),
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                              child: FaIcon(FontAwesomeIcons.locationDot,
                                  size: 17, color: Colors.red)),
                        ),
                        title: Text(
                          "${listLocation[index]['display_name']}",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
