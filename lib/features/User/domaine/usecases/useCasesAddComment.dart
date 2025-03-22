import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class useCaseAddCommentVente {
  final UserRepository userRepository;
  useCaseAddCommentVente({required this.userRepository});

  Future<void> call(
      String venteId, String userId, String text, String parentId) async {
    return userRepository.addCommentVente(venteId, userId, text, parentId);
  }
}
