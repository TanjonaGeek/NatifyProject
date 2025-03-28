import 'dart:io';

import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseEditerVente {
  final UserRepository userRepository;
  UseCaseEditerVente({required this.userRepository});

  Future<void> call(
      UserModel users,
      String title,
      String description,
      double latitude,
      double longitude,
      List<File> images,
      List<String> imagesOld,
      List<String> jaime,
      List<String> commentaire,
      int prix,
      String categorie,
      String currency,
      String nameProduit,
      String uidVente,
      bool status) async {
    return userRepository.editerVente(
        users,
        title,
        description,
        latitude,
        longitude,
        images,
        imagesOld,
        jaime,
        commentaire,
        prix,
        categorie,
        currency,
        nameProduit,
        uidVente,
        status);
  }
}
