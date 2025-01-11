import 'package:prima/widgets/order_bottom_sheet.dart';

class ArticleState {
  final List<ArticleCategory> categories;
  final Map<String, List<Article>> articlesByCategory;
  final bool isLoading;
  final String? error;

  ArticleState({
    this.categories = const [],
    this.articlesByCategory = const {},
    this.isLoading = false,
    this.error,
  });

  ArticleState copyWith({
    List<ArticleCategory>? categories,
    Map<String, List<Article>>? articlesByCategory,
    bool? isLoading,
    String? error,
  }) {
    return ArticleState(
      categories: categories ?? this.categories,
      articlesByCategory: articlesByCategory ?? this.articlesByCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
