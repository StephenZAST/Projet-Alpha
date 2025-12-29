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
      String typeStr = (json['type'] ?? 'SYSTEM').toString().toUpperCase();
      NotificationType type = NotificationType.SYSTEM;
      try {
        type = NotificationType.values.firstWhere(
          (t) => t.toString().split('.').last == typeStr,
          orElse: () => NotificationType.SYSTEM,
        );
      } catch (e) {
        type = NotificationType.SYSTEM;
      }

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

      return AdminNotification(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Notification',
        message: json['message']?.toString() ?? '',
        type: type,
        referenceId: json['referenceId']?.toString() ?? json['reference_id']?.toString(),
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
