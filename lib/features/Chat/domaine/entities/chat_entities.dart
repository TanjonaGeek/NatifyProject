import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String? name;
  final String? profilePic;
  final String? contactId;
  final DateTime? timeSent;
  final String? lastMessage;
  final bool? statusBlock;
  final bool? statusRead;
  final bool? statusTyping;
  final bool? checkStatusReadOnOther;
  final String? messageLastBy;
  final String? flag;

  const ChatEntity({
    required this.name,
    required this.profilePic,
    required this.contactId,
    required this.timeSent,
    required this.lastMessage,
    required this.statusBlock,
    required this.statusRead,
    this.statusTyping = false,
    required this.checkStatusReadOnOther,
    required this.messageLastBy,
    required this.flag,
  });

  @override
  List<Object?> get props {
    return [
      name,
      profilePic,
      contactId,
      timeSent,
      lastMessage,
      statusBlock,
      statusRead,
      statusTyping,
      checkStatusReadOnOther,
      messageLastBy,
      flag,
    ];
  }
}
