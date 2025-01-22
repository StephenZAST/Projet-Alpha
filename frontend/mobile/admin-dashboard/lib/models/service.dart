class Service {
  final String id;
  final String name;
  final double price;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
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
