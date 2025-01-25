import 'package:flutter/material.dart';
import '../constants.dart';

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

enum PaymentMethod { CASH, ORANGE_MONEY }

enum AppButtonVariant { primary, secondary, error, success }

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
      default:
        return '';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.PENDING:
        return AppColors.pending;
      case OrderStatus.COLLECTING:
        return AppColors.processing;
      case OrderStatus.COLLECTED:
        return AppColors.completed;
      case OrderStatus.PROCESSING:
        return AppColors.processing;
      case OrderStatus.READY:
        return AppColors.completed;
      case OrderStatus.DELIVERING:
        return AppColors.processing;
      case OrderStatus.DELIVERED:
        return AppColors.delivered;
      case OrderStatus.CANCELLED:
        return AppColors.cancelled;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.PENDING:
        return Icons.hourglass_empty;
      case OrderStatus.COLLECTING:
        return Icons.directions_car;
      case OrderStatus.COLLECTED:
        return Icons.check_circle_outline;
      case OrderStatus.PROCESSING:
        return Icons.local_laundry_service;
      case OrderStatus.READY:
        return Icons.check_circle;
      case OrderStatus.DELIVERING:
        return Icons.local_shipping;
      case OrderStatus.DELIVERED:
        return Icons.done_all;
      case OrderStatus.CANCELLED:
        return Icons.cancel;
    }
  }
}

extension OrderStatusParser on String? {
  OrderStatus toOrderStatus() {
    if (this == null || this!.isEmpty) {
      return OrderStatus.PENDING;
    }
    try {
      return OrderStatus.values.firstWhere(
        (status) => status.name == this!.toUpperCase(),
        orElse: () => OrderStatus.PENDING,
      );
    } catch (e) {
      print('Error parsing OrderStatus from string: $this');
      return OrderStatus.PENDING;
    }
  }
}

extension PaymentMethodExtension on String {
  PaymentMethod toPaymentMethod() {
    try {
      return PaymentMethod.values.firstWhere(
        (method) => method.name == toUpperCase(),
        orElse: () => PaymentMethod.CASH,
      );
    } catch (e) {
      print('Error parsing PaymentMethod from string: $this');
      return PaymentMethod.CASH;
    }
  }
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.CASH:
        return 'Espèces';
      case PaymentMethod.ORANGE_MONEY:
        return 'Orange Money';
      default:
        return name;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.CASH:
        return Icons.payments_outlined;
      case PaymentMethod.ORANGE_MONEY:
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }
}

enum PaymentStatus {
  PENDING,
  PAID,
  FAILED,
  REFUNDED,
}

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.PENDING:
        return 'En attente';
      case PaymentStatus.PAID:
        return 'Payé';
      case PaymentStatus.FAILED:
        return 'Échoué';
      case PaymentStatus.REFUNDED:
        return 'Remboursé';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.PENDING:
        return AppColors.warning;
      case PaymentStatus.PAID:
        return AppColors.success;
      case PaymentStatus.FAILED:
        return AppColors.error;
      case PaymentStatus.REFUNDED:
        return AppColors.accent;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.PENDING:
        return Icons.pending;
      case PaymentStatus.PAID:
        return Icons.payment;
      case PaymentStatus.FAILED:
        return Icons.error;
      case PaymentStatus.REFUNDED:
        return Icons.replay;
    }
  }
}

extension PaymentStatusParser on String {
  PaymentStatus toPaymentStatus() {
    return PaymentStatus.values.firstWhere(
      (status) => status.name == this.toUpperCase(),
      orElse: () => PaymentStatus.PENDING,
    );
  }
}
