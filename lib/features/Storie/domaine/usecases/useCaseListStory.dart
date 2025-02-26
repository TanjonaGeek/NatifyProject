import 'package:natify/features/Storie/domaine/repositories/storie_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UseCaseGetStorie {
  final StorieRepository storieRepository;
  UseCaseGetStorie({required this.storieRepository});

  Future<Map<String, dynamic>> call(
    DocumentSnapshot? lastDocument,
    int limit,
  ) async {
    return storieRepository.getAllStory(
      lastDocument,
      limit,
    );
  }
}
