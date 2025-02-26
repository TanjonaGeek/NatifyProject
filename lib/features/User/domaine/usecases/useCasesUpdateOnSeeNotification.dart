import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseUpdateStatusOnSeeNotification {
  final UserRepository userRepository;
  UseCaseUpdateStatusOnSeeNotification({required this.userRepository});
  Future<void> call(bool status) async {
    return userRepository.updateStatusOnSeeNotification(status);
  }
}
