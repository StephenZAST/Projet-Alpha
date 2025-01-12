import 'package:prima/widgets/order_bottom_sheet.dart';

class ArticleState {
  final List<ArticleCategory> categories;
  final List<Article> articles;
  final bool isLoading;
  final String? error;
  final Map<String, List<Article>> articlesByCategory;

  ArticleState({
    this.categories = const [],
    this.articles = const [],
    this.articlesByCategory = const {},
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
