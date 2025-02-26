import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class useCaseAddReceiveNotificatonByUser {
  final UserRepository userRepository;
  useCaseAddReceiveNotificatonByUser({required this.userRepository});

  Future<void> call(String uidUser, String uidNotification) async {
    return userRepository.addToReceiveNotificationFollowerByUser(
        uidUser, uidNotification);
  }
}
