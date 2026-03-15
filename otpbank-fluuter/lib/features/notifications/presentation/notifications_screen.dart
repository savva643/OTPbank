import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiClient();
  bool _loading = true;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final res = await _api.dio.get('/notifications');
      final data = res.data;
      if (data is Map) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(data['items'] ?? []);
          _unreadCount = data['unreadCount'] ?? 0;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _api.dio.patch('/notifications/$id/read');
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
          _unreadCount = _notifications.where((n) => n['isRead'] != true).length;
        }
      });
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await _api.dio.patch('/notifications/read-all');
      setState(() {
        for (var n in _notifications) {
          n['isRead'] = true;
        }
        _unreadCount = 0;
      });
    } catch (_) {}
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _api.dio.delete('/notifications/$id');
      setState(() {
        _notifications.removeWhere((n) => n['id'] == id);
        _unreadCount = _notifications.where((n) => n['isRead'] != true).length;
      });
    } catch (_) {}
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Только что';
      if (diff.inHours < 1) return '${diff.inMinutes} мин назад';
      if (diff.inDays < 1) return '${diff.inHours} ч назад';
      if (diff.inDays == 1) return 'Вчера';
      if (diff.inDays < 7) {
        final formatter = DateFormat('EEEE', 'ru');
        final dayName = formatter.format(date);
        return dayName.substring(0, 1).toUpperCase() + dayName.substring(1);
      }
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {
      return '';
    }
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'transfer':
        return Icons.swap_horiz;
      case 'bonus':
        return Icons.stars;
      case 'security':
        return Icons.security;
      case 'promo':
        return Icons.local_offer;
      case 'account':
        return Icons.account_balance;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'payment':
        return const Color(0xFF3B82F6);
      case 'transfer':
        return const Color(0xFF8B5CF6);
      case 'bonus':
        return const Color(0xFFF59E0B);
      case 'security':
        return const Color(0xFFEF4444);
      case 'promo':
        return const Color(0xFF10B981);
      case 'account':
        return const Color(0xFF0F172A);
      case 'card':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          OtpUniversalAppBar(
            title: 'Уведомления',
            onBack: () => Navigator.of(context).pop(),
          ),
          if (_unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1FF05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_unreadCount новых',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text(
                      'Прочитать все',
                      style: TextStyle(
                        color: Color(0xFF9E6FC3),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final isRead = notification['isRead'] == true;
                  final type = notification['type']?.toString();

                  return Dismissible(
                    key: Key(notification['id']?.toString() ?? index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.only(right: 16),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _deleteNotification(notification['id']?.toString() ?? ''),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isRead
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFFC1FF05).withOpacity(0.5),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getColorForType(type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIconForType(type),
                            color: _getColorForType(type),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['title']?.toString() ?? '',
                                style: TextStyle(
                                  color: const Color(0xFF0F172A),
                                  fontSize: 15,
                                  fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC1FF05),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notification['message']?.toString() ?? '',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatDate(notification['createdAt']?.toString()),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (!isRead) {
                            _markAsRead(notification['id']?.toString() ?? '');
                          }
                          _handleNotificationAction(notification);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Уведомлений пока нет',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь будут появляться важные события',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    final action = notification['action'];
    if (action == null) return;

    final type = action['type']?.toString();
    final data = action['data'];

    switch (type) {
      case 'receipt':
      case 'transaction':
      // Navigate to transaction details
        break;
      case 'bonuses':
      // Navigate to bonuses screen
        break;
      case 'promo':
      // Navigate to store promo
        break;
      case 'security':
      // Show security dialog
        break;
      case 'account':
      // Navigate to account
        break;
    }
  }
}