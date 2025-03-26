import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MarketPlaceEntity extends Equatable {
  final String? title;
  final String? description;
  final GeoPoint? location;
  final List<String>? images;
  final String? uidVente;
  final String? organizerUid;
  final String? organizerName;
  final String? organizerPhoto;
  final String? codeCoutargetCountryntry;
  final String? targetNationality;
  final int? createdAt;
  final List<Map<String, dynamic>>? jaime;
  final List<Map<String, dynamic>>? commentaire;
  final int? prix;
  final String? categorie;
  final String? currency;
  final List<String>? nameProduit;

  const MarketPlaceEntity({
    required this.title,
    required this.description,
    required this.location,
    required this.images,
    required this.uidVente,
    required this.organizerUid,
    required this.organizerName,
    required this.organizerPhoto,
    required this.codeCoutargetCountryntry,
    required this.targetNationality,
    required this.createdAt,
    required this.jaime,
    required this.commentaire,
    required this.prix,
    required this.categorie,
    required this.currency,
    required this.nameProduit,
  });

  @override
  List<Object?> get props {
    return [
      title,
      description,
      location,
      images,
      uidVente,
      organizerUid,
      organizerName,
      organizerPhoto,
      codeCoutargetCountryntry,
      targetNationality,
      createdAt,
      jaime,
      commentaire,
      prix,
      categorie,
      currency,
      nameProduit
    ];
  }
}
