import 'package:flutter/material.dart';
import '../constants.dart';

enum NotificationType { ORDER, USER, SYSTEM, PAYMENT }

class AdminNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? referenceId;
  bool isRead;
  final DateTime createdAt;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
        orElse: () => NotificationType.SYSTEM,
      ),
      referenceId: json['referenceId'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'referenceId': referenceId,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

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
        return AppColors.error;
    }
  }
}
