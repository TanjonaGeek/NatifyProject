import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/User/presentation/provider/state/maps_state_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:natify/features/User/presentation/provider/state/marketplace_state.dart';
import 'package:units_converter/units_converter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketplaceUserNotifier extends StateNotifier<MarketplaceUserState> {
  Timer? _debounce;
  late final GeoFlutterFire _geo;
  Stream<List<DocumentSnapshot>>? queryStream;
  final Ref ref;
  MarketplaceUserNotifier(this.ref) : super(MarketplaceUserState.initial()) {
    _geo = GeoFlutterFire();
    transferDataPrefToNotifer();
  }
  bool get isFetching => state.state != MarketplaceUserConcreteState.loading;
  final firestore = FirebaseFirestore.instance;

  // Méthode pour récupérer la position initiale
  Future<void> initializePosition(GoogleMapController controller) async {
    if (state.position != null) {
      updatePosition(state.position!, controller);
    }
  }

  Future<void> loadMarkerFromUrl(String url) async {
    try {
      final BitmapDescriptor icon =
          await MarkerIcon.downloadResizePictureCircle(url,
              size: 120,
              addBorder: true,
              borderColor: Colors.red,
              borderSize: 20);
      state = state.copyWith(customIcon: icon);
    } catch (e) {
      print("Erreur : $e");
    }
  }

  // Fonction pour obtenir la position actuelle
  Future<void> getCurrentLocation() async {
    if (isFetching) {
      final BitmapDescriptor icon = state.customIcon ??
          await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(550, 550)),
            'assets/pointer.png',
          );
      final prefs = await SharedPreferences.getInstance();
      try {
        // Mettre à jour l'état avec la position récupérée
        print('position misy');
        // Vérifier les permissions de localisation
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          state = state.copyWith(
            isLoading: false,
            state: MarketplaceUserConcreteState.loaded,
          );
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            state = state.copyWith(
              isLoading: false,
              state: MarketplaceUserConcreteState.loaded,
            );
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          state = state.copyWith(
            isLoading: false,
            state: MarketplaceUserConcreteState.loaded,
          );
          return;
        }

        // Obtenir la position actuelle
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );

        final initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 11.2, // Par exemple
        );

        final currentPositionMarker = Marker(
          markerId: MarkerId('current_position'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Votre position actuelle'),
          icon: icon,
        );
        await prefs.setDouble('latitude', position.latitude);
        await prefs.setDouble('longitude', position.longitude);
        await prefs.setDouble('zoom', 11.2); // Par exemple
        // Mettre à jour l'état avec la position récupérée
        state = state.copyWith(
          position: position,
          cameraPosition: initialCameraPosition,
          isLoading: false,
          markers: {currentPositionMarker},
          state: MarketplaceUserConcreteState.loaded,
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          state: MarketplaceUserConcreteState.failure,
        );
      }
    }
  }

  Future<void> transferDataPrefToNotifer() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final BitmapDescriptor icon = state.customIcon!;

      double? latitude = prefs.getDouble('latitude') ?? 0.0;
      double? longitude = prefs.getDouble('longitude') ?? 0.0;
      double? zoom = prefs.getDouble('zoom') ?? 11.2;
      double? radius = prefs.getDouble('radius') ?? 10000.0;
      double? mapCenterLatitude = prefs.getDouble('mapCenter_latitude') ?? 0.0;
      double? mapCenterLongitude =
          prefs.getDouble('mapCenter_longitude') ?? 0.0;

      // Vérifier si rangeOfageDebutAndFin est bien formaté avant de le parser
      String? rangeString = prefs.getString('rangeOfageDebutAndFin');
      RangeValues loadedRangeOfageDebutAndFin;
      if (rangeString!.contains(',')) {
        List<String> parts = rangeString.split(',');
        if (parts.length == 2) {
          try {
            loadedRangeOfageDebutAndFin = RangeValues(
              double.tryParse(parts[0]) ?? 14.0,
              double.tryParse(parts[1]) ?? 90.0,
            );
          } catch (e) {
            print("Erreur parsing rangeOfageDebutAndFin: $e");
            loadedRangeOfageDebutAndFin = RangeValues(14, 90);
          }
        } else {
          loadedRangeOfageDebutAndFin = RangeValues(14, 90);
        }
      } else {
        loadedRangeOfageDebutAndFin = RangeValues(14, 90);
      }

      List<String> nationaliteGroupSansFlag =
          prefs.getStringList('nationaliteGroupSansFlag') ?? [];
      String pays = prefs.getString('pays') ?? '';
      String sexe = prefs.getString('sexe') ?? '';
      String adresse = prefs.getString('adresse') ?? '';
      bool isFilter = prefs.getBool('isFilter') ?? false;

      // Vérifier si nationaliteGroup est bien formaté avant de le décoder
      String? nationaliteGroupJson = prefs.getString('nationaliteGroup');
      List<Map<String, String>> loadedNationaliteGroup = [];
      try {
        loadedNationaliteGroup = List<Map<String, String>>.from(
          jsonDecode(nationaliteGroupJson!)
              .map((e) => Map<String, String>.from(e)),
        );
      } catch (e) {
        print("Erreur parsing nationaliteGroup: $e");
        loadedNationaliteGroup = [];
      }

      final GeoFirePoint mapCenter = GeoFirePoint(
        mapCenterLatitude,
        mapCenterLongitude,
      );

      if (latitude == 0.0 && longitude == 0.0) {
        getCurrentLocation();
      } else {
        final initialCameraPosition = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: zoom,
        );

        final currentPositionMarker = Marker(
          markerId: MarkerId('current_position'),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: 'Votre position actuelle'),
          icon: icon,
        );

        // Création correcte de l'objet Position avec `altitudeAccuracy` et `headingAccuracy`
        Position position = Position(
          latitude: latitude,
          longitude: longitude,
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          timestamp: DateTime.now(),
          altitudeAccuracy: 0.0, // Correction ici
          headingAccuracy: 0.0, // Correction ici
        );

        state = state.copyWith(
          position: position,
          mapCenter: mapCenter,
          cameraPosition: initialCameraPosition,
          markers: {currentPositionMarker},
          adressMaps: adresse,
          prixProduit: loadedRangeOfageDebutAndFin,
          Categorie: sexe,
          pays: pays,
          zoom: zoom,
          radius: radius,
          nationaliteGroup: loadedNationaliteGroup,
          nationaliteGroupSansFlag: nationaliteGroupSansFlag,
          isFilter: isFilter,
          isLoading: false,
          state: MarketplaceUserConcreteState.loaded,
        );
      }
    } catch (e) {
      print("Erreur dans transferDataPrefToNotifer: $e");
    }
  }

  // Future<void> transferDataPrefToNotifer() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final BitmapDescriptor icon = state.customIcon!;
  //   double? Latitude = prefs.getDouble('latitude') ?? 0.0;
  //   double? Longitude = prefs.getDouble('longitude') ?? 0.0;
  //   double? zoom = prefs.getDouble('zoom') ?? 11.2;
  //   String? rangeString = prefs.getString('rangeOfageDebutAndFin');
  //   RangeValues loadedRangeOfageDebutAndFin = rangeString != null
  //       ? RangeValues(
  //           double.parse(rangeString.split(',')[0]),
  //           double.parse(rangeString.split(',')[1]),
  //         )
  //       : RangeValues(14, 90);
  //   List<String> nationaliteGroupSansFlag =
  //       prefs.getStringList('nationaliteGroupSansFlag') ?? [];
  //   String pays = prefs.getString('pays') ?? '';
  //   String sexe = prefs.getString('sexe') ?? '';
  //   String adresse = prefs.getString('adresse') ?? '';
  //   bool isFilter = prefs.getBool('isFilter') ?? false;
  //   String? nationaliteGroupJson = prefs.getString('nationaliteGroup');
  //   List<Map<String, String>> loadedNationaliteGroup =
  //       nationaliteGroupJson != null
  //           ? List<Map<String, String>>.from(
  //               jsonDecode(nationaliteGroupJson)
  //                   .map((e) => Map<String, String>.from(e)),
  //             )
  //           : [];

  //   double? radius = prefs.getDouble('radius') ?? 10000.0;
  //   double? mapCenterLatitude = prefs.getDouble('mapCenter_latitude') ?? 0.0;
  //   double? mapCenterLongitude = prefs.getDouble('mapCenter_longitude') ?? 0.0;
  //   final GeoFirePoint mapCenter = GeoFirePoint(
  //     mapCenterLatitude,
  //     mapCenterLongitude,
  //   );
  //   if (Latitude == 0.0 && Longitude == 0.0) {
  //     getCurrentLocation();
  //   } else {
  //     final initialCameraPosition = CameraPosition(
  //       target: LatLng(Latitude, Longitude),
  //       zoom: zoom, // Par exemple
  //     );
  //     final currentPositionMarker = Marker(
  //       markerId: MarkerId('current_position'),
  //       position: LatLng(Latitude, Longitude),
  //       infoWindow: InfoWindow(title: 'Votre position actuelle'),
  //       icon: icon,
  //     );
  //     // Obtenir la position actuelle
  //     Position position = Position(
  //       latitude: Latitude,
  //       longitude: Longitude,
  //       accuracy: 0.0, // Précision, vous pouvez ajuster cette valeur
  //       altitude: 0.0, // Altitude par défaut
  //       heading: 0.0, // Direction par défaut
  //       speed: 0.0, // Vitesse par défaut
  //       speedAccuracy: 0.0, // Précision de la vitesse
  //       timestamp: DateTime.now(),
  //       altitudeAccuracy: 0.0, // Ajoutez l'altitudeAccuracy par défaut
  //       headingAccuracy: 0.0,
  //     );
  //     state = state.copyWith(
  //       position: position,
  //       mapCenter: mapCenter,
  //       cameraPosition: initialCameraPosition,
  //       markers: {currentPositionMarker},
  //       adressMaps: adresse,
  //       rangeOfageDebutAndFin: loadedRangeOfageDebutAndFin,
  //       sexe: sexe,
  //       pays: pays,
  //       zoom: zoom,
  //       radius: radius,
  //       nationaliteGroup: loadedNationaliteGroup,
  //       nationaliteGroupSansFlag: nationaliteGroupSansFlag,
  //       isFilter: isFilter,
  //       isLoading: false,
  //       state: MapsUserConcreteState.loaded,
  //     );
  //   }
  // }

  void updatePosition(
      Position newPosition, GoogleMapController controller) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    // Créer un point GeoFire avec la nouvelle position
    final GeoFirePoint center = _geo.point(
      latitude: newPosition.latitude,
      longitude: newPosition.longitude,
    );
    final List<Placemark> placemarks = await placemarkFromCoordinates(
      newPosition.latitude,
      newPosition.longitude,
    );
    final BitmapDescriptor icon = state.customIcon ??
        await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(550, 550)),
          'assets/pointer.png',
        );
    final currentPositionMarker = Marker(
      markerId: MarkerId('current_position'),
      position: LatLng(newPosition.latitude, newPosition.longitude),
      infoWindow: InfoWindow(title: 'Votre position actuelle'),
      icon: icon,
    );
    // Anime la caméra vers la nouvelle position
    double levelZoom = state.zoom;
    if (state.radius > 10000) {
      double radiusElevated = state.radius + state.radius / 2;
      double scale = radiusElevated / 500;
      levelZoom = 16 - log(scale) / log(2);
    }
    var zoom = levelZoom.toStringAsFixed(1);
    double zoomParse = double.parse(zoom);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(newPosition.latitude, newPosition.longitude),
            zoom: zoomParse, // Vous pouvez définir un zoom spécifique
          ),
        ),
      );
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String codePostal = place.postalCode.toString() ?? '';
      String locality = place.subLocality.toString() ?? '';
      String administrativeArea = place.administrativeArea.toString() ?? '';
      String adresse = "${place.postalCode} $locality $administrativeArea";

      // Sauvegarder les données dans SharedPreferences
      await prefs.setDouble('mapCenter_latitude', newPosition.latitude);
      await prefs.setDouble('mapCenter_longitude', newPosition.longitude);
      await prefs.setDouble('latitude', newPosition.latitude);
      await prefs.setDouble('longitude', newPosition.longitude);
      await prefs.setDouble('zoom', zoomParse);
      await prefs.setString('adresse', adresse);
      // Mettre à jour le state avec la nouvelle position et mapCenter
      state = state.copyWith(
          position: newPosition,
          mapCenter: center,
          markers: {currentPositionMarker},
          adressMaps: adresse);
    } else {
      // Sauvegarder les données dans SharedPreferences sans adresse
      await prefs.setDouble('mapCenter_latitude', newPosition.latitude);
      await prefs.setDouble('mapCenter_longitude', newPosition.longitude);
      await prefs.setDouble('latitude', newPosition.latitude);
      await prefs.setDouble('longitude', newPosition.longitude);
      await prefs.setDouble('zoom', zoomParse);
      // Mettre à jour le state avec la nouvelle position et mapCenter
      state = state.copyWith(
        position: newPosition,
        mapCenter: center,
        markers: {currentPositionMarker},
      );
    }
  }

  // Recentrer la caméra sur la position actuelle
  Future<void> resetToCurrentPosition(GoogleMapController controller) async {
    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    updatePosition(position, controller);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String codePostal = place.postalCode.toString() ?? '';
        String locality = place.subLocality.toString() ?? '';
        String administrativeArea = place.administrativeArea.toString() ?? '';
        String adresse = "${place.postalCode} $locality $administrativeArea";
        updateAdress(adresse);
      }
    } catch (e) {}
  }

  void updateRadius(double newRadius, GoogleMapController controller) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      radius: newRadius,
    );
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    double levelZoom = state.zoom;
    if (state.radius > 1000) {
      double radiusElevated = state.radius + state.radius / 2;
      double scale = radiusElevated / 500;
      levelZoom = 16 - log(scale) / log(2);
    }
    var zoom = levelZoom.toStringAsFixed(1);
    double zoomParse = double.parse(zoom);
    await prefs.setDouble('radius', newRadius);
    await prefs.setDouble('zoom', zoomParse);
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(state.position!.latitude, state.position!.longitude),
            zoom: zoomParse, // Vous pouvez définir un zoom spécifique
          ),
        ),
      );
    });
  }

  void updateZoom(double newZoom) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('zoom', newZoom);
    state = state.copyWith(zoom: newZoom);
  }

  void updateAdress(String nameAdresse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('adresse', nameAdresse);
    state = state.copyWith(adressMaps: nameAdresse);
  }

  void resetListeNationalite() {
    print('etat nationalite');
  }

  // Mise à jour de la position de la caméra
  void updateCameraPosition(CameraPosition newCameraPosition) {
    state = state.copyWith(cameraPosition: newCameraPosition);
  }

  Future<void> searchNearbyUsers() async {
    final prefs = await SharedPreferences.getInstance();
    // Récupérer les préférences partagées
    if (state.mapCenter == null) {
      print('Map center is null. Exiting searchNearbyUsers.');
      return;
    }
    state = state.copyWith(isLoading: true);
    // Récupérer tes propres données depuis Firestore
    final String myUidss = FirebaseAuth.instance.currentUser!.uid;
    final myDoc = await firestore.collection('users').doc(myUidss).get();
    List<String> friendBlockedList = [];
    if (myDoc.exists) {
      final myData = myDoc.data() as Map<String, dynamic>;
      friendBlockedList = List<String>.from(myData['friendBlocked'] ?? []);
    }
    try {
      final collectionReference = firestore.collection('users');
      final double radiusInKm = state.radius / 1000;

      // Appliquer les filtres
      int ageMin = state.prixProduit.start.toInt();
      int ageMax = state.prixProduit.end.toInt();
      String selectedNationality = state.nationalite;
      List<String> nationaliteGroupSansFlag = state.nationaliteGroupSansFlag;
      String selectedCountry = state.pays;
      String selectedGender = state.Categorie;

      // Utiliser GeoFlutterFire pour récupérer les utilisateurs autour d'une position sans stream
      final List<DocumentSnapshot> users = await _geo
          .collection(collectionRef: collectionReference)
          .within(
            center: state.mapCenter!,
            radius: radiusInKm,
            field: 'position',
            strictMode: true,
          )
          .first; // Utilisez `first` pour récupérer les données immédiatement, sans écouter

      // Filtrage des utilisateurs
      final filteredUsers = users.where((user) {
        var data = user.data() as Map<String, dynamic>;

        // Vérifier que les champs existent
        int userAge = int.parse(data['age'][0]['age']) ?? 0;
        String userNationality = data['nationalite'] ?? '';
        String userCountry = data['pays'] ?? '';
        String userGender = data['sexe'] ?? '';

        // Appliquer les conditions de filtre
        bool matchesAge = userAge >= ageMin && userAge <= ageMax;
        // bool matchesNationality = selectedNationality.isEmpty || userNationality == selectedNationality;
        bool matchesNationality = nationaliteGroupSansFlag.isEmpty ||
            nationaliteGroupSansFlag.contains(userNationality);
        bool matchesCountry =
            selectedCountry.isEmpty || userCountry == selectedCountry;
        bool matchesGender =
            selectedGender.isEmpty || userGender == selectedGender;

        return matchesAge &&
            matchesNationality &&
            matchesCountry &&
            matchesGender;
      }).toList();

      // Supprimer de la liste les utilisateurs dont le uid est dans friendblockerd
      filteredUsers.removeWhere((user) {
        final data = user.data() as Map<String, dynamic>;
        final String? uid = data['uid'];
        return uid != null && friendBlockedList.contains(uid);
      });

      // Traitement des utilisateurs filtrés
      final Set<String> countedUsers = {};
      final Map<String, Map<String, dynamic>> nationaliteCounts = {};
      final List<Map<String, dynamic>> listeUserApproximite = [];

      for (var user in filteredUsers) {
        final data = user.data() as Map<String, dynamic>;
        final String? flag = data['flag'];
        final String? uid = data['uid'];
        final String? name = data['name'];
        final int age = int.parse(data['age'][0]['age']) ?? 0;
        final String? nationalite = data['nationalite'];
        final String? pays = data['pays'];
        final String? sexe = data['sexe'];
        final String? photoUser = data['profilePic'];
        final List<dynamic>? abonnee = data['abonnee'];
        final bool? hiddenPosition = data['hiddenPosition'];
        final GeoPoint pos = data['position']['geopoint'];
        var distanceInMeters = Geolocator.distanceBetween(
            state.position!.latitude,
            state.position!.longitude,
            pos.latitude,
            pos.longitude);

        if (uid != FirebaseAuth.instance.currentUser!.uid) {
          if (nationalite != null &&
              flag != null &&
              uid != null &&
              !countedUsers.contains(uid)) {
            countedUsers.add(uid);
            if (nationaliteCounts.containsKey(nationalite)) {
              nationaliteCounts[nationalite]!['count'] =
                  nationaliteCounts[nationalite]!['count'] + 1;
              nationaliteCounts[nationalite]!['users'].add({
                'flag': flag,
                'uid': uid,
                'name': name,
                'age': age,
                'pays': pays,
                'sexe': sexe,
                'photoUser': photoUser,
                'abonnee': abonnee,
                'hiddenPosition': hiddenPosition,
                'nationalite': nationalite,
                'distance': distanceInMeters
                    .convertFromTo(LENGTH.meters, LENGTH.kilometers)!
                    .toStringAsFixed(2),
              });
            } else {
              nationaliteCounts[nationalite] = {
                'count': 1,
                'flag': flag,
                'users': [
                  {
                    'flag': flag,
                    'uid': uid,
                    'name': name,
                    'age': age,
                    'pays': pays,
                    'sexe': sexe,
                    'photoUser': photoUser,
                    'nationalite': nationalite,
                    'abonnee': abonnee,
                    'hiddenPosition': hiddenPosition,
                    'distance': distanceInMeters
                        .convertFromTo(LENGTH.meters, LENGTH.kilometers)!
                        .toStringAsFixed(2),
                  }
                ],
              };
            }
          }
          listeUserApproximite.add({
            'flag': flag,
            'uid': uid,
            'name': name,
            'age': age,
            'nationalite': nationalite,
            'pays': pays,
            'sexe': sexe,
            'photoUser': photoUser,
            'abonnee': abonnee,
            'hiddenPosition': hiddenPosition,
            'distance': distanceInMeters
                .convertFromTo(LENGTH.meters, LENGTH.kilometers)!
                .toStringAsFixed(2)
          });
        }
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  SetUpdateFieldToFilter({
    required List<String> nationaliteGroupSansFlag,
    required List<Map<String, String>> nationaliteGroup,
    required String categorie,
    required String flag,
    required String nationalite,
    required String pays,
    required RangeValues rangeOfPriceDebutAndFin,
    required String currency,
  }) async {
    state = state.copyWith(
        flag: flag,
        Categorie: categorie,
        nationalite: nationalite,
        currency: currency,
        pays: pays,
        isFilter: true,
        prixProduit: rangeOfPriceDebutAndFin,
        nationaliteGroup: nationaliteGroup,
        nationaliteGroupSansFlag: nationaliteGroupSansFlag);

    // Sauvegarde des données dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Sauvegarde des valeurs simples
    await prefs.setString('flagMarket', flag);
    await prefs.setString('categorieMarket', categorie);
    await prefs.setString('currencyMarket', currency);
    await prefs.setString('nationaliteMarket', nationalite);
    await prefs.setString('paysMarket', pays);
    await prefs.setBool('isFilter', true);

    // Sauvegarde des RangeValues comme une chaîne
    await prefs.setString('rangeOfPrixDebutAndFinMarket',
        '${rangeOfPriceDebutAndFin.start.toString()},${rangeOfPriceDebutAndFin.end.toString()}');

    // Sauvegarde des listes
    await prefs.setStringList(
        'nationaliteGroupSansFlagMarket', nationaliteGroupSansFlag);

    // Convertir `nationaliteGroup` en une chaîne JSON
    String nationaliteGroupJson = jsonEncode(nationaliteGroup);
    await prefs.setString('nationaliteGroupMarket', nationaliteGroupJson);

    // await searchNearbyUsers();
  }

  Future<void> ResetFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
        prixProduit: RangeValues(1, 10000),
        Categorie: '',
        pays: '',
        flag: '',
        currency: 'USD',
        nationalite: '',
        nameSearch: '',
        nationaliteGroup: [],
        nationaliteGroupSansFlag: [],
        isFilter: false);

    // Sauvegarder les valeurs réinitialisées dans SharedPreferences
    await prefs.setString('flagMarket', '');
    await prefs.setString('categorieMarket', '');
    await prefs.setString('currencyMarket', 'USD');
    await prefs.setString('nationaliteMarket', '');
    await prefs.setString('paysMarket', '');
    await prefs.setBool('isFilter', false);

    await prefs.setString('rangeOfPrixDebutAndFinMarket', '');
    await prefs.setString('nameSearchMarket', '');
    await prefs.setString('nationaliteGroupMarket',
        jsonEncode([])); // Stocker la liste de Map en JSON
    await prefs.setStringList('nationaliteGroupSansFlagMarket',
        []); // Stocker directement la liste de chaînes
  }
}
