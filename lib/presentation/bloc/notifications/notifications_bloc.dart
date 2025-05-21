import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/domain/entities/notification.dart';
import 'package:stock_manager/domain/repositories/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository notificationRepository;

  NotificationsBloc(this.notificationRepository) : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onLoadNotifications(
      LoadNotifications event,
      Emitter<NotificationsState> emit,
      ) async {
    emit(NotificationsLoading());
    try {
      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationsError('Failed to load notifications'));
    }
  }

  Future<void> _onMarkAsRead(
      MarkAsRead event,
      Emitter<NotificationsState> emit,
      ) async {
    try {
      await notificationRepository.markAsRead(event.notificationId);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationsError('Failed to mark as read'));
    }
  }

  Future<void> _onMarkAllAsRead(
      MarkAllAsRead event,
      Emitter<NotificationsState> emit,
      ) async {
    try {
      await notificationRepository.markAllAsRead();
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationsError('Failed to mark all as read'));
    }
  }
}