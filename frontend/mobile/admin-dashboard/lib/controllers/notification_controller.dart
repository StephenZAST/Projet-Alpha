import 'package:admin/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../models/admin_notification.dart';
import '../services/notification_service.dart';
import '../routes/admin_routes.dart';
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
    print('[NotificationController] Initializing');
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

  void handleNotificationAction(AdminNotification notification) {
    if (!notification.isRead) {
      markAsRead(notification);
    }

    // Navigation basée sur le type de notification
    switch (notification.type) {
      // LOYALTY
      case NotificationType.REWARD_CLAIM_APPROVED:
      case NotificationType.REWARD_CLAIM_REJECTED:
        AdminRoutes.navigateByIndex(8); // Index Loyalty
        break;
      // ORDERS
      case NotificationType.ORDER_PLACED:
      case NotificationType.ORDER_STATUS_CHANGED:
      case NotificationType.ORDER_READY_PICKUP:
      case NotificationType.ORDER_CANCELLED:
      case NotificationType.ORDER:
      case NotificationType.NEW_ORDER_ALERT:
        AdminRoutes.navigateByIndex(1); // Index Orders
        break;
      case NotificationType.PAYMENT_FAILED:
      case NotificationType.PAYMENT:
      case NotificationType.PAYMENT_SYSTEM_ISSUE:
        AdminRoutes.navigateByIndex(1); // Index Orders (pour voir les paiements)
        break;
      // DELIVERY
      case NotificationType.DELIVERY_ASSIGNED:
      case NotificationType.DELIVERY_COMPLETED:
      case NotificationType.DELIVERY_PROBLEM:
      case NotificationType.DELIVERY:
        AdminRoutes.navigateByIndex(9); // Index Delivery
        break;
      // AFFILIATION
      case NotificationType.REFERRAL_CODE_USED:
      case NotificationType.COMMISSION_EARNED:
      case NotificationType.WITHDRAWAL_APPROVED:
      case NotificationType.WITHDRAWAL_REJECTED:
      case NotificationType.AFFILIATE:
        AdminRoutes.navigateByIndex(7); // Index Affiliates
        break;
      // SUBSCRIPTION
      case NotificationType.SUBSCRIPTION_ACTIVATED:
      case NotificationType.SUBSCRIPTION_CANCELLED:
        AdminRoutes.navigateByIndex(13); // Index Subscriptions
        break;
      // ADMIN
      case NotificationType.NEW_USER_REGISTERED:
      case NotificationType.USER:
        AdminRoutes.navigateByIndex(6); // Index Users
        break;
      // Legacy
      case NotificationType.SYSTEM:
        _handleSystemNotification(notification);
        break;
    }
  }

  void _handleSystemNotification(AdminNotification notification) {
    print('[NotificationController] System notification: ${notification.message}');
    // Afficher un dialog ou une page de détails si nécessaire
  }

  void _initializeRefreshTimer() {
    // Rafraîchir les notifications toutes les 30 secondes
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      print('[NotificationController] Auto-refresh triggered');
      fetchNotifications(refresh: false);
      fetchUnreadCount();
    });
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      unreadCount.value = count;
    } catch (e) {
      print('[NotificationController] Error fetching unread count: $e');
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    print('[NotificationController] Fetching notifications, refresh: $refresh');
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
      print(
          '[NotificationController] Fetched ${notifications.length} notifications');
    } catch (e) {
      print('[NotificationController] Error fetching notifications: $e');
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
      print('[NotificationController] Error marking notification as read: $e');
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
      print('[NotificationController] Error marking all as read: $e');
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
    print('[NotificationController] Setting filter to: $filter');
    currentFilter.value = filter;
    _sortAndFilterNotifications();
  }

  void setPriority(NotificationPriority? priority) {
    currentPriority.value = priority;
    _sortAndFilterNotifications();
  }

  @override
  void onClose() {
    print('[NotificationController] Closing');
    _refreshTimer?.cancel();
    _subscription?.cancel();
    super.onClose();
  }
}
