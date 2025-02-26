import 'package:natify/features/User/domaine/repositories/user_repository.dart';

class UseCaseMyInfoData {
  final UserRepository userRepository;
  UseCaseMyInfoData({required this.userRepository});
  
  Future<Map<String, dynamic>> call() async {
    return userRepository.myDataInfo();
  }
}