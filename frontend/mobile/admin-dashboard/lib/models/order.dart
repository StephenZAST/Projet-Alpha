import 'dart:ui';
import 'user.dart';

import 'package:admin/constants.dart';

enum OrderStatus {
  PENDING,
  COLLECTING,
  COLLECTED,
  PROCESSING,
  READY,
  DELIVERING,
  DELIVERED,
  CANCELLED
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    return toString().split('.').last;
  }

  Color get color {
    switch (this) {
      case OrderStatus.PENDING:
        return AppColors.warning;
      case OrderStatus.COLLECTING:
        return AppColors.primary;
      case OrderStatus.COLLECTED:
        return AppColors.primary.withOpacity(0.7);
      case OrderStatus.PROCESSING:
        return AppColors.primary;
      case OrderStatus.READY:
        return AppColors.success;
      case OrderStatus.DELIVERING:
        return AppColors.primary;
      case OrderStatus.DELIVERED:
        return AppColors.success;
      case OrderStatus.CANCELLED:
        return AppColors.error;
    }
  }
}

class Order {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user; // Ajout de la propriété user

  Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
