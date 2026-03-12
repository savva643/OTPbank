part of 'chat_bloc.dart';

enum ChatStatus { initial, ready }

class ChatMessage extends Equatable {
  const ChatMessage({required this.sender, required this.text});

  final String sender;
  final String text;

  @override
  List<Object?> get props => [sender, text];
}

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
  });

  final ChatStatus status;
  final List<ChatMessage> messages;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [status, messages];
}
