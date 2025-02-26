import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseUpdateStatusUser {
  final UserRepository userRepository;
  UseCaseUpdateStatusUser({required this.userRepository});
  Future<void> call(bool isOnline, String uid) async {
    return userRepository.updateStatusUser(isOnline, uid);
  }
}
