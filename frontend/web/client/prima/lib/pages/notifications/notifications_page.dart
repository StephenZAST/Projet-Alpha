import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/providers/notification_provider.dart';
import 'package:prima/widgets/notification/notification_list_item.dart';
import 'package:provider/provider.dart';
import 'package:prima/widgets/connection_error_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<NotificationProvider>().loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppBarComponent(
              title: 'Notifications',
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
            ),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return ConnectionErrorWidget(
                      onRetry: () => provider.loadNotifications(),
                      customMessage: 'Impossible de charger les notifications',
                    );
                  }

                  if (provider.notifications.isEmpty) {
                    return const Center(
                      child: Text('Aucune notification'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadNotifications(),
                    child: ListView.builder(
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = provider.notifications[index];
                        return NotificationListItem(
                          notification: notification,
                          onTap: () => provider.markAsRead(notification.id),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
