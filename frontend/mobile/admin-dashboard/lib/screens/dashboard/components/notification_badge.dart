import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart';
import '../../controllers/notification_controller.dart';
import '../notifications/notifications_screen.dart';

class NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Badge(
      position: BadgePosition.topEnd(top: -5, end: -5),
      child: IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () => Get.to(() => NotificationsScreen()),
      ),
      badgeContent: Obx(() => Text(
            '${controller.unreadCount}',
            style: TextStyle(color: Colors.white, fontSize: 12),
          )),
      showBadge: controller.unreadCount > 0,
    );
  }
}
