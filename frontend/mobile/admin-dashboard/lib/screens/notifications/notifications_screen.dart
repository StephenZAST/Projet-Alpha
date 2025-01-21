import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/notification_controller.dart';
import 'components/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.check_circle_outline),
            label: Text('Mark all as read'),
            onPressed: controller.markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(controller),
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : controller.notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(NotificationController controller) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      child: Row(
        children: [
          FilterChip(
            label: Text('All'),
            selected: controller.currentFilter.value == 'all',
            onSelected: (_) => controller.setFilter('all'),
          ),
          SizedBox(width: 8),
          FilterChip(
            label: Text('Unread'),
            selected: controller.currentFilter.value == 'unread',
            onSelected: (_) => controller.setFilter('unread'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationController controller) {
    return RefreshIndicator(
      onRefresh: controller.fetchNotifications,
      child: ListView.builder(
        itemCount: controller.filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = controller.filteredNotifications[index];
          return NotificationTile(notification: notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppColors.gray400),
          SizedBox(height: defaultPadding),
          Text('No notifications yet'),
        ],
      ),
    );
  }
}
