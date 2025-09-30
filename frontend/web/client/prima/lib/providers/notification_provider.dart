import 'package:flutter/material.dart';
import '../models/notification.dart' as notification_model;
import '../services/notification_service.dart';
import '../services/websocket_service.dart';

class NotificationPreferences {
  final bool push;
  final bool email;
  final bool orderUpdates;
  final bool loyalty;
  final bool promotions;

  const NotificationPreferences({
    this.push = true,
    this.email = true,
    this.orderUpdates = true,
    this.loyalty = true,
    this.promotions = true,
  });

  NotificationPreferences copyWith({
    bool? push,
    bool? email,
    bool? orderUpdates,
    bool? loyalty,
    bool? promotions,
  }) {
    return NotificationPreferences(
      push: push ?? this.push,
      email: email ?? this.email,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      loyalty: loyalty ?? this.loyalty,
      promotions: promotions ?? this.promotions,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;
  final WebSocketService _webSocketService;

  List<notification_model.Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  NotificationPreferences _preferences = const NotificationPreferences();
  NotificationPreferences get preferences => _preferences;

  NotificationProvider(this._notificationService, this._webSocketService) {
    _initWebSocket();
  }

  List<notification_model.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  void _initWebSocket() {
    _webSocketService.orderUpdates.listen(_handleNewNotification);
  }

  void _handleNewNotification(dynamic data) {
    if (data['type'] == 'notification') {
      final notification =
          notification_model.Notification.fromJson(data['data']);
      _notifications.insert(0, notification);
      if (!notification.isRead) _unreadCount++;
      notifyListeners();
    }
  }

  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _notifications = await _notificationService.getNotifications();
      _updateUnreadCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        if (!notification.isRead) _unreadCount--;

        _notifications[index] = notification_model.Notification(
          id: notification.id,
          userId: notification.userId,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          isRead: true,
          createdAt: notification.createdAt,
          data: notification.data,
        );

        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      _notifications = _notifications
          .map((notification) => notification_model.Notification(
                id: notification.id,
                userId: notification.userId,
                type: notification.type,
                title: notification.title,
                message: notification.message,
                isRead: true,
                createdAt: notification.createdAt,
                data: notification.data,
              ))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> loadPreferences() async {
    // TODO: Implement when backend supports preferences
    /*
    try {
      final prefs = await _notificationService.getPreferences();
      _preferences = NotificationPreferences(
        push: prefs['push'] ?? true,
        email: prefs['email'] ?? true,
        orderUpdates: prefs['orderUpdates'] ?? true,
        loyalty: prefs['loyalty'] ?? true,
        promotions: prefs['promotions'] ?? true,
      );
      notifyListeners();
    } catch (e) {
      print('Error loading preferences: $e');
    }
    */
  }

  Future<void> updatePreference(String key, bool value) async {
    // TODO: Implement when backend supports preferences
    /*
    try {
      final newPrefs = _preferences.copyWith(
        push: key == 'push' ? value : null,
        email: key == 'email' ? value : null,
        orderUpdates: key == 'orderUpdates' ? value : null,
        loyalty: key == 'loyalty' ? value : null,
        promotions: key == 'promotions' ? value : null,
      );

      await _notificationService.updatePreferences(newPrefs);
      _preferences = newPrefs;
      notifyListeners();
    } catch (e) {
      print('Error updating preferences: $e');
    }
    */
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void handleNewNotification(notification_model.Notification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) _unreadCount++;
    notifyListeners();
  }

  @override
  void dispose() {
    // _webSocketService.off('notification'); // Not implemented in WebSocketService
    super.dispose();
  }
}
