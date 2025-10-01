import 'package:flutter/material.dart';
import '../../core/models/notification.dart';
import '../../core/services/notification_service.dart';

/// 📲 Provider de Notifications - Alpha Client App
///
/// Gère l'état des notifications avec synchronisation backend
/// et gestion des préférences utilisateur.
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // État des notifications
  List<AppNotification> _notifications = [];
  NotificationStats? _stats;
  NotificationPreferences? _preferences;
  
  // États de chargement et d'erreur
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isUpdating = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMoreNotifications = true;
  static const int _pageSize = 20;

  // Filtres
  NotificationType? _selectedType;
  bool? _showOnlyUnread;

  // Getters
  List<AppNotification> get notifications => _notifications;
  NotificationStats? get stats => _stats;
  NotificationPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  bool get hasMoreNotifications => _hasMoreNotifications;
  NotificationType? get selectedType => _selectedType;
  bool? get showOnlyUnread => _showOnlyUnread;

  // Getters calculés
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnreadNotifications => unreadCount > 0;
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  List<AppNotification> get todayNotifications {
    final today = DateTime.now();
    return _notifications.where((n) => 
        n.createdAt.day == today.day &&
        n.createdAt.month == today.month &&
        n.createdAt.year == today.year
    ).toList();
  }

  /// 🚀 Initialisation du provider
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await Future.wait([
        loadNotifications(refresh: true),
        loadPreferences(),
      ]);
      
      _clearError();
    } catch (e) {
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 📋 Charger les notifications
  Future<void> loadNotifications({
    bool refresh = false,
    NotificationType? type,
    bool? isRead,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreNotifications = true;
      _notifications.clear();
    }

    if (!_hasMoreNotifications && !refresh) return;

    _setLoadingMore(true);
    
    try {
      final newNotifications = await _notificationService.getNotifications(
        page: _currentPage,
        limit: _pageSize,
        type: type?.value,
        isRead: isRead,
      );

      if (refresh) {
        _notifications = newNotifications;
      } else {
        _notifications.addAll(newNotifications);
      }

      _hasMoreNotifications = newNotifications.length == _pageSize;
      _currentPage++;
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement: ${e.toString()}');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// 📊 Charger les statistiques
  Future<void> loadStats() async {
    try {
      final unreadCount = await _notificationService.getUnreadCount();
      
      // Calculer les stats localement
      final now = DateTime.now();
      final today = _notifications.where((n) => 
          n.createdAt.day == now.day &&
          n.createdAt.month == now.month &&
          n.createdAt.year == now.year
      ).length;
      
      final thisWeek = _notifications.where((n) => 
          now.difference(n.createdAt).inDays < 7
      ).length;
      
      final byType = <NotificationType, int>{};
      for (final notification in _notifications) {
        byType[notification.type] = (byType[notification.type] ?? 0) + 1;
      }
      
      _stats = NotificationStats(
        total: _notifications.length,
        unread: unreadCount,
        today: today,
        thisWeek: thisWeek,
        byType: byType,
      );
      
      notifyListeners();
    } catch (e) {
      // Erreur silencieuse pour les statistiques
    }
  }

  /// ⚙️ Charger les préférences
  Future<void> loadPreferences() async {
    try {
      _preferences = await _notificationService.getPreferences();
      notifyListeners();
    } catch (e) {
      // Erreur silencieuse pour les préférences
    }
  }

  /// ✅ Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      _setError('Erreur lors du marquage: ${e.toString()}');
      return false;
    }
  }

  /// ✅ Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    _setUpdating(true);
    
    try {
      final success = await _notificationService.markAllAsRead();
      
      if (success) {
        final now = DateTime.now();
        _notifications = _notifications.map((n) => n.copyWith(
          isRead: true,
          readAt: now,
        )).toList();
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Erreur lors du marquage: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// 🗑️ Supprimer une notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      
      if (success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Erreur lors de la suppression: ${e.toString()}');
      return false;
    }
  }

  /// ⚙️ Mettre à jour les préférences
  Future<bool> updatePreferences(NotificationPreferences preferences) async {
    try {
      final success = await _notificationService.updatePreferences(preferences);
      
      if (success) {
        _preferences = preferences;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Erreur lors de la mise à jour: ${e.toString()}');
      return false;
    }
  }

  /// 🔍 Appliquer des filtres
  void applyFilters({
    NotificationType? type,
    bool? showOnlyUnread,
  }) {
    _selectedType = type;
    _showOnlyUnread = showOnlyUnread;
    
    loadNotifications(
      refresh: true,
      type: type,
      isRead: showOnlyUnread == true ? false : null,
    );
  }

  /// 🔄 Actualiser
  Future<void> refresh() async {
    await Future.wait([
      loadNotifications(refresh: true),
      loadStats(),
    ]);
  }

  /// 📱 Ajouter une notification locale (pour les push)
  void addLocalNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// 🔧 Méthodes utilitaires privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// 🧹 Nettoyage des ressources
  @override
  void dispose() {
    super.dispose();
  }

  /// 🎯 Méthodes utilitaires pour l'UI

  /// Obtenir les notifications par type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Vérifier si une notification peut être supprimée
  bool canDeleteNotification(String notificationId) {
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => throw Exception('Notification not found'),
    );
    return notification.canBeDeleted;
  }

  /// Obtenir le nombre de notifications par type
  Map<NotificationType, int> getCountByType() {
    final counts = <NotificationType, int>{};
    for (final notification in _notifications) {
      counts[notification.type] = (counts[notification.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Vérifier s'il y a des notifications récentes (moins de 1h)
  bool get hasRecentNotifications {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return _notifications.any((n) => n.createdAt.isAfter(oneHourAgo));
  }
}