import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseSignUp {
  final UserRepository userRepository;
  UseCaseSignUp({required this.userRepository});

  Future<void> call(String uid, String name, String photoURL) async {
    return userRepository.SignUp(uid, name, photoURL);
  }
}
