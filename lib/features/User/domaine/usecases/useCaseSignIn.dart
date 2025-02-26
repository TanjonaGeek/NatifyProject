import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseSignIn {
  final UserRepository userRepository;
  UseCaseSignIn({required this.userRepository});

  Future<void> call(String userUid) async {
    return userRepository.SignIn(userUid);
  }
}
