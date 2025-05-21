import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/presentation/bloc/notifications/notifications_bloc.dart';
import 'package:stock_manager/presentation/widgets/empty_state.dart';
import 'package:stock_manager/presentation/widgets/notifications/notification_item.dart';
import 'package:stock_manager/utils/constants/strings.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () => context.read<NotificationsBloc>().add(MarkAllAsRead()),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return EmptyState(
                message: Strings.noNotifications,
                icon: Icons.notifications_none,
              );
            }

            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                return NotificationItem(
                  notification: state.notifications[index],
                );
              },
            );
          } else if (state is NotificationsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}