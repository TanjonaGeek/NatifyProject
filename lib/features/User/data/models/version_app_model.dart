import 'package:natify/features/User/domaine/entities/version_app_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VersionAppModel extends VersionAppEntity {
  const VersionAppModel({
    super.numeroVersion,
  });

  factory VersionAppModel.fromJson(Map<String, dynamic> map) {
    return VersionAppModel(
      numeroVersion: map['numeroVersion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numeroVersion': numeroVersion,
    };
  }

  factory VersionAppModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VersionAppModel(
      numeroVersion: data['numeroVersion'],
    );
  }

  factory VersionAppModel.fromEntity(VersionAppEntity entity) {
    return VersionAppModel(
      numeroVersion: entity.numeroVersion,
    );
  }

  VersionAppEntity toEntity() {
    return VersionAppEntity(
      numeroVersion: numeroVersion,
    );
  }
}
