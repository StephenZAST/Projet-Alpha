/// 💰 Modèle de Tarification de Commande - Alpha Client App
///
/// Représente le calcul de prix d'une commande avec réductions et prix manuel ajusté par admin
class OrderPricing {
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double taxAmount;
  final double total;

  // ✅ NOUVEAU - Prix manuel ajusté par l'admin
  final double? manualPrice;
  final double? originalPrice;
  final double? discountPercentage;

  // ✅ NOUVEAU - Statut de paiement
  final bool isPaid;
  final DateTime? paidAt;
  final String? paymentReason;

  // ✅ NOUVEAU - Métadonnées
  final DateTime? updatedAt;

  OrderPricing({
    required this.subtotal,
    required this.discount,
    this.deliveryFee = 0.0,
    this.taxAmount = 0.0,
    required this.total,
    // ✅ NOUVEAU
    this.manualPrice,
    this.originalPrice,
    this.discountPercentage,
    this.isPaid = false,
    this.paidAt,
    this.paymentReason,
    this.updatedAt,
  });

  factory OrderPricing.fromJson(Map<String, dynamic> json) {
    return OrderPricing(
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount'] ?? json['discountAmount']),
      deliveryFee: _parseDouble(json['deliveryFee']),
      taxAmount: _parseDouble(json['taxAmount'] ?? json['tax']),
      total: _parseDouble(json['total'] ?? json['totalAmount']),
      // ✅ NOUVEAU - Parsing des nouveaux champs
      manualPrice: json['manualPrice'] != null ? _parseDouble(json['manualPrice']) : null,
      originalPrice: json['originalPrice'] != null ? _parseDouble(json['originalPrice']) : null,
      discountPercentage: json['discountPercentage'] != null ? _parseDouble(json['discountPercentage']) : null,
      isPaid: json['isPaid'] ?? json['is_paid'] ?? false,
      paidAt: json['paidAt'] != null ? _parseDateTime(json['paidAt']) : null,
      paymentReason: json['paymentReason'] ?? json['reason'],
      updatedAt: json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'total': total,
      // ✅ NOUVEAU
      'manualPrice': manualPrice,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'isPaid': isPaid,
      'paidAt': paidAt?.toIso8601String(),
      'paymentReason': paymentReason,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Helper pour parser les nombres en double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper pour parser les dates
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Montant économisé
  double get savings => discount;

  /// Pourcentage de réduction (ancien calcul, conservé pour compatibilité)
  double get discountPercentageOld {
    if (subtotal == 0) return 0.0;
    return (discount / subtotal) * 100;
  }

  // ✅ NOUVEAU - Getters utiles pour la feature pricing

  /// Affiche le prix à payer (manuel si défini, sinon subtotal)
  double get displayPrice => manualPrice ?? subtotal;

  /// Vérifie si un prix manuel a été défini
  bool get hasManualPrice => manualPrice != null;

  /// Vérifie si c'est une réduction (prix manuel < prix original)
  bool get isReduction => manualPrice != null && manualPrice! < (originalPrice ?? subtotal);

  /// Vérifie si c'est une augmentation (prix manuel > prix original)
  bool get isIncrease => manualPrice != null && manualPrice! > (originalPrice ?? subtotal);

  /// Label pour afficher le type d'ajustement
  String get priceAdjustmentLabel {
    if (!hasManualPrice) return '';
    return isReduction ? 'Réduction appliquée' : 'Augmentation appliquée';
  }

  /// Icône pour afficher le type d'ajustement
  String get priceAdjustmentIcon {
    if (!hasManualPrice) return '';
    return isReduction ? '📉' : '📈';
  }

  /// Montant de l'ajustement (positif pour réduction, négatif pour augmentation)
  double get adjustmentAmount {
    if (!hasManualPrice) return 0.0;
    return (originalPrice ?? subtotal) - manualPrice!;
  }

  /// Pourcentage d'ajustement
  double get adjustmentPercentage {
    if (!hasManualPrice || (originalPrice ?? subtotal) == 0) return 0.0;
    return (adjustmentAmount / (originalPrice ?? subtotal)) * 100;
  }

  /// Statut de paiement formaté
  String get paymentStatusLabel => isPaid ? 'Payée' : 'Non payée';

  /// Icône de statut de paiement
  String get paymentStatusIcon => isPaid ? '✅' : '⏳';

  @override
  String toString() {
    return 'OrderPricing(subtotal: $subtotal, discount: $discount, total: $total, manualPrice: $manualPrice, isPaid: $isPaid)';
  }
}
