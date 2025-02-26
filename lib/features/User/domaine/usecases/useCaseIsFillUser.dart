import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseIsFillUser {
  final UserRepository userRepository;
  UseCaseIsFillUser({required this.userRepository});

  Future<Map<String, dynamic>> call() async {
    return userRepository.isFillCheck();
  }
}
