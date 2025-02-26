import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class useCaseRemoveReceiveNotificatonByUser {
  final UserRepository userRepository;
  useCaseRemoveReceiveNotificatonByUser({required this.userRepository});

  Future<void> call(String uidUser, String uidNotification) async {
    return userRepository.removeToReceiveNotificationFollowerByUser(
        uidUser, uidNotification);
  }
}
