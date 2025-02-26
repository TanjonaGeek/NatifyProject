import 'package:natify/features/User/domaine/entities/userphoto_entities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPhotoModel extends UserPhotoEntity {
  const UserPhotoModel({
    super.urlPhoto,
    super.timeCreated,
    super.type,
  });

  factory UserPhotoModel.fromJson(Map<String, dynamic> map) {
    return UserPhotoModel(
      urlPhoto: map['urlPhoto'] ?? '',
      timeCreated: map['timeCreated'] ?? 0,
      type: map['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'urlPhoto': urlPhoto,
      'timeCreated': timeCreated,
      'type': type,
    };
  }

  factory UserPhotoModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserPhotoModel(
      urlPhoto: data['urlPhoto'],
      timeCreated: data['timeCreated'],
      type: data['type'],
    );
  }

  factory UserPhotoModel.fromEntity(UserPhotoEntity entity) {
    return UserPhotoModel(
      urlPhoto: entity.urlPhoto,
      timeCreated: entity.timeCreated,
      type: entity.type,
    );
  }

  UserPhotoEntity toEntity() {
    return UserPhotoEntity(
      urlPhoto: urlPhoto,
      timeCreated: timeCreated,
      type: type,
    );
  }
}
