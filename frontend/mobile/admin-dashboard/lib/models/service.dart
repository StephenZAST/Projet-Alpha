class Service {
  final String id;
  final String name;
  final double basePrice;
  final String description;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.description,
    this.isActive = true,
  });
}
