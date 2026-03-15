import 'package:flutter/material.dart';
import '../../bloc/chat_list_bloc.dart';

/// Универсальный виджет элемента чата для списка
class ChatListItem extends StatelessWidget {
  final ChatConversation chat;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const ChatListItem({
    super.key,
    required this.chat,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: const BorderSide(
              width: 1,
              color: Color(0xFFF1F5F9),
            ),
            left: isHighlighted
                ? const BorderSide(
                    width: 4,
                    color: Color(0xFFC4FF2E),
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with online indicator
            _buildAvatar(),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row with tag
                  _buildNameRow(),
                  const SizedBox(height: 2),

                  // Topic/Subject
                  if (chat.tag != null || chat.isSupport) ...[
                    Text(
                      chat.isSupport ? 'Поддержка' : 'Вопрос по платежу',
                      style: TextStyle(
                        color: chat.isSupport
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],

                  // Last message
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: chat.unreadCount > 0
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w400
                          : FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),

            // Time and unread badge
            _buildRightColumn(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: chat.isSupport
                  ? const Color(0x33C4FF2E)
                  : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
              border: Border.all(
                color: chat.isSupport ? const Color(0x4CC4FF2E) : const Color(0xFFF1F5F9),
                width: 1,
              ),
              image: chat.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(chat.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: chat.avatarUrl == null
                ? Icon(
                    chat.isSupport ? Icons.support_agent_rounded : Icons.person_rounded,
                    color: chat.isSupport
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8),
                    size: 24,
                  )
                : null,
          ),
          if (chat.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFC4FF2E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC4FF2E).withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            chat.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.50,
            ),
          ),
        ),
        if (chat.tag != null) ...[
          const SizedBox(width: 8),
          _buildTagChip(chat.tag!),
        ],
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final upper = tag.toUpperCase();

    Color borderColor;
    Color backgroundColor;
    Color textColor;

    switch (upper) {
      case 'СРОЧНО':
        borderColor = const Color(0x4CFF7D32);
        backgroundColor = const Color(0x0CFF7D32);
        textColor = const Color(0xFFFF7D32);
        break;
      case 'РЕШЕНО':
        borderColor = const Color(0x4C9E6FC3);
        backgroundColor = const Color(0x0C9E6FC3);
        textColor = const Color(0xFF9E6FC3);
        break;
      default:
        borderColor = const Color(0xFFE2E8F0);
        backgroundColor = const Color(0xFFF8FAFC);
        textColor = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        upper,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.50,
          letterSpacing: 0.30,
        ),
      ),
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatTime(chat.lastMessageTime),
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.50,
          ),
        ),
        if (chat.unreadCount > 0) ...[
          const SizedBox(height: 8),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Вчера';
    } else {
      return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}';
    }
  }
}
