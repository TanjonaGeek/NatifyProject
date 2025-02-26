import 'package:equatable/equatable.dart';

class StorieEntity extends Equatable {
  final String? uid;
  final String? username;
  final List<Map<String, dynamic>>? photoUrl;
  final int? createdAt;
  final String? profilePic;
  final String? statusId;
  final List<Map<String, dynamic>>? QuivoirStorie;
  final List<String>? storyAvailableForUser;

  const StorieEntity({
    required this.uid,
    required this.username,
    required this.photoUrl,
    required this.createdAt,
    required this.profilePic,
    required this.statusId,
    required this.QuivoirStorie,
    required this.storyAvailableForUser,
  });

  @override
  List<Object?> get props {
    return [
      uid,
      username,
      photoUrl,
      createdAt,
      profilePic,
      statusId,
      QuivoirStorie,
      storyAvailableForUser
    ];
  }
}
