import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MarketplaceUserConcreteState { initial, loading, loaded, failure }

class MarketplaceUserState extends Equatable {
  final bool hasData;
  final String message;
  final bool isLoading;
  final bool IsTypeInSearchBar;
  final RangeValues prixProduit;
  final String Categorie;
  final String nationalite;
  final String pays;
  final String flag;
  final String nameSearch;
  final bool isFilter;
  final Position? position;
  final double zoom;
  final double radius; // En mètres
  final GeoFirePoint? mapCenter; // Centre de la carte
  final CameraPosition? cameraPosition;
  final Set<Marker> markers; // Marqueurs à afficher sur la carte
  final String adressMaps;
  final double radiusCircle;
  final BitmapDescriptor? customIcon;
  final List<Map<String, String>> nationaliteGroup;
  final List<String> nationaliteGroupSansFlag;
  final MarketplaceUserConcreteState state;

  const MarketplaceUserState(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.IsTypeInSearchBar = false,
      this.prixProduit = const RangeValues(1, 10000),
      this.Categorie = "",
      this.nationalite = "",
      this.pays = "",
      this.flag = "",
      this.nameSearch = '',
      this.isFilter = false,
      this.position,
      this.zoom = 11.2,
      this.radius = 10000.0, // Valeur par défaut
      this.mapCenter,
      this.cameraPosition,
      this.markers = const <Marker>{},
      this.adressMaps = "",
      this.radiusCircle = 10000.0, // Valeur par défaut
      this.customIcon,
      this.nationaliteGroup = const [],
      this.nationaliteGroupSansFlag = const [],
      this.state = MarketplaceUserConcreteState.initial});

  const MarketplaceUserState.initial(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.IsTypeInSearchBar = false,
      this.prixProduit = const RangeValues(1, 10000),
      this.Categorie = "",
      this.nationalite = "",
      this.pays = "",
      this.flag = "",
      this.nameSearch = '',
      this.isFilter = false,
      this.position,
      this.zoom = 11.2,
      this.radius = 10000.0, // Valeur par défaut
      this.mapCenter,
      this.cameraPosition,
      this.markers = const <Marker>{},
      this.adressMaps = "",
      this.radiusCircle = 10000.0, // Valeur par défaut
      this.customIcon,
      this.nationaliteGroup = const [],
      this.nationaliteGroupSansFlag = const [],
      this.state = MarketplaceUserConcreteState.initial});

  MarketplaceUserState copyWith({
    bool? hasData,
    String? message,
    bool? isLoading,
    bool? IsTypeInSearchBar,
    RangeValues? prixProduit,
    String? Categorie,
    String? nationalite,
    String? pays,
    String? flag,
    bool? hasMore,
    String? nameSearch,
    bool? isFilter,
    Position? position,
    double? zoom,
    double? radius, // En mètres
    GeoFirePoint? mapCenter, // Centre de la carte
    CameraPosition? cameraPosition,
    Set<Marker>? markers,
    String? adressMaps,
    double? radiusCircle, // En mètres
    BitmapDescriptor? customIcon,
    List<Map<String, String>>? nationaliteGroup,
    List<String>? nationaliteGroupSansFlag,
    MarketplaceUserConcreteState? state,
  }) {
    return MarketplaceUserState(
        hasData: hasData ?? this.hasData,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        IsTypeInSearchBar: IsTypeInSearchBar ?? this.IsTypeInSearchBar,
        prixProduit: prixProduit ?? this.prixProduit,
        Categorie: Categorie ?? this.Categorie,
        nationalite: nationalite ?? this.nationalite,
        pays: pays ?? this.pays,
        flag: flag ?? this.flag,
        isFilter: isFilter ?? this.isFilter,
        nameSearch: nameSearch ?? this.nameSearch,
        position: position ?? this.position,
        zoom: zoom ?? this.zoom,
        radius: radius ?? this.radius,
        mapCenter: mapCenter ?? this.mapCenter,
        cameraPosition: cameraPosition ?? this.cameraPosition,
        markers: markers ?? this.markers,
        adressMaps: adressMaps ?? this.adressMaps,
        radiusCircle: radiusCircle ?? this.radiusCircle,
        customIcon: customIcon ?? this.customIcon,
        nationaliteGroup: nationaliteGroup ?? this.nationaliteGroup,
        nationaliteGroupSansFlag:
            nationaliteGroupSansFlag ?? this.nationaliteGroupSansFlag,
        state: state ?? this.state);
  }

  @override
  List<Object?> get props => [
        hasData,
        message,
        isLoading,
        IsTypeInSearchBar,
        prixProduit,
        Categorie,
        nationalite,
        pays,
        flag,
        nameSearch,
        isFilter,
        position,
        zoom,
        radius,
        mapCenter,
        cameraPosition,
        markers,
        adressMaps,
        radiusCircle,
        customIcon,
        nationaliteGroup,
        nationaliteGroupSansFlag,
        state
      ];
}
