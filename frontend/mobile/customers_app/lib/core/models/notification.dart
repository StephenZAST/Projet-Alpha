import 'package:flutter/material.dart';
import '../../constants.dart';

/// 📲 Modèle de Notification - Alpha Client App
///
/// Représente une notification dans l'application avec tous ses attributs
/// et méthodes utilitaires pour l'affichage et la gestion.
class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? readAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.isRead = false,
    this.priority = NotificationPriority.normal,
    required this.createdAt,
    this.readAt,
  });

  /// 📊 Conversion depuis JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Gérer les champs null ou manquants
    DateTime createdAt;
    try {
      final createdAtValue = json['createdAt'];
      if (createdAtValue == null || createdAtValue.isEmpty) {
        createdAt = DateTime.now();
      } else {
        createdAt = DateTime.parse(createdAtValue.toString());
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    DateTime? readAt;
    try {
      final readAtValue = json['readAt'];
      if (readAtValue != null && readAtValue.toString().isNotEmpty) {
        readAt = DateTime.parse(readAtValue.toString());
      }
    } catch (e) {
      readAt = null;
    }

    return AppNotification(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: NotificationType.fromString(json['type']?.toString() ?? 'info'),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] == true,
      priority: NotificationPriority.fromString(json['priority']?.toString() ?? 'normal'),
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.value,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'priority': priority.value,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  /// 🔄 Copie avec modifications
  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    NotificationPriority? priority,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// 🎨 Couleur selon le type
  Color get color {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.info;
      case NotificationType.order:
        return AppColors.primary;
      case NotificationType.promotion:
        return AppColors.pink;
      case NotificationType.loyalty:
        return AppColors.warning;
    }
  }

  /// 🎯 Icône selon le type
  IconData get icon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.loyalty:
        return Icons.stars;
    }
  }

  /// ⏰ Temps relatif depuis la création
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// 📱 Peut être supprimée par l'utilisateur
  bool get canBeDeleted {
    return type != NotificationType.order || 
           DateTime.now().difference(createdAt).inDays > 7;
  }
}

/// 🏷️ Types de notification
enum NotificationType {
  success('success'),
  error('error'),
  warning('warning'),
  info('info'),
  order('order'),
  promotion('promotion'),
  loyalty('loyalty');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.info,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationType.success:
        return 'Succès';
      case NotificationType.error:
        return 'Erreur';
      case NotificationType.warning:
        return 'Attention';
      case NotificationType.info:
        return 'Information';
      case NotificationType.order:
        return 'Commande';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.loyalty:
        return 'Fidélité';
    }
  }
}

/// 🎯 Priorités de notification
enum NotificationPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  const NotificationPriority(this.value);
  final String value;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Faible';
      case NotificationPriority.normal:
        return 'Normale';
      case NotificationPriority.high:
        return 'Élevée';
      case NotificationPriority.urgent:
        return 'Urgente';
    }
  }

  Color get color {
    switch (this) {
      case NotificationPriority.low:
        return AppColors.lightTextTertiary;
      case NotificationPriority.normal:
        return AppColors.info;
      case NotificationPriority.high:
        return AppColors.warning;
      case NotificationPriority.urgent:
        return AppColors.error;
    }
  }
}

/// 📊 Statistiques de notifications
class NotificationStats {
  final int total;
  final int unread;
  final int today;
  final int thisWeek;
  final Map<NotificationType, int> byType;

  NotificationStats({
    required this.total,
    required this.unread,
    required this.today,
    required this.thisWeek,
    required this.byType,
  });

  /// 📊 Conversion depuis JSON
  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    final byTypeJson = json['byType'] as Map<String, dynamic>? ?? {};
    final byType = <NotificationType, int>{};
    
    for (final entry in byTypeJson.entries) {
      try {
        final type = NotificationType.fromString(entry.key);
        final value = entry.value;
        byType[type] = value is int ? value : int.tryParse(value.toString()) ?? 0;
      } catch (e) {
        // Ignorer les entrées invalides
      }
    }

    return NotificationStats(
      total: _parseInt(json['total']),
      unread: _parseInt(json['unread']),
      today: _parseInt(json['today']),
      thisWeek: _parseInt(json['thisWeek']),
      byType: byType,
    );
  }

  /// 🔧 Utilitaire pour parser les entiers
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    final byTypeJson = <String, int>{};
    for (final entry in byType.entries) {
      byTypeJson[entry.key.value] = entry.value;
    }

    return {
      'total': total,
      'unread': unread,
      'today': today,
      'thisWeek': thisWeek,
      'byType': byTypeJson,
    };
  }

  /// 📊 Pourcentage de notifications non lues
  double get unreadPercentage {
    if (total == 0) return 0.0;
    return (unread / total) * 100;
  }

  /// 📈 Type de notification le plus fréquent
  NotificationType? get mostFrequentType {
    if (byType.isEmpty) return null;
    
    return byType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}