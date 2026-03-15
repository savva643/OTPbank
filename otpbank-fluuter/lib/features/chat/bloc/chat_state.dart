part of 'chat_bloc.dart';

enum ChatStatus { initial, ready }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.sender,
    required this.text,
    this.timestamp,
    this.isRead = false,
  });

  final String sender;
  final String text;
  final DateTime? timestamp;
  final bool isRead;

  @override
  List<Object?> get props => [sender, text, timestamp, isRead];
}

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.chatId,
    this.chatName,
    this.isSupport = false,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? chatId;
  final String? chatName;
  final bool isSupport;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? chatId,
    String? chatName,
    bool? isSupport,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
      chatName: chatName ?? this.chatName,
      isSupport: isSupport ?? this.isSupport,
    );
  }

  @override
  List<Object?> get props => [status, messages, chatId, chatName, isSupport];
}
