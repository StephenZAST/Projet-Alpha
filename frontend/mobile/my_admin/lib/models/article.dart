class Article {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String? imageUrl;
  final bool isActive;

  Article({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    this.isActive = true,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      categoryId: json['categoryId'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'],
    );
  }
}
