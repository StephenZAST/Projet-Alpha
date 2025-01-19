class ArticleCategory {
  final String id;
  final String name;
  final String? description;
  final int articlesCount;
  final bool isActive;

  ArticleCategory({
    required this.id,
    required this.name,
    this.description,
    this.articlesCount = 0,
    this.isActive = true,
  });
}
