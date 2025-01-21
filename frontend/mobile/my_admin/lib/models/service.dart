class Service {
  final String id;
  final String name;
  final String description;
  final double basePrice;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      basePrice: double.parse(json['basePrice'].toString()),
    );
  }
}
