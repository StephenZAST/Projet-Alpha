import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get/get.dart';
import '../../../models/admin_notification.dart';
import '../../../controllers/notification_controller.dart';

class NotificationTile extends StatelessWidget {
  final AdminNotification notification;

  const NotificationTile({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return ListTile(
      title: Text(notification.title),
      subtitle: Text(notification.message),
      trailing: Text(
        timeago.format(notification.createdAt),
        style: TextStyle(color: Colors.grey),
      ),
      leading: Icon(notification.icon, color: notification.color),
      tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.1),
      onTap: () {
        controller.handleNotificationAction(notification);
      },
    );
  }
}
