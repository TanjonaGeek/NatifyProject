import 'package:natify/features/Storie/domaine/repositories/storie_repository.dart';

class UseCaseReactStorie {
  final StorieRepository storieRepository;
  UseCaseReactStorie({required this.storieRepository});

  Future<void> call(
      String userIdVisiteur, int indexEmoji, String urlPhotoReact) async {
    return storieRepository.ReactStory(
        userIdVisiteur, indexEmoji, urlPhotoReact);
  }
}
