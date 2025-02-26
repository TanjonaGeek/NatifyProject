import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseUpdateStatusAutorisation {
  final UserRepository userRepository;
  UseCaseUpdateStatusAutorisation({required this.userRepository});
  Future<void> call(bool status, String fieldNameUpdate) async {
    return userRepository.updateStatusAutorisation(status, fieldNameUpdate);
  }
}
