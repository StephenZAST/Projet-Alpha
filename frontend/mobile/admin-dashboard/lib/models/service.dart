class Service {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? serviceTypeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.serviceTypeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    try {
      return Service(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        price: _parsePrice(json['price']) ?? 0.0,
        serviceTypeId: json['service_type_id']?.toString(),
        createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ??
            DateTime.now(),
        updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']) ??
            DateTime.now(),
      );
    } catch (e) {
      print('Error parsing Service: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  static double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'service_type_id': serviceTypeId,
    };
  }
}

// Supprimer la définition en double de ServiceType ici
// et utiliser celle de service_type.dart

class ServiceCreateDTO {
  final String name;
  final double price;
  final String? description;

  ServiceCreateDTO({
    required this.name,
    required this.price,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
    };
  }
}

class ServiceUpdateDTO {
  final String? name;
  final double? price;
  final String? description;

  ServiceUpdateDTO({
    this.name,
    this.price,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (description != null) 'description': description,
    };
  }
}
