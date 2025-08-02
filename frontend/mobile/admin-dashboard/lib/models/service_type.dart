class ServiceType {
  final String id;
  final String name;
  final String? description;
  final bool? requiresWeight;
  final String? pricingType;
  final bool? isActive;
  final bool? supportsPremium;
  final bool? isDefault;

  ServiceType({
    required this.id,
    required this.name,
    this.description,
    this.requiresWeight,
    this.pricingType,
    this.isActive,
    this.supportsPremium,
    this.isDefault,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      requiresWeight: json['requires_weight'] as bool?,
      pricingType: json['pricing_type']?.toString(),
      isActive: json['is_active'] as bool?,
      supportsPremium: json['supports_premium'] as bool?,
      isDefault: json['is_default'] as bool?,
    );
  }
}
