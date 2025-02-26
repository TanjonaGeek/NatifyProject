import 'dart:io';
import 'package:natify/features/Storie/domaine/repositories/storie_repository.dart';

class UseCaseCreateStorie {
  final StorieRepository storieRepository;
  UseCaseCreateStorie({required this.storieRepository});

  Future<void> call(List<File> statusImage, String type) async {
    return storieRepository.createStory(statusImage, type);
  }
}
