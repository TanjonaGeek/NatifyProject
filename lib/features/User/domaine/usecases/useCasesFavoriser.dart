import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseFavoriser {
  final UserRepository userRepository;
  UseCaseFavoriser({required this.userRepository});

  Future<void> call(
      String uidMe, String uidNotification, String uidVente) async {
    return userRepository.Favoriser(uidMe, uidNotification, uidVente);
  }
}
