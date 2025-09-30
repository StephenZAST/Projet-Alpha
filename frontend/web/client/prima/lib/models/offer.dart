class Offer {
  final String id;
  final String name;
  final String? description;
  final String discountType; // 'PERCENTAGE' ou 'FIXED'
  final double discountValue;
  final double? minPurchaseAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? pointsRequired;
  final bool isActive;

  const Offer({
    required this.id,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minPurchaseAmount,
    this.startDate,
    this.endDate,
    this.pointsRequired,
    this.isActive = true,
  });

  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  // Getters for backward compatibility
  String get type => discountType;
  double get value => discountValue;

  // Calculate discount amount for a given price
  double get discountAmount => discountValue;

  double calculateDiscount(double amount) {
    if (!isValid) return 0;
    if (minPurchaseAmount != null && amount < minPurchaseAmount!) return 0;
    if (discountType == 'PERCENTAGE') {
      return (amount * discountValue) / 100;
    }
    return discountValue;
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      discountType: json['discountType'] ?? json['type'] ?? 'FIXED',
      discountValue: (json['discountValue'] ?? json['value'] ?? 0).toDouble(),
      minPurchaseAmount: json['minPurchaseAmount'] != null
          ? (json['minPurchaseAmount'] as num).toDouble()
          : null,
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      pointsRequired: json['pointsRequired'] != null
          ? (json['pointsRequired'] as num).toInt()
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchaseAmount': minPurchaseAmount,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'pointsRequired': pointsRequired,
      'isActive': isActive,
    };
  }
}
