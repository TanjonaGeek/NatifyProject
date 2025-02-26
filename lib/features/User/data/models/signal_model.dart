import 'package:natify/features/User/domaine/entities/signal_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignalModel extends SignalEntity {
  const SignalModel({
    super.uid_user_signaled,
    super.uid_user_who_signal,
    super.raison_signal,
    super.description,
    super.timeCreated,
    super.uid_signal,
    super.status_signal,
  });

  factory SignalModel.fromJson(Map<String, dynamic> map) {
    return SignalModel(
      uid_user_signaled: map['uid_user_signaled'] ?? '',
      uid_user_who_signal: map['uid_user_who_signal'] ?? '',
      raison_signal: map['raison_signal'] ?? '',
      description: map['description'] ?? '',
      timeCreated: map['timeCreated'] ?? 0,
      uid_signal: map['uid_signal'] ?? '',
      status_signal: map['status_signal'] ?? 'en attente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid_user_signaled': uid_user_signaled,
      'uid_user_who_signal': uid_user_who_signal,
      'raison_signal': raison_signal,
      'description': description,
      'timeCreated': timeCreated,
      'uid_signal': uid_signal,
      'status_signal': status_signal,
    };
  }

  factory SignalModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SignalModel(
      uid_user_signaled: data['uid_user_signaled'],
      uid_user_who_signal: data['uid_user_who_signal'],
      raison_signal: data['raison_signal'],
      description: data['description'],
      timeCreated: data['timeCreated'],
      uid_signal: data['uid_signal'],
      status_signal: data['status_signal'],
    );
  }

  factory SignalModel.fromEntity(SignalEntity entity) {
    return SignalModel(
      uid_user_signaled: entity.uid_user_signaled,
      uid_user_who_signal: entity.uid_user_who_signal,
      raison_signal: entity.raison_signal,
      description: entity.description,
      timeCreated: entity.timeCreated,
      uid_signal: entity.uid_signal,
      status_signal: entity.status_signal,
    );
  }

  SignalEntity toEntity() {
    return SignalEntity(
      uid_user_signaled: uid_user_signaled,
      uid_user_who_signal: uid_user_who_signal,
      raison_signal: raison_signal,
      description: description,
      timeCreated: timeCreated,
      uid_signal: uid_signal,
      status_signal: status_signal,
    );
  }
}
