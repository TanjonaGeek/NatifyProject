import 'dart:io';

import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCasePublierVente {
  final UserRepository userRepository;
  UseCasePublierVente({required this.userRepository});

  Future<void> call(
      UserModel users,
      String title,
      String description,
      double latitude,
      double longitude,
      List<File> images,
      List<String> jaime,
      List<String> commentaire,
      int prix,
      String categorie,
      String currency,
      String nameProduit) async {
    return userRepository.publierVente(
        users,
        title,
        description,
        latitude,
        longitude,
        images,
        jaime,
        commentaire,
        prix,
        categorie,
        currency,
        nameProduit);
  }
}
