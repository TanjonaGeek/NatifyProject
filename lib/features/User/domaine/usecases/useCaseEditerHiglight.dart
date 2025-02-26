import 'dart:io';
import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseEditereHighLight {
  final UserRepository userRepository;
  UseCaseEditereHighLight({required this.userRepository});

  Future<void> call(List<File> images, String profilePic, String titre,
      String collectionId, List dataActually, int createdAt) async {
    return userRepository.EditerCollection(
        images, profilePic, titre, collectionId, dataActually, createdAt);
  }
}
