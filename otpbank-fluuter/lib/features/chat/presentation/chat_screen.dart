import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/chat_bloc.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? chatName;
  final bool isSupport;

  const ChatScreen({
    super.key,
    this.chatId,
    this.chatName,
    this.isSupport = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatStarted(
          chatId: widget.chatId,
          chatName: widget.chatName,
          isSupport: widget.isSupport,
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(ChatMessageSent(text));
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuickAction(String text) {
    context.read<ChatBloc>().add(ChatMessageSent(text));
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final previousMessage = index > 0 ? state.messages[index - 1] : null;
                    final showDateHeader = _shouldShowDateHeader(message, previousMessage);

                    return Column(
                      children: [
                        if (showDateHeader)
                          _buildDateHeader(message.timestamp!),
                        _buildMessageBubble(message),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildQuickActions(),
          _buildInputField(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final title = (widget.chatName ?? (widget.isSupport ? 'Чат с поддержкой' : 'Чат')).trim();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x33C4FF2E),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x4CC4FF2E), width: 1),
            ),
            child: Icon(
              widget.isSupport ? Icons.support_agent_rounded : Icons.chat_bubble_rounded,
              color: const Color(0xFF0F172A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4FF2E),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Операторы онлайн',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0F172A)),
          onPressed: () {
            // TODO: Show chat options menu
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFF1F5F9)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Начните диалог',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Опишите ваш вопрос и мы поможем',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDateHeader(ChatMessage current, ChatMessage? previous) {
    if (previous?.timestamp == null || current.timestamp == null) return true;
    final currentDate = DateTime(current.timestamp!.year, current.timestamp!.month, current.timestamp!.day);
    final previousDate = DateTime(previous!.timestamp!.year, previous.timestamp!.month, previous.timestamp!.day);
    return currentDate != previousDate;
  }

  Widget _buildDateHeader(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Сегодня';
    } else if (messageDate == yesterday) {
      dateText = 'Вчера';
    } else {
      dateText = DateFormat('d MMMM', 'ru_RU').format(timestamp);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            dateText.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == 'user';
    final timeText = message.timestamp != null ? DateFormat('HH:mm').format(message.timestamp!) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0x33C4FF2E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x4CC4FF2E), width: 1),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Color(0xFF0F172A),
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isUser ? 0 : 4,
                    right: isUser ? 4 : 0,
                    bottom: 4,
                  ),
                  child: Text(
                    isUser ? 'Вы' : 'Поддержка OTP',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFFC4FF2E) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: isUser
                        ? const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ),
                if (isUser && timeText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$timeText • ${message.isRead ? 'Прочитано' : 'Отправлено'}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      'Проблема с картой',
      'Вопрос по платежу',
      'Оформить кредит',
      'Связаться с оператором',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 1, color: Color(0xFFF1F5F9)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions.map((action) {
            final isPrimary = action == 'Вопрос по платежу';
            final isOrange = action == 'Оформить кредит';

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => _sendQuickAction(action),
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? const Color(0x0C9E6FC3)
                        : (isOrange ? const Color(0x0CFF7D32) : Colors.transparent),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: isPrimary
                          ? const Color(0x4C9E6FC3)
                          : (isOrange ? const Color(0x4CFF7D32) : const Color(0xFFE2E8F0)),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    action,
                    style: TextStyle(
                      color: isPrimary
                          ? const Color(0xFF9E6FC3)
                          : (isOrange ? const Color(0xFFFF7D32) : const Color(0xFF0F172A)),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFF1F5F9)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Сообщение...',
                    hintStyle: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 12, right: 12, top: 9, bottom: 10),
                    prefixIcon: Icon(Icons.add_rounded, color: Color(0xFF64748B), size: 20),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFFC4FF2E),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _send,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.send_rounded,
                    color: Color(0xFF0F172A),
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
