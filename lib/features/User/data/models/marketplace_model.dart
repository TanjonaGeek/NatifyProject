import 'package:natify/features/User/domaine/entities/marketplace_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceModel extends MarketPlaceEntity {
  const MarketplaceModel({
    super.title,
    super.description,
    super.location,
    super.images,
    super.uidVente,
    super.organizerUid,
    super.organizerName,
    super.organizerPhoto,
    super.codeCoutargetCountryntry,
    super.targetNationality,
    super.createdAt,
    super.jaime,
    super.commentaire,
    super.prix,
    super.categorie,
    super.currency,
    super.nameProduit,
    super.latitude,
    super.longitude,
    super.favorie,
    super.vue,
  });

  factory MarketplaceModel.fromJson(Map<String, dynamic> map) {
    return MarketplaceModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] is GeoPoint ? map['location'] : null,
      images: List<String>.from(map['images']),
      uidVente: map['uidVente'] ?? '',
      organizerUid: map['organizerUid'] ?? '',
      organizerName: map['organizerName'] ?? '',
      organizerPhoto: map['organizerPhoto'] ?? '',
      codeCoutargetCountryntry: map['codeCoutargetCountryntry'] ?? '',
      targetNationality: map['targetNationality'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      jaime: List<Map<String, dynamic>>.from(map['jaime']),
      commentaire: List<Map<String, dynamic>>.from(map['commentaire']),
      prix: map['prix'] ?? 1,
      categorie: map['categorie'] ?? '',
      currency: map['currency'] ?? 'USD',
      nameProduit: List<String>.from(map['nameProduit']) ?? [],
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      favorie: List<String>.from(map['favorie']),
      vue: List<String>.from(map['vue']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'images': images,
      'uidVente': uidVente,
      'organizerUid': organizerUid,
      'organizerName': organizerName,
      'organizerPhoto': organizerPhoto,
      'codeCoutargetCountryntry': codeCoutargetCountryntry,
      'targetNationality': targetNationality,
      'createdAt': createdAt,
      'jaime': jaime,
      'commentaire': commentaire,
      'prix': prix,
      'categorie': categorie,
      'currency': currency,
      'nameProduit': nameProduit,
      'latitude': latitude,
      'longitude': longitude,
      'favorie': favorie,
      'vue': vue,
    };
  }

  factory MarketplaceModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketplaceModel(
      title: data['title'],
      description: data['description'],
      location: data['location'] is GeoPoint ? data['location'] : null,
      images: data['images'],
      uidVente: data['uidVente'],
      organizerUid: data['organizerUid'],
      organizerName: data['organizerName'],
      organizerPhoto: data['organizerPhoto'],
      codeCoutargetCountryntry: data['codeCoutargetCountryntry'],
      targetNationality: data['targetNationality'],
      createdAt: data['createdAt'],
      jaime: data['jaime'],
      commentaire: data['commentaire'],
      prix: data['prix'],
      categorie: data['categorie'],
      currency: data['currency'],
      nameProduit: data['nameProduit'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      favorie: data['favorie'],
      vue: data['vue'],
    );
  }

  factory MarketplaceModel.fromEntity(MarketPlaceEntity entity) {
    return MarketplaceModel(
      title: entity.title,
      description: entity.description,
      location: entity.location,
      images: entity.images,
      uidVente: entity.uidVente,
      organizerUid: entity.organizerUid,
      organizerName: entity.organizerName,
      organizerPhoto: entity.organizerPhoto,
      codeCoutargetCountryntry: entity.codeCoutargetCountryntry,
      targetNationality: entity.targetNationality,
      createdAt: entity.createdAt,
      jaime: entity.jaime,
      commentaire: entity.commentaire,
      prix: entity.prix,
      categorie: entity.categorie,
      currency: entity.currency,
      nameProduit: entity.nameProduit,
      latitude: entity.latitude,
      longitude: entity.longitude,
      favorie: entity.favorie,
      vue: entity.vue,
    );
  }

  MarketPlaceEntity toEntity() {
    return MarketPlaceEntity(
        title: title,
        description: description,
        location: location,
        images: images,
        uidVente: uidVente,
        organizerUid: organizerUid,
        organizerName: organizerName,
        organizerPhoto: organizerPhoto,
        codeCoutargetCountryntry: codeCoutargetCountryntry,
        targetNationality: targetNationality,
        createdAt: createdAt,
        jaime: jaime,
        commentaire: commentaire,
        prix: prix,
        categorie: categorie,
        currency: currency,
        nameProduit: nameProduit,
        latitude: latitude,
        longitude: longitude,
        favorie: favorie,
        vue: vue);
  }
}
