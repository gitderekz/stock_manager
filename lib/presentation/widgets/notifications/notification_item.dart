import 'package:flutter/material.dart';
import 'package:stock_manager/domain/entities/notification.dart';

class NotificationItem extends StatelessWidget {
  final AppNotification notification;

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getNotificationIcon(),
        color: _getNotificationColor(context),
      ),
      title: Text(notification.title),
      subtitle: Text(notification.message),
      trailing: Text(
        _formatDate(notification.createdAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        // Handle notification tap
      },
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.notificationType) {
      case 'stock_alert':
        return Icons.warning;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(BuildContext context) {
    switch (notification.notificationType) {
      case 'stock_alert':
        return Theme.of(context).colorScheme.error;
      case 'system':
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}