import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseSignalProfile {
  final UserRepository userRepository;
  UseCaseSignalProfile({required this.userRepository});

  Future<void> call(
      String uidUserSignal, String raison, String description) async {
    return userRepository.signalProfileUser(
        uidUserSignal, raison, description);
  }
}
