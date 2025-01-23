import 'package:flutter/material.dart';
import '../constants.dart';

enum NotificationType { ORDER, USER, SYSTEM, PAYMENT, DELIVERY, AFFILIATE }

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
      return AdminNotification(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Notification',
        message: json['message']?.toString() ?? '',
        type: NotificationType.values.firstWhere(
          (type) =>
              type.toString().split('.').last ==
              (json['type'] ?? '').toString().toUpperCase(),
          orElse: () => NotificationType.SYSTEM,
        ),
        referenceId: json['referenceId']?.toString(),
        isRead: json['isRead'] == true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        priority: NotificationPriority.values.firstWhere(
          (p) =>
              p.toString().split('.').last ==
              (json['priority'] ?? '').toString().toUpperCase(),
          orElse: () => NotificationPriority.NORMAL,
        ),
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
      case NotificationType.ORDER:
        return Icons.shopping_cart;
      case NotificationType.USER:
        return Icons.person;
      case NotificationType.PAYMENT:
        return Icons.payment;
      case NotificationType.SYSTEM:
        return Icons.info;
      case NotificationType.DELIVERY:
        return Icons.local_shipping;
      case NotificationType.AFFILIATE:
        return Icons.group;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.ORDER:
        return AppColors.primary;
      case NotificationType.USER:
        return AppColors.warning;
      case NotificationType.PAYMENT:
        return AppColors.success;
      case NotificationType.SYSTEM:
        return AppColors.info;
      case NotificationType.DELIVERY:
        return AppColors.accent;
      case NotificationType.AFFILIATE:
        return AppColors.categoryTag;
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
