import 'package:natify/features/Storie/domaine/repositories/storie_repository.dart';

class UseCaseSendNotificationFollowers {
  final StorieRepository storieRepository;
  UseCaseSendNotificationFollowers({required this.storieRepository});
  
  Future<void> call() async {
    return storieRepository.sendNotificationToFollowers();
  }
}