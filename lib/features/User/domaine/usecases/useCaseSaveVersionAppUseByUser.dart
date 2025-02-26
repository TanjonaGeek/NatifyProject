import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class useCaseSaveVersionUseByUser {
  final UserRepository userRepository;
  useCaseSaveVersionUseByUser({required this.userRepository});
  
  Future<void> call(String versionNumero) async {
    return userRepository.saveVersionUse(versionNumero);
  }
}