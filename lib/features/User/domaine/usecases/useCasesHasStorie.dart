import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseCheckHasStorie {
  final UserRepository userRepository;
  UseCaseCheckHasStorie({required this.userRepository});

  Future<Map<String, dynamic>> call(String uid) async {
    return userRepository.checkifHasStorie(uid);
  }
}
