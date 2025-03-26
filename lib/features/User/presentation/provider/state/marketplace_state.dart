import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum MarketplaceUserConcreteState { initial, loading, loaded, failure }

class MarketplaceUserState extends Equatable {
  final bool hasData;
  final String message;
  final bool isLoading;
  final bool IsTypeInSearchBar;
  final RangeValues prixProduit;
  final String Categorie;
  final String nameSearch;
  final bool isFilter;
  final bool isFilterLocation;
  final double latitude;
  final double longitude;
  final String adressMaps;
  final MarketplaceUserConcreteState state;
  final String currency;
  final double radius;

  const MarketplaceUserState({
    this.hasData = false,
    this.message = '',
    this.isLoading = false,
    this.IsTypeInSearchBar = false,
    this.prixProduit = const RangeValues(1, 10000),
    this.Categorie = "",
    this.nameSearch = '',
    this.isFilter = false,
    this.isFilterLocation = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.adressMaps = "",
    this.state = MarketplaceUserConcreteState.initial,
    this.currency = "USD",
    this.radius = 10000.0,
  });

  MarketplaceUserState copyWith({
    bool? hasData,
    String? message,
    bool? isLoading,
    bool? IsTypeInSearchBar,
    RangeValues? prixProduit,
    String? Categorie,
    bool? hasMore,
    String? nameSearch,
    bool? isFilter,
    bool? isFilterLocation,
    double? latitude,
    double? longitude,
    String? adressMaps,
    MarketplaceUserConcreteState? state,
    String? currency,
    double? radius,
  }) {
    return MarketplaceUserState(
      hasData: hasData ?? this.hasData,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      IsTypeInSearchBar: IsTypeInSearchBar ?? this.IsTypeInSearchBar,
      prixProduit: prixProduit ?? this.prixProduit,
      Categorie: Categorie ?? this.Categorie,
      isFilter: isFilter ?? this.isFilter,
      isFilterLocation: isFilterLocation ?? this.isFilterLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      nameSearch: nameSearch ?? this.nameSearch,
      adressMaps: adressMaps ?? this.adressMaps,
      state: state ?? this.state,
      currency: currency ?? this.currency,
      radius: radius ?? this.radius,
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'hasData': hasData,
      'message': message,
      'isLoading': isLoading,
      'IsTypeInSearchBar': IsTypeInSearchBar,
      'prixProduit': [prixProduit.start, prixProduit.end],
      'Categorie': Categorie,
      'nameSearch': nameSearch,
      'isFilter': isFilter,
      'isFilterLocation': isFilterLocation,
      'latitude': latitude,
      'longitude': longitude,
      'adressMaps': adressMaps,
      'state': state.index,
      'currency': currency,
      'radius': radius,
    };
  }

  // Reconstruire depuis JSON
  factory MarketplaceUserState.fromJson(Map<String, dynamic> json) {
    return MarketplaceUserState(
      hasData: json['hasData'] ?? false,
      message: json['message'] ?? '',
      isLoading: json['isLoading'] ?? false,
      IsTypeInSearchBar: json['IsTypeInSearchBar'] ?? false,
      prixProduit: json['prixProduit'] != null
          ? RangeValues(json['prixProduit'][0], json['prixProduit'][1])
          : const RangeValues(1, 10000),
      Categorie: json['Categorie'] ?? '',
      nameSearch: json['nameSearch'] ?? '',
      isFilter: json['isFilter'] ?? false,
      isFilterLocation: json['isFilterLocation'] ?? false,
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      adressMaps: json['adressMaps'] ?? '',
      state: MarketplaceUserConcreteState.values[json['state'] ?? 0],
      currency: json['currency'] ?? 'USD',
      radius: json['radius'] ?? 10000.0,
    );
  }

  @override
  List<Object?> get props => [
        hasData,
        message,
        isLoading,
        IsTypeInSearchBar,
        prixProduit,
        Categorie,
        nameSearch,
        isFilter,
        isFilterLocation,
        latitude,
        longitude,
        adressMaps,
        state,
        currency,
        radius,
      ];
}
