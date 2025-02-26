import 'package:natify/features/Storie/domaine/repositories/storie_repository.dart';

class UseCaseDeleteStorie {
  final StorieRepository storieRepository;
  UseCaseDeleteStorie({required this.storieRepository});

  Future<void> call(String photoUrl, String statusId) async {
    return storieRepository.DeleteStory(photoUrl, statusId);
  }
}
