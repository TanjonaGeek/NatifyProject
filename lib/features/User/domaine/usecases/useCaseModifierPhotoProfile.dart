import 'dart:io';

import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseModifierPhotoProfiles {
  final UserRepository userRepository;
  UseCaseModifierPhotoProfiles({required this.userRepository});

  Future<void> call(String uidUser, List<File> profilePic) async {
    return userRepository.ModifierPhotoProfile(uidUser, profilePic);
  }
}
