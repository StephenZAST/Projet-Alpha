import 'package:admin/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/admin_notification.dart';
import '../services/notification_service.dart';
import '../constants.dart';
import 'dart:async';

class NotificationController extends GetxController {
  final notifications = <AdminNotification>[].obs;
  final filteredNotifications = <AdminNotification>[].obs;
  final isLoading = false.obs;
  final currentFilter = 'all'.obs;
  final currentPriority = Rxn<NotificationPriority>();
  final unreadCount = 0.obs;
  final hasMoreNotifications = true.obs;
  final _currentPage = 1.obs;
  static const int _pageSize = 20;
  Timer? _refreshTimer;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    // On n'initialise les notifications que si l'utilisateur est authentifié
    ever(Get.find<AuthController>().user, (user) {
      if (user != null) {
        fetchNotifications();
        fetchUnreadCount();
        _initializeRefreshTimer();
      } else {
        _refreshTimer?.cancel();
        notifications.clear();
        unreadCount.value = 0;
      }
    });
  }

  void _initializeRefreshTimer() {
    // Rafraîchir le compteur toutes les 30 secondes
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchUnreadCount();
    });
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      unreadCount.value = count;
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      hasMoreNotifications.value = true;
    }

    if (!hasMoreNotifications.value && !refresh) return;

    isLoading.value = true;
    try {
      final fetchedNotifications = await NotificationService.getNotifications(
        page: _currentPage.value,
        limit: _pageSize,
      );

      if (refresh) {
        notifications.clear();
      }

      if (fetchedNotifications.isEmpty) {
        hasMoreNotifications.value = false;
      } else {
        notifications.addAll(fetchedNotifications);
        _currentPage.value++;
      }

      _sortAndFilterNotifications();
      await fetchUnreadCount();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les notifications',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (!isLoading.value && hasMoreNotifications.value) {
      await fetchNotifications();
    }
  }

  Future<void> markAsRead(AdminNotification notification) async {
    if (notification.isRead) return;

    try {
      await NotificationService.markAsRead(notification.id);
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification.copyWith(isRead: true);
      }
      await fetchUnreadCount();
      _sortAndFilterNotifications();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de marquer la notification comme lue',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      notifications.assignAll(
          notifications.map((n) => n.copyWith(isRead: true)).toList());
      await fetchUnreadCount();
      _sortAndFilterNotifications();
      Get.snackbar(
        'Succès',
        'Toutes les notifications ont été marquées comme lues',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de marquer toutes les notifications comme lues',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    }
  }

  void _sortAndFilterNotifications() {
    List<AdminNotification> filtered = List.from(notifications);

    // Appliquer le filtre de type
    if (currentFilter.value != 'all') {
      filtered = filtered.where((n) {
        switch (currentFilter.value) {
          case 'unread':
            return !n.isRead;
          case 'orders':
            return n.type == NotificationType.ORDER;
          case 'delivery':
            return n.type == NotificationType.DELIVERY;
          case 'users':
            return n.type == NotificationType.USER;
          case 'payments':
            return n.type == NotificationType.PAYMENT;
          case 'system':
            return n.type == NotificationType.SYSTEM;
          case 'affiliate':
            return n.type == NotificationType.AFFILIATE;
          default:
            return true;
        }
      }).toList();
    }

    // Appliquer le filtre de priorité
    if (currentPriority.value != null) {
      filtered =
          filtered.where((n) => n.priority == currentPriority.value).toList();
    }

    // Trier par priorité puis par date
    filtered.sort((a, b) {
      // D'abord par priorité (URGENT en premier)
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;

      // Ensuite par date (plus récent en premier)
      return b.createdAt.compareTo(a.createdAt);
    });

    filteredNotifications.value = filtered;
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
    _sortAndFilterNotifications();
  }

  void setPriority(NotificationPriority? priority) {
    currentPriority.value = priority;
    _sortAndFilterNotifications();
  }

  Future<void> deleteNotification(AdminNotification notification) async {
    try {
      await NotificationService.deleteNotification(notification.id);
      notifications.remove(notification);
      _sortAndFilterNotifications();
      if (!notification.isRead) {
        await fetchUnreadCount();
      }
      Get.snackbar(
        'Succès',
        'Notification supprimée',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer la notification',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    }
  }

  void handleNotificationAction(AdminNotification notification) {
    if (!notification.isRead) {
      markAsRead(notification);
    }

    switch (notification.type) {
      case NotificationType.ORDER:
        Get.toNamed('/orders/${notification.referenceId}');
        break;
      case NotificationType.USER:
        Get.toNamed('/users/${notification.referenceId}');
        break;
      case NotificationType.PAYMENT:
        Get.toNamed('/payments/${notification.referenceId}');
        break;
      case NotificationType.DELIVERY:
        Get.toNamed('/delivery/${notification.referenceId}');
        break;
      case NotificationType.AFFILIATE:
        Get.toNamed('/affiliates/${notification.referenceId}');
        break;
      case NotificationType.SYSTEM:
        // Les notifications système peuvent avoir différentes actions
        _handleSystemNotification(notification);
        break;
    }
  }

  void _handleSystemNotification(AdminNotification notification) {
    // À implémenter selon les besoins spécifiques
    print('System notification: ${notification.message}');
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    _subscription?.cancel();
    super.onClose();
  }
}
