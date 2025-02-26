import 'package:natify/features/Storie/domaine/repositories/storie_repository.dart';

class UseCaseViewStorie {
  final StorieRepository storieRepository;
  UseCaseViewStorie({required this.storieRepository});

  Future<void> call(String userUid, String photoUrl) async {
    return storieRepository.ViewStory(userUid, photoUrl);
  }
}
