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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
