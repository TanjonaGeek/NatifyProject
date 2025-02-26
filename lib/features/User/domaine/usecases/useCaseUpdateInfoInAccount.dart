import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseUpdateInfoUser {
  final UserRepository userRepository;
  UseCaseUpdateInfoUser({required this.userRepository});
  
  Future<void> call(String userId,String champsName,var dataUpdate, String flag) async {
    return userRepository.UpdateInfoInAccount(userId,champsName,dataUpdate, flag);
  }
}