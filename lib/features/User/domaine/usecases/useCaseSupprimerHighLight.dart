import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseSupprimerHighLight {
  final UserRepository userRepository;
  UseCaseSupprimerHighLight({required this.userRepository});

  Future<void> call(List dataActually, String uidVisiteur, String collectionId,
      int index, int createdAt, String titre) async {
    return userRepository.SupprimerCollection(
        dataActually, uidVisiteur, collectionId, index, createdAt, titre);
  }
}
