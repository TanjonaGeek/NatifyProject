import 'dart:io';
import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseCreateHighLight {
  final UserRepository userRepository;
  UseCaseCreateHighLight({required this.userRepository});

  Future<void> call(
    List<File> images,
    String titre,
    String profilePic,
    String type,
  ) async {
    return userRepository.InsertCollection(images, titre, profilePic, type);
  }
}
