import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:natify/core/utils/snack_bar_helpers.dart';
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
  MarketplaceUserNotifier(this.ref) : super(MarketplaceUserState.initial());
  bool get isFetching => state.state != MarketplaceUserConcreteState.loading;
  final firestore = FirebaseFirestore.instance;

  SetUpdateFieldToFilter({
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

    // Sauvegarde des données dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Sauvegarde des valeurs simples
    await prefs.setString('categorieMarket', categorie);
    await prefs.setString('currencyMarket', currency);
    await prefs.setBool('isFilter', true);
    await prefs.setBool(
        'isFilterLocationMarket',
        (adresse == "Chargement..." ||
                adresse == "Impossible d'obtenir la localisation")
            ? false
            : isFilterLocation);
    await prefs.setString(
        'addressMarket',
        (adresse == "Chargement..." ||
                adresse == "Impossible d'obtenir la localisation")
            ? ""
            : adresse);
    await prefs.setDouble('latitudeMarket', latitude);
    await prefs.setDouble('longitudeMarket', longitude);
    await prefs.setDouble('radiusMarket', radius);
    // Sauvegarde des RangeValues comme une chaîne
    await prefs.setString('rangeOfPrixDebutAndFinMarket',
        '${rangeOfPriceDebutAndFin.start.toString()},${rangeOfPriceDebutAndFin.end.toString()}');

    // await searchNearbyUsers();
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
        isFilterLocation: false,
        isFilter: false);

    // Sauvegarder les valeurs réinitialisées dans SharedPreferences
    await prefs.setString('categorieMarket', '');
    await prefs.setString('currencyMarket', 'USD');
    await prefs.setBool('isFilter', false);
    await prefs.setBool('isFilterLocationMarket', false);
    await prefs.setString('addressMarket', '');
    await prefs.setDouble('latitudeMarket', 0.0);
    await prefs.setDouble('radiusMarket', 10000.0);
    await prefs.setDouble('longitudeMarket', 0.0);
    // Sauvegarde des RangeValues comme une chaîne
    await prefs.setString('rangeOfPrixDebutAndFinMarket', '');
    await prefs.setString('nameSearchMarket', '');
  }
}
