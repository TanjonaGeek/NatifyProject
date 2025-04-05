import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseDeFavoriser {
  final UserRepository userRepository;
  UseCaseDeFavoriser({required this.userRepository});

  Future<void> call(
      String uidMe, String uidNotification, String uidVente) async {
    return userRepository.Defavorier(uidMe, uidNotification, uidVente);
  }
}
