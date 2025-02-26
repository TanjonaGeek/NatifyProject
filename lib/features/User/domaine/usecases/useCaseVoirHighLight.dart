import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseVoirHighLight {
  final UserRepository userRepository;
  UseCaseVoirHighLight({required this.userRepository});

  Future<void> call(List viewerActually, String uidVisiteur,
      String collectionId, String photoUrl) async {
    return userRepository.VoirCollection(
        viewerActually, uidVisiteur, collectionId, photoUrl);
  }
}
