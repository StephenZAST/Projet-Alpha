import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constants.dart';

/// 🔔 Service de Notifications - Alpha Delivery App
///
/// Gère les notifications locales pour les livreurs :
/// nouvelles commandes, changements de statut, rappels, etc.
class NotificationService extends GetxService {
  // ==========================================================================
  // 📦 PROPRIÉTÉS
  // ==========================================================================

  late final FlutterLocalNotificationsPlugin _notifications;

  // États observables
  final _isInitialized = false.obs;
  final _permissionGranted = false.obs;

  // ==========================================================================
  // 🎯 GETTERS
  // ==========================================================================

  bool get isInitialized => _isInitialized.value;
  bool get permissionGranted => _permissionGranted.value;

  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('🔔 Initialisation NotificationService...');

    await _initializeNotifications();
    await _requestPermissions();

    debugPrint('✅ NotificationService initialisé');
  }

  /// Initialise le plugin de notifications
  Future<void> _initializeNotifications() async {
    try {
      _notifications = FlutterLocalNotificationsPlugin();

      // Configuration Android
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuration iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Configuration générale
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialise avec callback pour les interactions
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Crée le canal de notification Android
      await _createNotificationChannel();

      _isInitialized.value = true;
      debugPrint('✅ Plugin de notifications initialisé');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation des notifications: $e');
    }
  }

  /// Crée le canal de notification Android
  Future<void> _createNotificationChannel() async {
    try {
      const channel = AndroidNotificationChannel(
        NotificationConfig.channelId,
        NotificationConfig.channelName,
        description: NotificationConfig.channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      debugPrint('✅ Canal de notification créé');
    } catch (e) {
      debugPrint('❌ Erreur lors de la création du canal: $e');
    }
  }

  /// Demande les permissions de notification
  Future<void> _requestPermissions() async {
    try {
      // Permission Android 13+
      final status = await Permission.notification.request();
      _permissionGranted.value = status.isGranted;

      // Permission iOS
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      debugPrint('🔔 Permissions de notification: ${_permissionGranted.value}');
    } catch (e) {
      debugPrint('❌ Erreur lors de la demande de permissions: $e');
    }
  }

  // ==========================================================================
  // 🔔 NOTIFICATIONS DE COMMANDES
  // ==========================================================================

  /// Notification pour une nouvelle commande assignée
  Future<void> showNewOrderNotification({
    required String orderId,
    required String customerName,
    required String address,
  }) async {
    if (!_canShowNotification()) return;

    try {
      await _notifications.show(
        orderId.hashCode,
        '📦 Nouvelle commande assignée',
        'Client: $customerName\nAdresse: $address',
        _getNotificationDetails(
          type: NotificationType.newOrder,
          payload: orderId,
        ),
      );

      debugPrint('🔔 Notification nouvelle commande envoyée: $orderId');
    } catch (e) {
      debugPrint('❌ Erreur notification nouvelle commande: $e');
    }
  }

  /// Notification pour un changement de statut
  Future<void> showStatusChangeNotification({
    required String orderId,
    required String newStatus,
    required String customerName,
  }) async {
    if (!_canShowNotification()) return;

    try {
      final statusText = _getStatusDisplayText(newStatus);

      await _notifications.show(
        '${orderId}_status'.hashCode,
        '🔄 Statut mis à jour',
        'Commande $orderId: $statusText\nClient: $customerName',
        _getNotificationDetails(
          type: NotificationType.statusChange,
          payload: orderId,
        ),
      );

      debugPrint(
          '🔔 Notification changement statut envoyée: $orderId -> $newStatus');
    } catch (e) {
      debugPrint('❌ Erreur notification changement statut: $e');
    }
  }

  /// Notification de rappel pour une collecte
  Future<void> showCollectionReminderNotification({
    required String orderId,
    required String customerName,
    required String address,
    required DateTime scheduledTime,
  }) async {
    if (!_canShowNotification()) return;

    try {
      final timeText = _formatTime(scheduledTime);

      await _notifications.show(
        '${orderId}_reminder'.hashCode,
        '⏰ Rappel de collecte',
        'Collecte prévue à $timeText\nClient: $customerName\nAdresse: $address',
        _getNotificationDetails(
          type: NotificationType.reminder,
          payload: orderId,
        ),
      );

      debugPrint('🔔 Notification rappel collecte envoyée: $orderId');
    } catch (e) {
      debugPrint('❌ Erreur notification rappel: $e');
    }
  }

  /// Notification de livraison urgente
  Future<void> showUrgentDeliveryNotification({
    required String orderId,
    required String customerName,
    required String reason,
  }) async {
    if (!_canShowNotification()) return;

    try {
      await _notifications.show(
        '${orderId}_urgent'.hashCode,
        '🚨 Livraison urgente',
        'Commande $orderId - $reason\nClient: $customerName',
        _getNotificationDetails(
          type: NotificationType.urgent,
          payload: orderId,
          priority: NotificationPriority.max,
        ),
      );

      debugPrint('🔔 Notification livraison urgente envoyée: $orderId');
    } catch (e) {
      debugPrint('❌ Erreur notification urgente: $e');
    }
  }

  // ==========================================================================
  // 📅 NOTIFICATIONS PROGRAMMÉES
  // ==========================================================================

  /// Programme une notification pour plus tard
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_canShowNotification()) return;

    try {
      // Convertit DateTime en TZDateTime pour la programmation
      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDate,
        _getNotificationDetails(payload: payload),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('📅 Notification programmée: $title à $scheduledDate');
    } catch (e) {
      debugPrint('❌ Erreur programmation notification: $e');
    }
  }

  /// Annule une notification programmée
  Future<void> cancelScheduledNotification(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('❌ Notification annulée: $id');
    } catch (e) {
      debugPrint('❌ Erreur annulation notification: $e');
    }
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('❌ Toutes les notifications annulées');
    } catch (e) {
      debugPrint('❌ Erreur annulation toutes notifications: $e');
    }
  }

  // ==========================================================================
  // 🔧 MÉTHODES UTILITAIRES
  // ==========================================================================

  /// Vérifie si on peut afficher une notification
  bool _canShowNotification() {
    return _isInitialized.value && _permissionGranted.value;
  }

  /// Obtient les détails de notification selon le type
  NotificationDetails _getNotificationDetails({
    NotificationType type = NotificationType.general,
    String? payload,
    NotificationPriority priority = NotificationPriority.high,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationConfig.channelId,
        NotificationConfig.channelName,
        channelDescription: NotificationConfig.channelDescription,
        importance: _getImportance(priority),
        priority: _getPriority(priority),
        icon: '@mipmap/ic_launcher',
        color: _getNotificationColor(type),
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: _getNotificationColor(type),
        ledOnMs: 1000,
        ledOffMs: 500,
        styleInformation: const BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: null,
      ),
    );
  }

  /// Obtient l'importance Android selon la priorité
  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Importance.min;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }

  /// Obtient la priorité Android selon notre enum personnalisé
  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Priority.min;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }

  /// Obtient la couleur selon le type de notification
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder:
        return AppColors.primary;
      case NotificationType.statusChange:
        return AppColors.info;
      case NotificationType.reminder:
        return AppColors.warning;
      case NotificationType.urgent:
        return AppColors.error;
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.general:
        return AppColors.gray600;
    }
  }

  /// Formate le texte d'affichage du statut
  String _getStatusDisplayText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'COLLECTING':
        return 'En collecte';
      case 'COLLECTED':
        return 'Collectée';
      case 'PROCESSING':
        return 'En traitement';
      case 'READY':
        return 'Prête pour livraison';
      case 'DELIVERING':
        return 'En livraison';
      case 'DELIVERED':
        return 'Livrée';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return status;
    }
  }

  /// Formate l'heure pour l'affichage
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Gère les interactions avec les notifications
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapée: ${response.payload}');

    if (response.payload != null) {
      // Navigation vers la commande concernée
      try {
        Get.toNamed('/orders/details',
            arguments: {'orderId': response.payload});
      } catch (e) {
        debugPrint('❌ Erreur navigation depuis notification: $e');
      }
    }
  }

  // ==========================================================================
  // 📊 GESTION DES BADGES
  // ==========================================================================

  /// Met à jour le badge de l'application
  Future<void> updateBadgeCount(int count) async {
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(badge: true);

      // Note: Le badge Android nécessite une implémentation native
      debugPrint('🔢 Badge mis à jour: $count');
    } catch (e) {
      debugPrint('❌ Erreur mise à jour badge: $e');
    }
  }

  /// Efface le badge
  Future<void> clearBadge() async {
    await updateBadgeCount(0);
  }
}

/// 🏷️ Types de notifications
enum NotificationType {
  general,
  newOrder,
  statusChange,
  reminder,
  urgent,
  success,
}

/// 🎯 Priorités de notification
enum NotificationPriority {
  min,
  low,
  defaultPriority,
  high,
  max,
}
