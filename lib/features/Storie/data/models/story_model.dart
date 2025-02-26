import 'package:natify/features/Storie/domaine/entities/storie_entities.dart';

class StorieModel extends StorieEntity {
  const StorieModel({
    super.uid,
    super.username,
    super.photoUrl,
    super.createdAt,
    super.profilePic,
    super.statusId,
    super.QuivoirStorie,
    super.storyAvailableForUser,
  });

  factory StorieModel.fromJson(Map<String, dynamic> map) {
    return StorieModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      photoUrl: List<Map<String, dynamic>>.from(map['photoUrl']),
      createdAt: map['createdAt'] ?? 0,
      profilePic: map['profilePic'] ?? '',
      statusId: map['statusId'] ?? '',
      QuivoirStorie: List<Map<String, dynamic>>.from(map['QuivoirStorie']),
      storyAvailableForUser: List<String>.from(map['storyAvailableForUser']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'profilePic': profilePic,
      'statusId': statusId,
      'QuivoirStorie': QuivoirStorie,
      'storyAvailableForUser': storyAvailableForUser,
    };
  }

  factory StorieModel.fromEntity(StorieEntity entity) {
    return StorieModel(
      uid: entity.uid,
      username: entity.username,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      profilePic: entity.profilePic,
      statusId: entity.statusId,
      QuivoirStorie: entity.QuivoirStorie,
      storyAvailableForUser: entity.storyAvailableForUser,
    );
  }

  StorieEntity toEntity() {
    return StorieEntity(
      uid: uid,
      username: username,
      photoUrl: photoUrl,
      createdAt: createdAt,
      profilePic: profilePic,
      statusId: statusId,
      QuivoirStorie: QuivoirStorie,
      storyAvailableForUser: storyAvailableForUser,
    );
  }
}
