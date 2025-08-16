class Service {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? serviceTypeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.serviceTypeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    try {
      return Service(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        price: (json['price'] ?? 0.0).toDouble(),
        description: json['description'],
        serviceTypeId: json['service_type_id']?.toString(),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
    } catch (e) {
      print('Error parsing Service: $e');
      rethrow;
    }
  }
}
