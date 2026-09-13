import 'package:flutter/material.dart';
import '../constants.dart';

/// Les 19 types de notifications alignés avec le backend
enum NotificationType {
  // LOYALTY (2)
  REWARD_CLAIM_APPROVED,
  REWARD_CLAIM_REJECTED,
  // ORDERS (5)
  ORDER_PLACED,
  PAYMENT_FAILED,
  ORDER_STATUS_CHANGED,
  ORDER_READY_PICKUP,
  ORDER_CANCELLED,
  // DELIVERY (3)
  DELIVERY_ASSIGNED,
  DELIVERY_COMPLETED,
  DELIVERY_PROBLEM,
  // AFFILIATION (4)
  REFERRAL_CODE_USED,
  COMMISSION_EARNED,
  WITHDRAWAL_APPROVED,
  WITHDRAWAL_REJECTED,
  // SUBSCRIPTION (2)
  SUBSCRIPTION_ACTIVATED,
  SUBSCRIPTION_CANCELLED,
  // ADMIN (3)
  NEW_USER_REGISTERED,
  NEW_ORDER_ALERT,
  PAYMENT_SYSTEM_ISSUE,
  // Legacy (pour compatibilité)
  ORDER,
  USER,
  SYSTEM,
  PAYMENT,
  DELIVERY,
  AFFILIATE
}

enum NotificationPriority { LOW, NORMAL, HIGH, URGENT }

class AdminNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? referenceId;
  bool isRead;
  final DateTime createdAt;
  final NotificationPriority priority;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
    this.priority = NotificationPriority.NORMAL,
  });

  static NotificationType _normalizeType(String rawType) {
    final value = rawType.trim().toUpperCase();

    switch (value) {
      case 'ORDER_CREATED':
        return NotificationType.ORDER_PLACED;
      case 'ORDER_STATUS_UPDATED':
        return NotificationType.ORDER_STATUS_CHANGED;
      case 'ORDER_STATUS':
        return NotificationType.ORDER_STATUS_CHANGED;
      case 'READY_FOR_PICKUP':
      case 'ORDER_READY_FOR_PICKUP':
      case 'ORDER_READY_PICKUP':
        return NotificationType.ORDER_READY_PICKUP;
      case 'ORDER_CANCELLED':
      case 'CANCELLED_ORDER':
        return NotificationType.ORDER_CANCELLED;
      case 'NEW_ORDER_ALERT':
        return NotificationType.NEW_ORDER_ALERT;
      case 'PAYMENT_SYSTEM_ISSUE':
        return NotificationType.PAYMENT_SYSTEM_ISSUE;
      case 'PAYMENT_FAILED':
        return NotificationType.PAYMENT_FAILED;
      case 'WITHDRAWAL_APPROVED':
        return NotificationType.WITHDRAWAL_APPROVED;
      case 'WITHDRAWAL_REJECTED':
        return NotificationType.WITHDRAWAL_REJECTED;
      case 'REFERRAL_CODE_USED':
        return NotificationType.REFERRAL_CODE_USED;
      case 'COMMISSION_EARNED':
        return NotificationType.COMMISSION_EARNED;
      case 'SUBSCRIPTION_ACTIVATED':
        return NotificationType.SUBSCRIPTION_ACTIVATED;
      case 'SUBSCRIPTION_CANCELLED':
        return NotificationType.SUBSCRIPTION_CANCELLED;
      case 'NEW_USER_REGISTERED':
        return NotificationType.NEW_USER_REGISTERED;
      default:
        try {
          return NotificationType.values.firstWhere(
            (type) => type.toString().split('.').last == value,
            orElse: () => NotificationType.SYSTEM,
          );
        } catch (_) {
          return NotificationType.SYSTEM;
        }
    }
  }

  static String? _extractEventTypeFromPayload(Map<String, dynamic> json) {
    final candidates = <String?>[
      json['type'],
      json['event_type'],
      json['eventType'],
      json['category'],
      json['kind'],
      json['title'],
      json['message'],
    ];

    final data = json['data'];
    if (data is Map) {
      final dataMap = data as Map<String, dynamic>;
      candidates.addAll([
        dataMap['type'],
        dataMap['event_type'],
        dataMap['eventType'],
        dataMap['category'],
        dataMap['kind'],
      ]);
    }

    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value == null || value.isEmpty) continue;

      final upper = value.toUpperCase();
      if (upper.contains('NEW_ORDER_ALERT')) return 'NEW_ORDER_ALERT';
      if (upper.contains('NEW_USER_REGISTERED')) return 'NEW_USER_REGISTERED';
      if (upper.contains('ORDER_CREATED')) return 'ORDER_CREATED';
      if (upper.contains('ORDER_STATUS_UPDATED')) return 'ORDER_STATUS_UPDATED';
      if (upper.contains('ORDER_READY_PICKUP')) return 'ORDER_READY_PICKUP';
      if (upper.contains('ORDER_CANCELLED')) return 'ORDER_CANCELLED';
      if (upper.contains('PAYMENT_FAILED')) return 'PAYMENT_FAILED';
      if (upper.contains('PAYMENT_SYSTEM_ISSUE')) return 'PAYMENT_SYSTEM_ISSUE';
      if (upper.contains('SUBSCRIPTION_ACTIVATED')) return 'SUBSCRIPTION_ACTIVATED';
      if (upper.contains('SUBSCRIPTION_CANCELLED')) return 'SUBSCRIPTION_CANCELLED';
      if (upper.contains('WITHDRAWAL_APPROVED')) return 'WITHDRAWAL_APPROVED';
      if (upper.contains('WITHDRAWAL_REJECTED')) return 'WITHDRAWAL_REJECTED';
      if (upper.contains('REFERRAL_CODE_USED')) return 'REFERRAL_CODE_USED';
      if (upper.contains('COMMISSION_EARNED')) return 'COMMISSION_EARNED';
      if (upper.contains('REWARD_CLAIM_APPROVED')) return 'REWARD_CLAIM_APPROVED';
      if (upper.contains('REWARD_CLAIM_REJECTED')) return 'REWARD_CLAIM_REJECTED';
      if (upper.contains('DELIVERY_ASSIGNED')) return 'DELIVERY_ASSIGNED';
      if (upper.contains('DELIVERY_COMPLETED')) return 'DELIVERY_COMPLETED';
      if (upper.contains('DELIVERY_PROBLEM')) return 'DELIVERY_PROBLEM';
    }

    return null;
  }

  static String? _extractReferenceId(Map<String, dynamic> json) {
    final directCandidates = [
      json['referenceId'],
      json['reference_id'],
      json['orderId'],
      json['order_id'],
      json['notificationId'],
      json['notification_id'],
      json['id'],
    ];

    for (final candidate in directCandidates) {
      final value = candidate?.toString();
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }

    final payload = json['data'];
    if (payload is Map) {
      final nested = payload as Map<String, dynamic>;
      final nestedCandidates = [
        nested['orderId'],
        nested['order_id'],
        nested['referenceId'],
        nested['reference_id'],
        nested['id'],
      ];

      for (final candidate in nestedCandidates) {
        final value = candidate?.toString();
        if (value != null && value.trim().isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    try {
      // Gérer les champs du nouveau format du backend
      DateTime createdAt;
      try {
        final createdAtValue = json['createdAt'] ?? json['created_at'];
        if (createdAtValue == null || createdAtValue.toString().isEmpty) {
          createdAt = DateTime.now();
        } else {
          createdAt = DateTime.parse(createdAtValue.toString());
        }
      } catch (e) {
        createdAt = DateTime.now();
      }

      // Parser le type de notification
      final rawType = (json['type'] ?? json['event_type'] ?? json['eventType'] ?? 'SYSTEM').toString();
      final discoveredType = _extractEventTypeFromPayload(json);
      final type = discoveredType != null
          ? _normalizeType(discoveredType)
          : _normalizeType(rawType);

      // Parser la priorité
      String priorityStr = (json['priority'] ?? 'NORMAL').toString().toUpperCase();
      NotificationPriority priority = NotificationPriority.NORMAL;
      try {
        priority = NotificationPriority.values.firstWhere(
          (p) => p.toString().split('.').last == priorityStr,
          orElse: () => NotificationPriority.NORMAL,
        );
      } catch (e) {
        priority = NotificationPriority.NORMAL;
      }

      final referenceId = _extractReferenceId(json);

      return AdminNotification(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Notification',
        message: json['message']?.toString() ?? '',
        type: type,
        referenceId: referenceId,
        isRead: json['isRead'] == true || json['read'] == true,
        createdAt: createdAt,
        priority: priority,
      );
    } catch (e) {
      print('Error parsing notification: $e');
      // Retourner une notification par défaut en cas d'erreur
      return AdminNotification(
        id: json['id']?.toString() ?? DateTime.now().toString(),
        title: 'Erreur de notification',
        message: 'Impossible de charger cette notification',
        type: NotificationType.SYSTEM,
        createdAt: DateTime.now(),
        isRead: true,
        priority: NotificationPriority.LOW,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'referenceId': referenceId,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
        'priority': priority.toString().split('.').last,
      };

  AdminNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? referenceId,
    bool? isRead,
    DateTime? createdAt,
    NotificationPriority? priority,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
    );
  }

  String get categoryKey {
    switch (type) {
      case NotificationType.REWARD_CLAIM_APPROVED:
      case NotificationType.REWARD_CLAIM_REJECTED:
        return 'loyalty';
      case NotificationType.ORDER_PLACED:
      case NotificationType.ORDER_STATUS_CHANGED:
      case NotificationType.ORDER_READY_PICKUP:
      case NotificationType.ORDER_CANCELLED:
      case NotificationType.NEW_ORDER_ALERT:
      case NotificationType.ORDER:
        return 'order';
      case NotificationType.PAYMENT_FAILED:
      case NotificationType.PAYMENT_SYSTEM_ISSUE:
      case NotificationType.PAYMENT:
        return 'payment';
      case NotificationType.DELIVERY_ASSIGNED:
      case NotificationType.DELIVERY_COMPLETED:
      case NotificationType.DELIVERY_PROBLEM:
      case NotificationType.DELIVERY:
        return 'delivery';
      case NotificationType.REFERRAL_CODE_USED:
      case NotificationType.COMMISSION_EARNED:
      case NotificationType.WITHDRAWAL_APPROVED:
      case NotificationType.WITHDRAWAL_REJECTED:
      case NotificationType.AFFILIATE:
        return 'affiliate';
      case NotificationType.SUBSCRIPTION_ACTIVATED:
      case NotificationType.SUBSCRIPTION_CANCELLED:
        return 'subscription';
      case NotificationType.NEW_USER_REGISTERED:
      case NotificationType.USER:
        return 'user';
      case NotificationType.SYSTEM:
        return 'system';
    }
  }

  bool matchesCategory(String selectedType) {
    final normalized = selectedType.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'all') {
      return true;
    }

    return categoryKey == normalized;
  }

  String get categoryLabel {
    switch (categoryKey) {
      case 'loyalty':
        return 'Fidélité';
      case 'order':
        return 'Commande';
      case 'payment':
        return 'Paiement';
      case 'delivery':
        return 'Livraison';
      case 'affiliate':
        return 'Affiliation';
      case 'subscription':
        return 'Abonnement';
      case 'user':
        return 'Utilisateur';
      case 'system':
        return 'Système';
      default:
        return 'Notification';
    }
  }

  IconData get icon {
    switch (type) {
      // LOYALTY
      case NotificationType.REWARD_CLAIM_APPROVED:
      case NotificationType.REWARD_CLAIM_REJECTED:
        return Icons.card_giftcard;
      // ORDERS
      case NotificationType.ORDER_PLACED:
      case NotificationType.ORDER_STATUS_CHANGED:
      case NotificationType.ORDER_READY_PICKUP:
      case NotificationType.ORDER_CANCELLED:
      case NotificationType.ORDER:
        return Icons.shopping_cart;
      case NotificationType.PAYMENT_FAILED:
      case NotificationType.PAYMENT:
        return Icons.payment;
      // DELIVERY
      case NotificationType.DELIVERY_ASSIGNED:
      case NotificationType.DELIVERY_COMPLETED:
      case NotificationType.DELIVERY_PROBLEM:
      case NotificationType.DELIVERY:
        return Icons.local_shipping;
      // AFFILIATION
      case NotificationType.REFERRAL_CODE_USED:
      case NotificationType.COMMISSION_EARNED:
      case NotificationType.WITHDRAWAL_APPROVED:
      case NotificationType.WITHDRAWAL_REJECTED:
      case NotificationType.AFFILIATE:
        return Icons.group;
      // SUBSCRIPTION
      case NotificationType.SUBSCRIPTION_ACTIVATED:
      case NotificationType.SUBSCRIPTION_CANCELLED:
        return Icons.calendar_month;
      // ADMIN
      case NotificationType.NEW_USER_REGISTERED:
      case NotificationType.USER:
        return Icons.person_add;
      case NotificationType.NEW_ORDER_ALERT:
        return Icons.notifications_active;
      case NotificationType.PAYMENT_SYSTEM_ISSUE:
        return Icons.warning;
      // Legacy
      case NotificationType.SYSTEM:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      // LOYALTY
      case NotificationType.REWARD_CLAIM_APPROVED:
      case NotificationType.REWARD_CLAIM_REJECTED:
        return AppColors.success;
      // ORDERS
      case NotificationType.ORDER_PLACED:
      case NotificationType.ORDER_STATUS_CHANGED:
      case NotificationType.ORDER_READY_PICKUP:
      case NotificationType.ORDER_CANCELLED:
      case NotificationType.ORDER:
        return AppColors.primary;
      case NotificationType.PAYMENT_FAILED:
      case NotificationType.PAYMENT:
        return AppColors.error;
      // DELIVERY
      case NotificationType.DELIVERY_ASSIGNED:
      case NotificationType.DELIVERY_COMPLETED:
      case NotificationType.DELIVERY_PROBLEM:
      case NotificationType.DELIVERY:
        return AppColors.accent;
      // AFFILIATION
      case NotificationType.REFERRAL_CODE_USED:
      case NotificationType.COMMISSION_EARNED:
      case NotificationType.WITHDRAWAL_APPROVED:
      case NotificationType.WITHDRAWAL_REJECTED:
      case NotificationType.AFFILIATE:
        return AppColors.categoryTag;
      // SUBSCRIPTION
      case NotificationType.SUBSCRIPTION_ACTIVATED:
      case NotificationType.SUBSCRIPTION_CANCELLED:
        return AppColors.violet;
      // ADMIN
      case NotificationType.NEW_USER_REGISTERED:
      case NotificationType.USER:
        return AppColors.warning;
      case NotificationType.NEW_ORDER_ALERT:
        return AppColors.primary;
      case NotificationType.PAYMENT_SYSTEM_ISSUE:
        return AppColors.error;
      // Legacy
      case NotificationType.SYSTEM:
        return AppColors.info;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case NotificationPriority.LOW:
        return AppColors.gray400;
      case NotificationPriority.NORMAL:
        return AppColors.info;
      case NotificationPriority.HIGH:
        return AppColors.warning;
      case NotificationPriority.URGENT:
        return AppColors.error;
    }
  }

  String get typeLabel {
    switch (type) {
      // LOYALTY
      case NotificationType.REWARD_CLAIM_APPROVED:
        return 'Récompense Approuvée';
      case NotificationType.REWARD_CLAIM_REJECTED:
        return 'Récompense Rejetée';
      // ORDERS
      case NotificationType.ORDER_PLACED:
        return 'Commande Créée';
      case NotificationType.PAYMENT_FAILED:
        return 'Paiement Échoué';
      case NotificationType.ORDER_STATUS_CHANGED:
        return 'Statut Commande';
      case NotificationType.ORDER_READY_PICKUP:
        return 'Commande Prête';
      case NotificationType.ORDER_CANCELLED:
        return 'Commande Annulée';
      // DELIVERY
      case NotificationType.DELIVERY_ASSIGNED:
        return 'Livraison Assignée';
      case NotificationType.DELIVERY_COMPLETED:
        return 'Livraison Complétée';
      case NotificationType.DELIVERY_PROBLEM:
        return 'Problème Livraison';
      // AFFILIATION
      case NotificationType.REFERRAL_CODE_USED:
        return 'Code Parrainage Utilisé';
      case NotificationType.COMMISSION_EARNED:
        return 'Commission Gagnée';
      case NotificationType.WITHDRAWAL_APPROVED:
        return 'Retrait Approuvé';
      case NotificationType.WITHDRAWAL_REJECTED:
        return 'Retrait Rejeté';
      // SUBSCRIPTION
      case NotificationType.SUBSCRIPTION_ACTIVATED:
        return 'Abonnement Activé';
      case NotificationType.SUBSCRIPTION_CANCELLED:
        return 'Abonnement Annulé';
      // ADMIN
      case NotificationType.NEW_USER_REGISTERED:
        return 'Nouvel Utilisateur';
      case NotificationType.NEW_ORDER_ALERT:
        return 'Nouvelle Commande';
      case NotificationType.PAYMENT_SYSTEM_ISSUE:
        return 'Problème Paiement';
      // Legacy
      case NotificationType.ORDER:
        return 'Commande';
      case NotificationType.USER:
        return 'Utilisateur';
      case NotificationType.PAYMENT:
        return 'Paiement';
      case NotificationType.SYSTEM:
        return 'Système';
      case NotificationType.DELIVERY:
        return 'Livraison';
      case NotificationType.AFFILIATE:
        return 'Affilié';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
