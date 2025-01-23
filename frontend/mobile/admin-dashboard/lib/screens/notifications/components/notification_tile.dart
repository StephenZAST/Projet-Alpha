import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get/get.dart';
import '../../../models/admin_notification.dart';
import '../../../controllers/notification_controller.dart';
import '../../../constants.dart';

class NotificationTile extends StatelessWidget {
  final AdminNotification notification;

  const NotificationTile({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.all(AppSpacing.md),
        title: Row(
          children: [
            Text(
              notification.title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: notification.priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                notification.typeLabel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: notification.priorityColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.sm),
            Text(
              notification.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              timeago.format(notification.createdAt, locale: 'fr'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        leading: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: notification.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.icon,
            color: notification.color,
            size: 24,
          ),
        ),
        trailing: !notification.isRead
            ? IconButton(
                icon: Icon(Icons.check_circle_outline),
                color: AppColors.success,
                onPressed: () => controller.markAsRead(notification),
                tooltip: 'Marquer comme lu',
              )
            : null,
        onTap: () {
          controller.handleNotificationAction(notification);
        },
      ),
    );
  }
}
