import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseAbonner {
  final UserRepository userRepository;
  UseCaseAbonner({required this.userRepository});
  
  Future<void> call(String uidUser , String uidNotification) async {
    return userRepository.Abonner(uidUser, uidNotification);
  }
}