part of 'notifications_bloc.dart';

enum NotificationsStatus { initial, loading, ready, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  final NotificationsStatus status;
  final List<Map<String, dynamic>> notifications;
  final int unreadCount;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<Map<String, dynamic>>? notifications,
    int? unreadCount,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [status, notifications, unreadCount];
}
