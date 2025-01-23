import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import '../../../constants.dart';
import '../../../controllers/notification_controller.dart';
import '../../../routes/admin_routes.dart';

class NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Material(
      type: MaterialType.transparency,
      child: badges.Badge(
        position: badges.BadgePosition.topEnd(top: -5, end: -5),
        badgeStyle: badges.BadgeStyle(
          badgeColor: AppColors.error,
          padding: EdgeInsets.all(6),
        ),
        child: IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () => AdminRoutes.goToNotifications(),
          tooltip: 'Notifications',
        ),
        badgeContent: Obx(() => Text(
              '${controller.unreadCount}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            )),
        showBadge: controller.unreadCount > 0,
      ),
    );
  }
}
