import 'package:stock_manager/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
}