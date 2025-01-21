import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/admin_notification.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  final notifications = <AdminNotification>[].obs;
  final filteredNotifications = <AdminNotification>[].obs;
  final isLoading = false.obs;
  final currentFilter = 'all'.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    // TODO: Implement WebSocket connection for real-time notifications
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final fetchedNotifications =
          await NotificationService.getAdminNotifications();
      notifications.value = fetchedNotifications;
      applyFilter();
      updateUnreadCount();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch notifications: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(AdminNotification notification) async {
    try {
      await NotificationService.markAsRead(notification.id);
      notification.isRead = true;
      updateUnreadCount();
      applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      notifications.forEach((notification) => notification.isRead = true);
      updateUnreadCount();
      applyFilter();
      Get.snackbar('Success', 'All notifications marked as read');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark all notifications as read');
    }
  }

  void applyFilter() {
    switch (currentFilter.value) {
      case 'unread':
        filteredNotifications.value =
            notifications.where((n) => !n.isRead).toList();
        break;
      case 'orders':
        filteredNotifications.value = notifications
            .where((n) => n.type == NotificationType.ORDER)
            .toList();
        break;
      case 'system':
        filteredNotifications.value = notifications
            .where((n) => n.type == NotificationType.SYSTEM)
            .toList();
        break;
      default:
        filteredNotifications.value = notifications;
    }
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
    applyFilter();
  }

  void handleNotificationAction(AdminNotification notification) {
    switch (notification.type) {
      case NotificationType.ORDER:
        Get.toNamed('/orders/${notification.referenceId}');
        break;
      case NotificationType.USER:
        Get.toNamed('/users/${notification.referenceId}');
        break;
      default:
        // Handle other notification types
        break;
    }
    markAsRead(notification);
  }

  void updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  @override
  void onClose() {
    // Close WebSocket connection
    super.onClose();
  }
}
