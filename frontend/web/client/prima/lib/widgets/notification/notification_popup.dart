import 'package:flutter/material.dart';
import 'package:prima/models/notification.dart' as model;
import 'package:prima/theme/colors.dart';

class NotificationPopup extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationPopup({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => onDismiss(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      _getNotificationIcon(),
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(notification.message),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}
