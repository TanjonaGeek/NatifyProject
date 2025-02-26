import 'package:natify/features/Chat/domaine/entities/chat_entities.dart';
import 'package:natify/features/Chat/domaine/entities/message_entities.dart';
import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:equatable/equatable.dart';

enum ChatListConcreteState { initial, loading, loaded, failure }

class ChatState extends Equatable {
  final bool hasData;
  final String message;
  final bool isLoading;
  final bool isMe;
  final bool hasMore;
  final List<ChatEntity> listAllMessage;
  final List<MessageEntity> specificMessage;
  final List<UserEntity> listAllUserOnline;
  final List<Map<String, dynamic>> messageReply;
  final Map<dynamic, bool> messageOnDelete;
  final ChatListConcreteState state;

  const ChatState(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.isMe = true,
      this.hasMore = false,
      this.listAllMessage = const [],
      this.specificMessage = const [],
      this.listAllUserOnline = const [],
      this.messageReply = const [],
      this.messageOnDelete = const {},
      this.state = ChatListConcreteState.initial});

  const ChatState.initial(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.isMe = true,
      this.hasMore = false,
      this.listAllMessage = const [],
      this.specificMessage = const [],
      this.listAllUserOnline = const [],
      this.messageReply = const [],
      this.messageOnDelete = const {},
      this.state = ChatListConcreteState.initial});

  ChatState copyWith({
    bool? hasData,
    String? message,
    bool? isLoading,
    bool? isMe,
    bool? hasMore,
    List<ChatEntity>? listAllMessage,
    List<MessageEntity>? specificMessage,
    List<UserEntity>? listAllUserOnline,
    List<Map<String, dynamic>>? messageReply,
    Map<dynamic, bool>? messageOnDelete,
    ChatListConcreteState? state,
  }) {
    return ChatState(
        hasData: hasData ?? this.hasData,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isMe: isMe ?? this.isMe,
        hasMore: hasMore ?? this.hasMore,
        listAllMessage: listAllMessage ?? this.listAllMessage,
        specificMessage: specificMessage ?? this.specificMessage,
        listAllUserOnline: listAllUserOnline ?? this.listAllUserOnline,
        messageReply: messageReply ?? this.messageReply,
        messageOnDelete: messageOnDelete ?? this.messageOnDelete,
        state: state ?? this.state);
  }

  @override
  List<Object?> get props => [
        hasData,
        message,
        isLoading,
        isMe,
        hasMore,
        listAllMessage,
        specificMessage,
        listAllUserOnline,
        messageReply,
        messageOnDelete,
        state
      ];
}
