import 'package:admin/utils/parser_utils.dart';

class Address {
  final String id;
  final String? name;
  final String city;
  final String street;
  final String userId;
  final bool isDefault;
  final String? postalCode;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    this.name,
    required this.city,
    required this.street,
    required this.userId,
    required this.isDefault,
    this.postalCode,
    this.gpsLatitude,
    this.gpsLongitude,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullAddress =>
      '$street, $city${postalCode != null ? ' $postalCode' : ''}';

  factory Address.fromJson(Map<String, dynamic> json) {
    try {
      return Address(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString(),
        city: json['city']?.toString() ?? '',
        street: json['street']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
        isDefault:
            ParserUtils.safeBool(json['is_default'] ?? json['isDefault']),
        postalCode:
            json['postal_code']?.toString() ?? json['postalCode']?.toString(),
        gpsLatitude:
            ParserUtils.safeDouble(json['gps_latitude'] ?? json['gpsLatitude']),
        gpsLongitude: ParserUtils.safeDouble(
            json['gps_longitude'] ?? json['gpsLongitude']),
        createdAt: ParserUtils.parseDateTime(
                json['created_at'] ?? json['createdAt']) ??
            DateTime.now(),
        updatedAt: ParserUtils.parseDateTime(
                json['updated_at'] ?? json['updatedAt']) ??
            DateTime.now(),
      );
    } catch (e) {
      print('[Address] Error parsing from JSON: $e');
      print('[Address] Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'street': street,
        'user_id': userId,
        'is_default': isDefault,
        'postal_code': postalCode,
        'gps_latitude': gpsLatitude,
        'gps_longitude': gpsLongitude,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Address copyWith({
    String? id,
    String? name,
    String? city,
    String? street,
    String? userId,
    bool? isDefault,
    String? postalCode,
    double? gpsLatitude,
    double? gpsLongitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      street: street ?? this.street,
      userId: userId ?? this.userId,
      isDefault: isDefault ?? this.isDefault,
      postalCode: postalCode ?? this.postalCode,
      gpsLatitude: gpsLatitude ?? this.gpsLatitude,
      gpsLongitude: gpsLongitude ?? this.gpsLongitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
