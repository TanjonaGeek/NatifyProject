import 'package:equatable/equatable.dart';

class SignalEntity extends Equatable{
  final String? uid_user_signaled;
  final String? uid_user_who_signal;
  final String? raison_signal;
  final String? description;
  final int? timeCreated;
  final String? uid_signal;
  final String? status_signal;

  const SignalEntity({
    required this.uid_user_signaled,
    required this.uid_user_who_signal,
    required this.raison_signal,
    required this.description,
    required this.timeCreated,
    required this.uid_signal,
    required this.status_signal,
  });

  @override
  List < Object ? > get props {
    return [
    uid_user_signaled,
    uid_user_who_signal,
    raison_signal,
    description,
    timeCreated,
    uid_signal,
    status_signal
    ];
  }
}