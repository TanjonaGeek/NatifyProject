import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natify/features/User/presentation/provider/state/marketplace_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketplaceUserNotifier extends StateNotifier<MarketplaceUserState> {
  final Ref ref;
  MarketplaceUserNotifier(this.ref) : super(MarketplaceUserState()) {
    _loadState(); // Charger l'état sauvegardé au démarrage
  }
  bool get isFetching => state.state != MarketplaceUserConcreteState.loading;

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

    // Sauvegarde des données dans SharedPreferences
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
        isFilterLocation: false,
        isFilter: false);

    // Sauvegarder les valeurs réinitialisées dans SharedPreferences
    _saveState();
  }
}
