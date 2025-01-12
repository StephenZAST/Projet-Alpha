import 'package:prima/widgets/order_bottom_sheet.dart';

class ArticleState {
  final List<ArticleCategory>? categories; // Rendre nullable
  final List<Article>? articles;
  final bool isLoading;
  final String? error;
  final Map<String, List<Article>>? articlesByCategory; // Rendre nullable

  ArticleState({
    this.categories, // Enlever la valeur par défaut
    this.articles,
    this.articlesByCategory,
    this.isLoading = false,
    this.error,
  });

  ArticleState copyWith({
    List<ArticleCategory>? categories,
    List<Article>? articles,
    Map<String, List<Article>>? articlesByCategory,
    bool? isLoading,
    String? error,
  }) {
    return ArticleState(
      categories: categories ?? this.categories,
      articles: articles ?? this.articles,
      articlesByCategory: articlesByCategory ?? this.articlesByCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
