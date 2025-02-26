import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseSupprimerPhotoProfiles {
  final UserRepository userRepository;
  UseCaseSupprimerPhotoProfiles({required this.userRepository});

  Future<void> call(String uidUser, String urlPhoto) async {
    return userRepository.SuprrimerPhotoProfile(uidUser, urlPhoto);
  }
}
