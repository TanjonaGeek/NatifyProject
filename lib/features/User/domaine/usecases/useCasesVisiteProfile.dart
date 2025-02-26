import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseVisiteProfileUser {
  final UserRepository userRepository;
  UseCaseVisiteProfileUser({required this.userRepository});
  Future<void> call(
      String name,
      String profilePic,
      String uid,
      String uidVisiteur,
      UserEntity userDat,
      String nationalite,
      String flag) async {
    return userRepository.visiteProfile(
        name, profilePic, uid, uidVisiteur, userDat, nationalite, flag);
  }
}
