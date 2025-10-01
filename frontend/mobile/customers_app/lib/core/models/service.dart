/// 🛠️ Modèle Service - Alpha Client App
///
/// Représente un service spécifique (Nettoyage à sec, Repassage, etc.)
/// lié à un type de service.
class Service {
  final String id;
  final String name;
  final String description;
  final String serviceTypeId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Informations enrichies du ServiceType
  final String? serviceTypeName;
  final String? serviceTypePricingType;
  final bool? serviceTypeRequiresWeight;
  final bool? serviceTypeSupportsPremium;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceTypeId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.serviceTypeName,
    this.serviceTypePricingType,
    this.serviceTypeRequiresWeight,
    this.serviceTypeSupportsPremium,
  });

  /// 📊 Conversion depuis JSON
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      serviceTypeId: json['service_type_id']?.toString() ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      // Informations enrichies
      serviceTypeName: json['service_type_name'],
      serviceTypePricingType: json['service_type_pricing_type'],
      serviceTypeRequiresWeight: json['service_type_requires_weight'],
      serviceTypeSupportsPremium: json['service_type_supports_premium'],
    );
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'service_type_id': serviceTypeId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// ⚖️ Vérifier si le service nécessite un poids
  bool get requiresWeight => serviceTypeRequiresWeight ?? false;

  /// 💎 Vérifier si le service supporte le premium
  bool get supportsPremium => serviceTypeSupportsPremium ?? false;

  /// 🏷️ Type de tarification
  String get pricingType => serviceTypePricingType ?? 'FIXED';

  /// 🔄 Copie avec modifications
  Service copyWith({
    String? id,
    String? name,
    String? description,
    String? serviceTypeId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serviceTypeName,
    String? serviceTypePricingType,
    bool? serviceTypeRequiresWeight,
    bool? serviceTypeSupportsPremium,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,
      serviceTypePricingType: serviceTypePricingType ?? this.serviceTypePricingType,
      serviceTypeRequiresWeight: serviceTypeRequiresWeight ?? this.serviceTypeRequiresWeight,
      serviceTypeSupportsPremium: serviceTypeSupportsPremium ?? this.serviceTypeSupportsPremium,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Service && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Service(id: $id, name: $name, serviceTypeId: $serviceTypeId)';
  }
}