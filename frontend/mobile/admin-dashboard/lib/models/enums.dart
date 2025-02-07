import 'package:flutter/material.dart';
import '../constants.dart';

enum OrderStatus {
  DRAFT('Brouillon', AppColors.gray400, Icons.edit_note),
  PENDING('En attente', AppColors.warning, Icons.pending_actions),
  COLLECTING('En collecte', AppColors.info, Icons.directions_run),
  COLLECTED('Collecté', AppColors.accent, Icons.check_circle_outline),
  PROCESSING('En traitement', AppColors.primary, Icons.local_laundry_service),
  READY('Prêt', AppColors.violet, Icons.thumb_up_outlined),
  DELIVERING('En livraison', AppColors.orange, Icons.local_shipping_outlined),
  DELIVERED('Livré', AppColors.success, Icons.task_alt),
  CANCELLED('Annulé', AppColors.error, Icons.cancel_outlined);

  final String label;
  final Color color;
  final IconData icon;

  const OrderStatus(this.label, this.color, this.icon);

  static Map<String, List<String>> validTransitions = {
    'DRAFT': ['PENDING'],
    'PENDING': ['COLLECTING', 'CANCELLED'],
    'COLLECTING': ['COLLECTED', 'CANCELLED'],
    'COLLECTED': ['PROCESSING', 'CANCELLED'],
    'PROCESSING': ['READY', 'CANCELLED'],
    'READY': ['DELIVERING', 'CANCELLED'],
    'DELIVERING': ['DELIVERED', 'CANCELLED'],
    'DELIVERED': [],
    'CANCELLED': []
  };

  static bool isValidTransition(String from, String to) {
    final validNext = validTransitions[from] ?? [];
    return validNext.contains(to);
  }
}

enum PaymentMethod { CASH, ORANGE_MONEY }

enum AppButtonVariant { primary, secondary, error, success }

extension OrderStatusParser on String? {
  OrderStatus toOrderStatus() {
    if (this == null) return OrderStatus.PENDING;

    final status = this!.toUpperCase();
    try {
      return OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
        orElse: () {
          print('Status inconnu: $status, utilisation de PENDING par défaut');
          return OrderStatus.PENDING;
        },
      );
    } catch (e) {
      print('Erreur lors de la conversion du status: $this - $e');
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
