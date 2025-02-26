
import 'package:natify/features/Chat/domaine/entities/chat_entities.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
  super.name,
  super.profilePic,
  super.contactId,
  super.timeSent,
  super.lastMessage,
  super.statusBlock,
  super.statusRead,
  super.statusTyping = null,
  super.checkStatusReadOnOther,
  super.messageLastBy,
  super.flag,
  });

  factory ChatModel.fromJson(Map < String, dynamic > map) {
    return ChatModel(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      contactId: map['contactId'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      lastMessage: map['lastMessage'] ?? '',
      statusBlock: map['statusBlock'] ?? false,
      statusRead: map['statusRead'] ?? false,
      statusTyping: map['statusTyping'] ?? false,
      checkStatusReadOnOther: map['checkStatusReadOnOther'] ?? false,
      messageLastBy: map['messageLastBy'] ?? '',
      flag: map['flag'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent!.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'statusBlock': statusBlock,
      'statusRead': statusRead,
      'statusTyping': statusTyping,
      'checkStatusReadOnOther': checkStatusReadOnOther,
      'messageLastBy': messageLastBy,
      'flag': flag,
    };
  }

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      name: entity.name,
      profilePic: entity.profilePic,
      contactId: entity.contactId,
      timeSent: entity.timeSent,
      lastMessage: entity.lastMessage,
      statusBlock: entity.statusBlock,
      statusRead: entity.statusRead,
      statusTyping: entity.statusTyping,
      checkStatusReadOnOther: entity.checkStatusReadOnOther,
      messageLastBy: entity.messageLastBy,
      flag: entity.flag,
    );
  }

  ChatEntity toEntity() {
    return ChatEntity(
      name: name,
      profilePic: profilePic,
      contactId: contactId,
      timeSent: timeSent,
      lastMessage: lastMessage,
      statusBlock: statusBlock,
      statusRead: statusRead,
      statusTyping: statusTyping,
      checkStatusReadOnOther: checkStatusReadOnOther,
      messageLastBy: messageLastBy,
      flag: flag,
    );
  }


}