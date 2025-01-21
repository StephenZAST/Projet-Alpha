import 'dart:ui';

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
    switch (this) {
      case OrderStatus.PENDING:
        return 'En attente';
      case OrderStatus.COLLECTING:
        return 'En collecte';
      case OrderStatus.COLLECTED:
        return 'Collecté';
      case OrderStatus.PROCESSING:
        return 'En traitement';
      case OrderStatus.READY:
        return 'Prêt';
      case OrderStatus.DELIVERING:
        return 'En livraison';
      case OrderStatus.DELIVERED:
        return 'Livré';
      case OrderStatus.CANCELLED:
        return 'Annulé';
    }
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
  final String customerName;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customerName'],
      status: OrderStatus.values
          .firstWhere((e) => e.toString() == 'OrderStatus.${json['status']}'),
      totalAmount: double.parse(json['totalAmount'].toString()),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'status': status.toString().split('.').last,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
