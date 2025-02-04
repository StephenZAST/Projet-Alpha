class Service {
  final String id;
  final String name;
  final double? price;
  // Prix optionnel pour les services flash
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Service({
    required this.id,
    required this.name,
    this.price,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    try {
      // Conversion des timestamps avec gestion des formats snake_case
      DateTime parseTimestamp(String? value) {
        if (value == null) return DateTime.now();
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing timestamp: $e');
          return DateTime.now();
        }
      }

      return Service(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        price: json['price'] != null ? (json['price'] as num).toDouble() : null,
        description: json['description']?.toString(),
        createdAt: parseTimestamp(json['created_at'] ?? json['createdAt']),
        updatedAt: json['updated_at'] != null
            ? parseTimestamp(json['updated_at'])
            : (json['updatedAt'] != null
                ? parseTimestamp(json['updatedAt'])
                : null),
      );
    } catch (e, stackTrace) {
      print('Error parsing Service: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');

      // Retourner un service par défaut au lieu de propager l'erreur
      return Service(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Service inconnu',
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Service copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

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
