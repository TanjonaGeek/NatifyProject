import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseGetAllPhotoProfile {
  final UserRepository userRepository;
  UseCaseGetAllPhotoProfile({required this.userRepository});
  Future<List<Map<String, dynamic>>> call(String userId, int limit) async {
    return userRepository.getAllPhotoProfileByUser(userId, limit);
  }
}
