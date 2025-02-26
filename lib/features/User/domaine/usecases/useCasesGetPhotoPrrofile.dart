import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseGetPhotoProfile {
  final UserRepository userRepository;
  UseCaseGetPhotoProfile({required this.userRepository});

  Future<List<Map<String, dynamic>>> call(String uid) async {
    return userRepository.getPhotoProfile(uid);
  }
}
