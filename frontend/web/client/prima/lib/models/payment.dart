import 'package:flutter/material.dart';

enum PaymentMethod { CASH, ORANGE_MONEY }

extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.CASH:
        return 'Paiement en espèces';
      case PaymentMethod.ORANGE_MONEY:
        return 'Orange Money';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.CASH:
        return 'Paiement à la livraison';
      case PaymentMethod.ORANGE_MONEY:
        return 'Transfert au : +237 6XX XXX XXX';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.CASH:
        return Icons.payments_outlined;
      case PaymentMethod.ORANGE_MONEY:
        return Icons.phone_android;
    }
  }
}

enum PaymentStatus { PENDING, COMPLETED }
