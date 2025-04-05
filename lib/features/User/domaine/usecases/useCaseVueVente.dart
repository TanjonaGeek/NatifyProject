import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseVueVente {
  final UserRepository userRepository;
  UseCaseVueVente({required this.userRepository});

  Future<void> call(
      String uidMe, String uidNotification, String uidVente) async {
    return userRepository.VueVente(uidMe, uidNotification, uidVente);
  }
}
