import 'dart:io';

import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseUpdateAllInfoUser {
  final UserRepository userRepository;
  UseCaseUpdateAllInfoUser({required this.userRepository});
  Future<void> call(
      String userId,
      String name,
      String nom,
      String prenom,
      String flag,
      String pays,
      String nationalite,
      List<File> profilePic,
      List<Map<String, dynamic>> age,
      String sexe,
      String bio,
      List<Map<String, dynamic>> situationamoureux,
      List<Map<String, dynamic>> universite,
      List<Map<String, dynamic>> college,
      List<Map<String, dynamic>> emploi) async {
    return userRepository.UpdateAllInAccount(
        userId,
        name,
        nom,
        prenom,
        flag,
        pays,
        nationalite,
        profilePic,
        age,
        sexe,
        bio,
        situationamoureux,
        universite,
        college,
        emploi);
  }
}
