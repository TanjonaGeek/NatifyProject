import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseDeleteAccount {
  final UserRepository userRepository;
  UseCaseDeleteAccount({required this.userRepository});

  Future<void> call(String userUid) async {
    return userRepository.DeleteAccount(userUid);
  }
}
