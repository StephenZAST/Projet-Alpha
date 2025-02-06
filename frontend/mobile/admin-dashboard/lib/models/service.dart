class Service {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? typeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.typeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : (json['price'] as num).toDouble(),
      typeId: json['typeId']?.toString(),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'typeId': typeId,
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
