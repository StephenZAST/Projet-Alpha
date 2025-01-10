class Address {
  final String id;
  final String userId; // Important pour la relation avec l'utilisateur
  final String name;
  final String? street; // Maintenant optionnel
  final String city;
  final String? postalCode; // Maintenant optionnel
  final double latitude; // Plus optionnel
  final double longitude; // Plus optionnel
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    this.street, // Optionnel
    required this.city,
    this.postalCode, // Optionnel
    required this.latitude, // Requis
    required this.longitude, // Requis
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      street: json['street'],
      city: json['city'],
      postalCode: json['postal_code'],
      latitude: json['gps_latitude'] ?? 0.0,
      longitude: json['gps_longitude'] ?? 0.0,
      isDefault: json['is_default'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'street': street,
      'city': city,
      'postal_code': postalCode,
      'gps_latitude': latitude,
      'gps_longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
