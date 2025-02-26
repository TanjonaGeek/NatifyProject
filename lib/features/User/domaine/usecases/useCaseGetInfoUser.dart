import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseGetInfoUser {
  final UserRepository userRepository;
  UseCaseGetInfoUser({required this.userRepository});

  Future<List<UserModel>> call(String userId) async {
    return userRepository.getInfoUser(userId);
  }
}
