class Address {
  final String id;
  final String userId;
  final String name;
  final String street;
  final String city;
  final String postalCode;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    this.gpsLatitude,
    this.gpsLongitude,
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
      gpsLatitude: json['gps_latitude'],
      gpsLongitude: json['gps_longitude'],
      isDefault: json['is_default'] ?? false,
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
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullAddress => '$street, $city $postalCode';
}
