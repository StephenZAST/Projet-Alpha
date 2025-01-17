class Offer {
  final String id;
  final String name;
  final String? description;
  final String discountType;
  final double discountValue;
  final double? minPurchaseAmount;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  const Offer({
    required this.id,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minPurchaseAmount,
    required this.isActive,
    this.startDate,
    this.endDate,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      discountType: json['discountType'],
      discountValue: (json['discountValue'] as num).toDouble(),
      minPurchaseAmount: json['minPurchaseAmount']?.toDouble(),
      isActive: json['isActive'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}
