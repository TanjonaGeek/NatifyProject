import 'package:equatable/equatable.dart';
import 'package:natify/core/utils/enums/message_enum.dart';

class MessageEntity extends Equatable {
  final String? senderId;
  final String? recieverid;
  final String? text;
  final MessageEnum? type;
  final DateTime? timeSent;
  final String? messageId;
  final bool? isSeen;
  final String? repliedMessage;
  final String? repliedTo;
  final MessageEnum? repliedMessageType;
  final List<Map<String, String>>? reactMessageSingle;
  final List<Map<String, String>>? reactMessageReply;

  const MessageEntity({
    required this.senderId,
    required this.recieverid,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
    required this.reactMessageSingle,
    required this.reactMessageReply,
  });

  @override
  List<Object?> get props {
    return [
      senderId,
      recieverid,
      text,
      type,
      timeSent,
      messageId,
      isSeen,
      repliedMessage,
      repliedTo,
      repliedMessageType,
      reactMessageSingle,
      reactMessageReply,
    ];
  }
}
