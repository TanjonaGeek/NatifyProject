import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseUpdateDistancePosition {
  final UserRepository userRepository;
  UseCaseUpdateDistancePosition({required this.userRepository});
  Future<void> call(bool status) async {
    return userRepository.updateStatusDistancePosition(status);
  }
}
