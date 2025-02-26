import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseSignOut {
  final UserRepository userRepository;
  UseCaseSignOut({required this.userRepository});
  
  Future<void> call() async {
    return userRepository.SignOut();
  }
}