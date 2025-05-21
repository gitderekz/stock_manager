part of 'notifications_bloc.dart';

abstract class NotificationsEvent {}

class LoadNotifications extends NotificationsEvent {}

class MarkAsRead extends NotificationsEvent {
  final int notificationId;

  MarkAsRead(this.notificationId);
}

class MarkAllAsRead extends NotificationsEvent {}