import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

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
    return switch (this) {
      OrderStatus.PENDING => 'En attente',
      OrderStatus.COLLECTING => 'En cours de collecte',
      OrderStatus.COLLECTED => 'Collectée',
      OrderStatus.PROCESSING => 'En traitement',
      OrderStatus.READY => 'Prête',
      OrderStatus.DELIVERING => 'En livraison',
      OrderStatus.DELIVERED => 'Livrée',
      OrderStatus.CANCELLED => 'Annulée',
    };
  }

  Color get color {
    return switch (this) {
      OrderStatus.PENDING ||
      OrderStatus.COLLECTING ||
      OrderStatus.PROCESSING =>
        AppColors.warning,
      OrderStatus.COLLECTED ||
      OrderStatus.READY ||
      OrderStatus.DELIVERING =>
        AppColors.primary,
      OrderStatus.DELIVERED => AppColors.success,
      OrderStatus.CANCELLED => AppColors.error,
    };
  }

  IconData get icon {
    return switch (this) {
      OrderStatus.PENDING => Icons.schedule,
      OrderStatus.COLLECTING || OrderStatus.DELIVERING => Icons.local_shipping,
      OrderStatus.COLLECTED => Icons.inventory_2,
      OrderStatus.PROCESSING => Icons.wash,
      OrderStatus.READY => Icons.check_circle_outline,
      OrderStatus.DELIVERED => Icons.check_circle,
      OrderStatus.CANCELLED => Icons.cancel,
    };
  }
}
