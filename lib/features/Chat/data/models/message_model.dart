import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/features/Chat/domaine/entities/message_entities.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    super.senderId,
    super.recieverid,
    super.text,
    super.type,
    super.timeSent,
    super.messageId,
    super.isSeen,
    super.repliedMessage,
    super.repliedTo,
    super.repliedMessageType,
    super.reactMessageSingle,
    super.reactMessageReply,
  });

  factory MessageModel.fromJson(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      recieverid: map['recieverid'] ?? '',
      text: map['text'] ?? '',
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
      isSeen: map['isSeen'] ?? false,
      repliedMessage: map['repliedMessage'] ?? '',
      repliedTo: map['repliedTo'] ?? '',
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
      reactMessageSingle:
          List<Map<String, String>>.from(map['reactMessageSingle']),
      reactMessageReply:
          List<Map<String, String>>.from(map['reactMessageReply']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recieverid': recieverid,
      'text': text,
      'type': type!.type,
      'timeSent': timeSent!.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType!.type,
      'reactMessageSingle': reactMessageSingle,
      'reactMessageReply': reactMessageReply,
    };
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      senderId: entity.senderId,
      recieverid: entity.recieverid,
      text: entity.text,
      type: entity.type,
      timeSent: entity.timeSent,
      messageId: entity.messageId,
      isSeen: entity.isSeen,
      repliedMessage: entity.repliedMessage,
      repliedTo: entity.repliedTo,
      repliedMessageType: entity.repliedMessageType,
      reactMessageSingle: entity.reactMessageSingle,
      reactMessageReply: entity.reactMessageReply,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      senderId: senderId,
      recieverid: recieverid,
      text: text,
      type: type,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: isSeen,
      repliedMessage: repliedMessage,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
      reactMessageSingle: reactMessageSingle,
      reactMessageReply: reactMessageReply,
    );
  }
}
