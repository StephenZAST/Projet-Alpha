import 'package:get/get.dart';
import '../models/admin_notification.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  final notifications = <AdminNotification>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final notifs = await NotificationService.getAdminNotifications();
      notifications.value = notifs;
      _updateUnreadCount();
    } catch (e) {
      print(e);
    }
  }

  void _updateUnreadCount() {
    unreadCount.value =
        notifications.where((notification) => !notification.isRead).length;
  }
}
