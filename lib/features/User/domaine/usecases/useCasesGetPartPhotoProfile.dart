import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseGetPartPhotoProfile {
  final UserRepository userRepository;
  UseCaseGetPartPhotoProfile({required this.userRepository});
  Future<List<Map<String, dynamic>>> call(String userId) async {
    return userRepository.getPartOfPhotoProfileByUser(userId);
  }
}
