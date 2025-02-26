import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable{
  final String? name;
  final String? profilePic;
  final String? contactId;
  final int? timeSent;
  final String? MessageNotification;
  final String? nationalite;
  final int? nombreVisiteurs;
  final bool? statusRead;
  final String? type;
  final String? flag;
  final List<String>? uidUserVisite;
  final bool? statusOnSee;

  const NotificationEntity({
    required this.name,
    required this.profilePic,
    required this.contactId,
    required this.timeSent,
    required this.MessageNotification,
    required this.nationalite,
    required this.nombreVisiteurs,
    required this.statusRead,
    required this.type,
    required this.flag,
    required this.uidUserVisite,
    required this.statusOnSee,
  });

  @override
  List < Object ? > get props {
    return [
    name,
    profilePic,
    contactId,
    timeSent,
    MessageNotification,
    nationalite,
    nombreVisiteurs,
    statusRead,
    type,
    flag,
    uidUserVisite,
    statusOnSee
    ];
  }
}