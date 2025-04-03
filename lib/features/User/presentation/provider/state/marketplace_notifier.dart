import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/usecases/useCaseEditVente.dart';
import 'package:natify/features/User/domaine/usecases/useCasePublierVente.dart';
import 'package:natify/features/User/presentation/provider/state/marketplace_state.dart';
import 'package:natify/injector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketplaceUserNotifier extends StateNotifier<MarketplaceUserState> {
  final Ref ref;
  final UseCasePublierVente _publierVenteUseCase =
      injector.get<UseCasePublierVente>();
  final UseCaseEditerVente _editerVenteUseCase =
      injector.get<UseCaseEditerVente>();
  MarketplaceUserNotifier(this.ref) : super(MarketplaceUserState()) {
    _loadState(); // Charger l'état sauvegardé au démarrage
  }
  bool get isFetching => state.state != MarketplaceUserConcreteState.loading;

  Future<void> publierVente(
    UserModel users,
    String title,
    String description,
    double latitude,
    double longitude,
    List<File> images,
    List<String> jaime,
    List<String> commentaire,
    int prix,
    String categorie,
    String currency,
    String nameProduit,
  ) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      await _publierVenteUseCase
          .call(users, title, description, latitude, longitude, images, jaime,
              commentaire, prix, categorie, currency, nameProduit)
          .then((onValue) {
        showCustomSnackBar("Vente publier avec succes");
      });
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> editerVente(
      UserModel users,
      String title,
      String description,
      double latitude,
      double longitude,
      List<File> images,
      List<String> imagesOld,
      List<String> jaime,
      List<String> commentaire,
      int prix,
      String categorie,
      String currency,
      String nameProduit,
      String uidVente,
      bool status) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      await _editerVenteUseCase
          .call(
              users,
              title,
              description,
              latitude,
              longitude,
              images,
              imagesOld,
              jaime,
              commentaire,
              prix,
              categorie,
              currency,
              nameProduit,
              uidVente,
              status)
          .then((onValue) {
        showCustomSnackBar("Vente editer avec succes");
      });
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  // Charger l'état depuis SharedPreferences
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? stateString = prefs.getString('marketplaceUserState');
    if (stateString != null) {
      final Map<String, dynamic> json = jsonDecode(stateString);
      state = MarketplaceUserState.fromJson(json);
    }
  }

  // Sauvegarder l'état dans SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final String stateString = jsonEncode(state.toJson());
    await prefs.setString('marketplaceUserState', stateString);
  }

  Future<void> SetUpdateFieldToFilter({
    required String categorie,
    required RangeValues rangeOfPriceDebutAndFin,
    required String currency,
    required bool isFilterLocation,
    required double latitude,
    required double longitude,
    required String adresse,
    required double radius,
  }) async {
    state = state.copyWith(
        Categorie: categorie,
        currency: currency,
        isFilter: true,
        prixProduit: rangeOfPriceDebutAndFin,
        isFilterLocation: isFilterLocation,
        latitude: latitude,
        longitude: longitude,
        adressMaps: adresse,
        radius: radius);
    calculateBounds(latitude, longitude);
    // Sauvegarde des données dans SharedPreferences
    _saveState();
  }

  Future<void> calculateBounds(double lat, double lon) async {
    const double earthRadiusKm = 6371.0;
    double radiusKm = state.radius / 1000.0;
    // Convertir le rayon en degrés
    double latOffset = (radiusKm / earthRadiusKm) * (180 / pi);
    double lonOffset = latOffset / cos(lat * pi / 180);

    double minLat = lat - latOffset;
    double maxLat = lat + latOffset;
    double minLon = lon - lonOffset;
    double maxLon = lon + lonOffset;
    state = state.copyWith(
        minlongitude: minLon,
        minlatitude: minLat,
        maxlongitude: maxLon,
        maxlatitude: maxLat);
  }

  Future<void> ClearFilterCategorie() async {
    state = state.copyWith(Categorie: "");
    _saveState();
  }

  Future<void> ClearFilterPrix() async {
    if (state.currency == "MGA") {
      state = state.copyWith(
          prixProduit: RangeValues(5000, 50000000), currency: "MGA");
      _saveState();
    } else {
      state =
          state.copyWith(prixProduit: RangeValues(1, 10000), currency: "USD");
      _saveState();
    }
  }

  Future<void> ClearFilterAdresse() async {
    state = state.copyWith(
      adressMaps: "",
      latitude: 0.0,
      longitude: 0.0,
      radius: 10000.0,
      minlongitude: 0.0,
      minlatitude: 0.0,
      maxlongitude: 0.0,
      maxlatitude: 0.0,
      isFilterLocation: false,
    );
    _saveState();
  }

  Future<void> ClearFilterRayon() async {
    state = state.copyWith(radius: 10000.0);
    _saveState();
  }

  Future<void> ClearFilterTerm() async {
    state = state.copyWith(nameSearch: "");
    _saveState();
  }

  Future<void> SetNameSearchTerm(String nameSearch) async {
    state = state.copyWith(nameSearch: nameSearch);
    _saveState();
  }

  Future<void> SetLocation(String adrss, double long, double lat, double rad,
      bool isFilterLoc) async {
    state = state.copyWith(
        adressMaps: adrss,
        longitude: long,
        latitude: lat,
        radius: rad,
        isFilterLocation: isFilterLoc);
    calculateBounds(lat, long);
    _saveState();
  }

  Future<void> ResetFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
        prixProduit: RangeValues(1, 10000),
        Categorie: '',
        adressMaps: '',
        currency: 'USD',
        latitude: 0.0,
        longitude: 0.0,
        nameSearch: '',
        radius: 10000.0,
        minlongitude: 0.0,
        minlatitude: 0.0,
        maxlongitude: 0.0,
        maxlatitude: 0.0,
        isFilterLocation: false,
        isFilter: false);

    // Sauvegarder les valeurs réinitialisées dans SharedPreferences
    _saveState();
  }
}
