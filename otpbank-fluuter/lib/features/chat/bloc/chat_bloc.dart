import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatMessageSent>(_onMessageSent);
  }

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.ready));
    if (state.messages.isEmpty) {
      emit(state.copyWith(messages: [
        ChatMessage(
          sender: 'support',
          text: 'Здравствуйте! Чем можем помочь?',
          timestamp: DateTime.now(),
        )
      ]));
    }
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    final next = List<ChatMessage>.from(state.messages)
      ..add(ChatMessage(
        sender: 'user',
        text: text,
        timestamp: DateTime.now(),
      ));
    emit(state.copyWith(messages: next));
  }
}
