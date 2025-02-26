import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseSendNotificationHighLightFollowers {
  final UserRepository userRepository;
  UseCaseSendNotificationHighLightFollowers({required this.userRepository});

  Future<void> call() async {
    return userRepository.sendNotificationToFollowers();
  }
}
