import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../components/custom_header.dart';
import '../../controllers/notification_controller.dart';
import 'components/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  final controller = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomHeader(
            title: 'Notifications',
            actions: [
              TextButton.icon(
                icon: Icon(Icons.check_circle_outline),
                label: Text('Tout marquer comme lu'),
                onPressed: controller.markAllAsRead,
              ),
            ],
          ),
          SizedBox(height: defaultPadding),
          _buildFilterTabs(),
          SizedBox(height: defaultPadding),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              if (controller.notifications.isEmpty) {
                return _buildEmptyState();
              }

              return _buildNotificationsList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        Obx(() => FilterChip(
              label: Text('Tous'),
              selected: controller.currentFilter.value == 'all',
              onSelected: (_) => controller.setFilter('all'),
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: controller.currentFilter.value == 'all'
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            )),
        SizedBox(width: 8),
        Obx(() => FilterChip(
              label: Text('Non lus'),
              selected: controller.currentFilter.value == 'unread',
              onSelected: (_) => controller.setFilter('unread'),
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: controller.currentFilter.value == 'unread'
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            )),
      ],
    );
  }

  Widget _buildNotificationsList() {
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
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.gray400,
          ),
          SizedBox(height: defaultPadding),
          Text(
            'Aucune notification',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: defaultPadding / 2),
          ElevatedButton.icon(
            onPressed: () => controller.fetchNotifications(refresh: true),
            icon: Icon(Icons.refresh),
            label: Text('Rafraîchir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
