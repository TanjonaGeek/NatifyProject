import 'package:natify/features/User/domaine/entities/notification_entities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    super.name,
    super.profilePic,
    super.contactId,
    super.timeSent,
    super.MessageNotification,
    super.nationalite,
    super.nombreVisiteurs,
    super.statusRead,
    super.type,
    super.flag,
    super.uidUserVisite,
    super.statusOnSee,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> map) {
    return NotificationModel(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      contactId: map['contactId'] ?? '',
      timeSent: map['timeSent'] ?? 0,
      MessageNotification: map['MessageNotification'] ?? '',
      nationalite: map['nationalite'] ?? '',
      nombreVisiteurs: map['nombreVisiteurs'] ?? 1,
      statusRead: map['statusRead'] ?? false,
      type: map['type'] ?? '',
      flag: map['flag'] ?? '',
      uidUserVisite: List<String>.from(map['uidUserVisite']),
      statusOnSee: map['statusOnSee'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent,
      'MessageNotification': MessageNotification,
      'nationalite': nationalite,
      'nombreVisiteurs': nombreVisiteurs,
      'statusRead': statusRead,
      'type': type,
      'flag': flag,
      'uidUserVisite': uidUserVisite,
      'statusOnSee': statusOnSee,
    };
  }

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      name: data['name'],
      profilePic: data['profilePic'],
      contactId: data['contactId'],
      timeSent: data['timeSent'],
      MessageNotification: data['MessageNotification'],
      nationalite: data['nationalite'],
      nombreVisiteurs: data['nombreVisiteurs'],
      statusRead: data['statusRead'],
      type: data['type'],
      flag: data['flag'],
      uidUserVisite: data['uidUserVisite'],
      statusOnSee: data['statusOnSee'],
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
        name: entity.name,
        profilePic: entity.profilePic,
        contactId: entity.contactId,
        timeSent: entity.timeSent,
        MessageNotification: entity.MessageNotification,
        nationalite: entity.nationalite,
        nombreVisiteurs: entity.nombreVisiteurs,
        statusRead: entity.statusRead,
        type: entity.type,
        flag: entity.flag,
        uidUserVisite: entity.uidUserVisite,
        statusOnSee: entity.statusOnSee);
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
        name: name,
        profilePic: profilePic,
        contactId: contactId,
        timeSent: timeSent,
        MessageNotification: MessageNotification,
        nationalite: nationalite,
        nombreVisiteurs: nombreVisiteurs,
        statusRead: statusRead,
        type: type,
        flag: flag,
        uidUserVisite: uidUserVisite,
        statusOnSee: statusOnSee);
  }
}
