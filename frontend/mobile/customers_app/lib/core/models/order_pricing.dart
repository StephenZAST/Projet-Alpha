/// 💰 Modèle de Tarification de Commande - Alpha Client App
///
/// Représente le calcul de prix d'une commande avec réductions
class OrderPricing {
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double taxAmount;
  final double total;

  OrderPricing({
    required this.subtotal,
    required this.discount,
    this.deliveryFee = 0.0,
    this.taxAmount = 0.0,
    required this.total,
  });

  factory OrderPricing.fromJson(Map<String, dynamic> json) {
    return OrderPricing(
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount'] ?? json['discountAmount']),
      deliveryFee: _parseDouble(json['deliveryFee']),
      taxAmount: _parseDouble(json['taxAmount'] ?? json['tax']),
      total: _parseDouble(json['total'] ?? json['totalAmount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'total': total,
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

  /// Montant économisé
  double get savings => discount;

  /// Pourcentage de réduction
  double get discountPercentage {
    if (subtotal == 0) return 0.0;
    return (discount / subtotal) * 100;
  }

  @override
  String toString() {
    return 'OrderPricing(subtotal: $subtotal, discount: $discount, total: $total)';
  }
}
