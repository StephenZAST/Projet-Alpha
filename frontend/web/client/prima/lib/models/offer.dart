class Offer {
  final String id;
  final String name;
  final String? description;
  final String type; // 'PERCENTAGE' ou 'FIXED'
  final double value;
  final DateTime? expiryDate;
  final bool isActive;

  const Offer({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.value,
    this.expiryDate,
    this.isActive = true,
  });

  bool get isValid =>
      isActive && (expiryDate == null || expiryDate!.isAfter(DateTime.now()));

  double calculateDiscount(double amount) {
    if (!isValid) return 0;
    if (type == 'PERCENTAGE') {
      return (amount * value) / 100;
    }
    return value;
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }
}
