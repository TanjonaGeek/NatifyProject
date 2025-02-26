import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MapsUserConcreteState { initial, loading, loaded, failure }

class MapsUserState extends Equatable {
  final bool hasData;
  final String message;
  final bool isLoading;
  final bool IsTypeInSearchBar;
  final RangeValues rangeOfageDebutAndFin;
  final String sexe;
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
  final Map<String, Map<String, dynamic>> nationaliteCounts;
  final List<Map<String,dynamic>> listAllUserApproximite;
  final int nombreUtilisateurAproximite;
  final String adressMaps;
  final double radiusCircle; 
  final BitmapDescriptor? customIcon;
  final List<Map<String, String>> nationaliteGroup;
  final List<String> nationaliteGroupSansFlag;
  final MapsUserConcreteState state;

  const MapsUserState({
      this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.IsTypeInSearchBar = false, 
      this.rangeOfageDebutAndFin = const RangeValues(14,90),  
      this.sexe = "", 
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
      this.nationaliteCounts = const {},
      this.listAllUserApproximite = const [],
      this.nombreUtilisateurAproximite = 0,
      this.adressMaps = "",
      this.radiusCircle = 10000.0, // Valeur par défaut
      this.customIcon, 
      this.nationaliteGroup = const [],
      this.nationaliteGroupSansFlag = const [],
      this.state = MapsUserConcreteState.initial
      });

  const MapsUserState.initial(
      {
      this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.IsTypeInSearchBar = false, 
      this.rangeOfageDebutAndFin = const RangeValues(14,90), 
      this.sexe = "", 
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
      this.nationaliteCounts = const {},
      this.listAllUserApproximite = const [],
      this.nombreUtilisateurAproximite = 0,
      this.adressMaps = "",
      this.radiusCircle = 10000.0, // Valeur par défaut
      this.customIcon , 
      this.nationaliteGroup = const [],
      this.nationaliteGroupSansFlag = const [],
      this.state = MapsUserConcreteState.initial
      });

  MapsUserState copyWith({
      bool? hasData,
      String? message,
      bool? isLoading,
      bool? IsTypeInSearchBar,
      RangeValues? rangeOfageDebutAndFin,
      String? sexe,
      String? nationalite,
      String? pays,
      String? flag,
      List<UserEntity>? listAlluser,
      List<UserEntity>? listAlluserTmp,
      List<UserEntity>? listAlluserDisplay,
      bool? hasMore,
      String? nameSearch,
      bool? isFilter,
      Position? position,
      double? zoom,
      double? radius, // En mètres
      GeoFirePoint? mapCenter, // Centre de la carte
      CameraPosition? cameraPosition,
      Set<Marker>? markers,
      Map<String, Map<String, dynamic>>? nationaliteCounts,
      List<Map<String,dynamic>>? listAllUserApproximite,
      int? nombreUtilisateurAproximite,
      String? adressMaps,
      double? radiusCircle, // En mètres
      BitmapDescriptor? customIcon,
      List<Map<String, String>>? nationaliteGroup,
      List<String>? nationaliteGroupSansFlag,
      MapsUserConcreteState? state,
  }) {
    return MapsUserState(
        hasData: hasData ?? this.hasData,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        IsTypeInSearchBar: IsTypeInSearchBar ?? this.IsTypeInSearchBar,
        rangeOfageDebutAndFin: rangeOfageDebutAndFin ?? this.rangeOfageDebutAndFin,
        sexe: sexe ?? this.sexe,
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
        nationaliteCounts: nationaliteCounts ?? this.nationaliteCounts,
        listAllUserApproximite: listAllUserApproximite ?? this.listAllUserApproximite,
        nombreUtilisateurAproximite: nombreUtilisateurAproximite ?? this.nombreUtilisateurAproximite,
        adressMaps: adressMaps ?? this.adressMaps,
        radiusCircle: radiusCircle ?? this.radiusCircle,
        customIcon: customIcon ?? this.customIcon,
        nationaliteGroup: nationaliteGroup ?? this.nationaliteGroup,
        nationaliteGroupSansFlag: nationaliteGroupSansFlag ?? this.nationaliteGroupSansFlag,
        state: state ?? this.state
        );
  }
  @override
  List<Object?> get props => [hasData, message,isLoading , IsTypeInSearchBar,rangeOfageDebutAndFin,sexe,nationalite,pays,flag,nameSearch,isFilter,position,zoom,radius,mapCenter,cameraPosition,markers,nationaliteCounts,nombreUtilisateurAproximite,listAllUserApproximite,adressMaps,radiusCircle,customIcon,nationaliteGroup,nationaliteGroupSansFlag,state];
}
