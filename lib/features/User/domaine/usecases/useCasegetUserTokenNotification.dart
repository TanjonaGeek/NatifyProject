import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseGetToken {
  final UserRepository userRepository;
  UseCaseGetToken({required this.userRepository});

  Future<String?> call() async {
    return userRepository.getUserTokenNotification();
  }
}
