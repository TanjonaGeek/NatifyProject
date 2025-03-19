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
    );
  }
}
