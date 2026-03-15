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
    final chatId = event.chatId;
    final isSupport = event.isSupport || chatId == 'support';

    emit(state.copyWith(
      status: ChatStatus.ready,
      chatId: chatId,
      chatName: event.chatName,
      isSupport: isSupport,
      messages: _mockConversation(chatId: chatId, isSupport: isSupport),
    ));
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    final next = List<ChatMessage>.from(state.messages)
      ..add(ChatMessage(
        sender: 'user',
        text: text,
        timestamp: DateTime.now(),
        isRead: true,
      ));
    emit(state.copyWith(messages: next));
  }

  List<ChatMessage> _mockConversation({required String? chatId, required bool isSupport}) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, 14, 0);

    if (isSupport) {
      return [
        ChatMessage(
          sender: 'support',
          text: 'Здравствуйте! Я ваш\nвиртуальный помощник OTP\nBank. Чем я могу вам помочь\nсегодня?',
          timestamp: base.add(const Duration(minutes: 0)),
        ),
        ChatMessage(
          sender: 'user',
          text: 'У меня возник вопрос по последнему\nплатежу в магазине.',
          timestamp: base.add(const Duration(minutes: 20)),
          isRead: true,
        ),
        ChatMessage(
          sender: 'support',
          text: 'Конечно, я помогу разобраться.\nВыберите категорию вопроса из\nсписка ниже или опишите\nпроблему подробнее.',
          timestamp: base.add(const Duration(minutes: 25)),
        ),
      ];
    }

    if (chatId == '1') {
      return [
        ChatMessage(
          sender: 'support',
          text: 'Здравствуйте! Я посмотрел ваш платеж.\nУточните, пожалуйста, дату и сумму.',
          timestamp: base.add(const Duration(minutes: 5)),
        ),
        ChatMessage(
          sender: 'user',
          text: 'Сегодня, 1490 ₽. Магазин "X".',
          timestamp: base.add(const Duration(minutes: 8)),
          isRead: true,
        ),
      ];
    }

    return [
      ChatMessage(
        sender: 'support',
        text: 'Здравствуйте! Напишите ваш вопрос — я помогу.',
        timestamp: base.add(const Duration(minutes: 3)),
      ),
    ];
  }
}
