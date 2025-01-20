import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/admin_notification.dart';

class NotificationTile extends StatelessWidget {
  final AdminNotification notification;

  const NotificationTile({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(notification.title),
      subtitle: Text(notification.message),
      trailing: Text(
        timeago.format(notification.createdAt),
        style: TextStyle(color: Colors.grey),
      ),
      leading: Icon(_getIcon(notification.type)),
      tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.1),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'ORDER':
        return Icons.shopping_cart;
      case 'USER':
        return Icons.person;
      case 'SYSTEM':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
