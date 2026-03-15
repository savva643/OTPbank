import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final ApiClient _api;

  NotificationsBloc() : _api = ApiClient(), super(const NotificationsState()) {
    on<NotificationsRequested>(_onRequested);
    on<NotificationMarkedAsRead>(_onMarkedAsRead);
    on<AllNotificationsMarkedAsRead>(_onAllMarkedAsRead);
    on<NotificationDeleted>(_onDeleted);
  }

  Future<void> _onRequested(
    NotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    try {
      final res = await _api.dio.get('/notifications');
      final data = res.data;

      if (data is Map) {
        final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
        final unreadCount = data['unreadCount'] ?? 0;

        emit(state.copyWith(
          status: NotificationsStatus.ready,
          notifications: items,
          unreadCount: unreadCount,
        ));
      }
    } catch (_) {
      emit(state.copyWith(status: NotificationsStatus.failure));
    }
  }

  Future<void> _onMarkedAsRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _api.dio.patch('/notifications/${event.id}/read');

      final updatedNotifications = state.notifications.map((n) {
        if (n['id'] == event.id) {
          return {...n, 'isRead': true};
        }
        return n;
      }).toList();

      final newUnreadCount = updatedNotifications.where((n) => n['isRead'] != true).length;

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (_) {}
  }

  Future<void> _onAllMarkedAsRead(
    AllNotificationsMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _api.dio.patch('/notifications/read-all');

      final updatedNotifications = state.notifications.map((n) {
        return {...n, 'isRead': true};
      }).toList();

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));
    } catch (_) {}
  }

  Future<void> _onDeleted(
    NotificationDeleted event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _api.dio.delete('/notifications/${event.id}');

      final updatedNotifications = state.notifications.where((n) => n['id'] != event.id).toList();
      final newUnreadCount = updatedNotifications.where((n) => n['isRead'] != true).length;

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (_) {}
  }
}
