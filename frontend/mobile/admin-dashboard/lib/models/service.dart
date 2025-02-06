class Service {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? typeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ServiceType>? types;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.typeId,
    required this.createdAt,
    required this.updatedAt,
    this.types,
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
      types: json['types'] != null
          ? (json['types'] as List).map((t) => ServiceType.fromJson(t)).toList()
          : null,
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

class ServiceType {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  ServiceType({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
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
