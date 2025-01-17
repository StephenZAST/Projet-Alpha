import 'package:flutter/material.dart';
import 'package:prima/models/notification.dart';
import 'package:prima/theme/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationListItem extends StatelessWidget {
  final Notification notification;
  final VoidCallback onTap;

  const NotificationListItem({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case 'ORDER_STATUS_UPDATED':
        return Icons.local_shipping;
      case 'PAYMENT_RECEIVED':
        return Icons.payment;
      case 'POINTS_EARNED':
        return Icons.stars;
      case 'SPECIAL_OFFER':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case 'ORDER_STATUS_UPDATED':
        return AppColors.primary;
      case 'PAYMENT_RECEIVED':
        return AppColors.success;
      case 'POINTS_EARNED':
        return AppColors.warning;
      case 'SPECIAL_OFFER':
        return AppColors.error;
      default:
        return AppColors.gray600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.primary.withOpacity(0.05),
          border: Border(bottom: BorderSide(color: AppColors.gray200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getNotificationColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(),
                color: _getNotificationColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.gray800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeago.format(notification.createdAt, locale: 'fr'),
                    style: TextStyle(
                      color: AppColors.gray400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getNotificationColor(),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
