import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseDesabonner {
  final UserRepository userRepository;
  UseCaseDesabonner({required this.userRepository});
  
  Future<void> call(String uidUser , String uidNotification) async {
    return userRepository.Desabonner(uidUser, uidNotification);
  }
}