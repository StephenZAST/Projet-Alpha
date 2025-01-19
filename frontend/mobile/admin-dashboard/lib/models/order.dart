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
  final double amount;
  final OrderStatus status;
  final DateTime date;

  Order({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.date,
  });
}

List<Order> demoOrders = [
  Order(
    id: "1",
    customerName: "John Doe",
    amount: 100.0,
    status: OrderStatus.PENDING,
    date: DateTime.now().subtract(Duration(days: 1)),
  ),
  Order(
    id: "2",
    customerName: "Jane Smith",
    amount: 200.0,
    status: OrderStatus.COMPLETED,
    date: DateTime.now().subtract(Duration(days: 2)),
  ),
  // ...other orders...
];
