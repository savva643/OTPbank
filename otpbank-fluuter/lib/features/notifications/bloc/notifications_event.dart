part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationsRequested extends NotificationsEvent {
  const NotificationsRequested();
}

final class NotificationMarkedAsRead extends NotificationsEvent {
  final String id;
  const NotificationMarkedAsRead(this.id);

  @override
  List<Object?> get props => [id];
}

final class AllNotificationsMarkedAsRead extends NotificationsEvent {
  const AllNotificationsMarkedAsRead();
}

final class NotificationDeleted extends NotificationsEvent {
  final String id;
  const NotificationDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
