/// 🎁 Modèle Offer - Alpha Client App
///
/// Représente une offre promotionnelle disponible pour les clients.
class Offer {
  final String id;
  final String name;
  final String? description;
  final String discountType; // PERCENTAGE, FIXED_AMOUNT, POINTS_EXCHANGE
  final double discountValue;
  final double? minPurchaseAmount;
  final double? maxDiscountAmount;
  final bool isCumulative;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? pointsRequired;
  final List<String>? articleIds; // Articles liés à l'offre
  final bool isSubscribed; // Si l'utilisateur est abonné

  Offer({
    required this.id,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minPurchaseAmount,
    this.maxDiscountAmount,
    this.isCumulative = false,
    this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.pointsRequired,
    this.articleIds,
    this.isSubscribed = false,
  });

  /// Vérifier si l'offre est valide (dates)
  bool get isValid {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return isActive;
  }

  /// Obtenir le label du type de réduction
  String get discountTypeLabel {
    switch (discountType.toUpperCase()) {
      case 'PERCENTAGE':
        return 'Pourcentage';
      case 'FIXED_AMOUNT':
        return 'Montant fixe';
      case 'POINTS_EXCHANGE':
        return 'Échange de points';
      default:
        return discountType;
    }
  }

  /// Obtenir le label de la réduction formaté
  String get discountLabel {
    switch (discountType.toUpperCase()) {
      case 'PERCENTAGE':
        return '-${discountValue.toStringAsFixed(0)}%';
      case 'FIXED_AMOUNT':
        return '-${discountValue.toStringAsFixed(2)}€';
      case 'POINTS_EXCHANGE':
        return '${discountValue.toStringAsFixed(0)} pts';
      default:
        return '${discountValue.toStringAsFixed(2)}';
    }
  }

  /// Convertir depuis JSON
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minPurchaseAmount: json['minPurchaseAmount'] != null
          ? (json['minPurchaseAmount'] as num).toDouble()
          : null,
      maxDiscountAmount: json['maxDiscountAmount'] != null
          ? (json['maxDiscountAmount'] as num).toDouble()
          : null,
      isCumulative: json['isCumulative'] as bool? ?? false,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pointsRequired: json['pointsRequired'] != null
          ? (json['pointsRequired'] as num).toDouble()
          : null,
      articleIds: json['articleIds'] != null
          ? List<String>.from(json['articleIds'] as List)
          : null,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchaseAmount': minPurchaseAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'isCumulative': isCumulative,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pointsRequired': pointsRequired,
      'articleIds': articleIds,
      'isSubscribed': isSubscribed,
    };
  }

  /// Copier avec modifications
  Offer copyWith({
    String? id,
    String? name,
    String? description,
    String? discountType,
    double? discountValue,
    double? minPurchaseAmount,
    double? maxDiscountAmount,
    bool? isCumulative,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? pointsRequired,
    List<String>? articleIds,
    bool? isSubscribed,
  }) {
    return Offer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minPurchaseAmount: minPurchaseAmount ?? this.minPurchaseAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      isCumulative: isCumulative ?? this.isCumulative,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      articleIds: articleIds ?? this.articleIds,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  @override
  String toString() => 'Offer(id: $id, name: $name, discount: $discountLabel)';
}
