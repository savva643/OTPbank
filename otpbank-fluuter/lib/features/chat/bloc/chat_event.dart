part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatStarted extends ChatEvent {
  const ChatStarted({this.chatId, this.chatName, this.isSupport = false});

  final String? chatId;
  final String? chatName;
  final bool isSupport;

  @override
  List<Object?> get props => [chatId, chatName, isSupport];
}

final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}
