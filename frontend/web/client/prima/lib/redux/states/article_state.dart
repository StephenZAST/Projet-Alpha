import 'package:prima/widgets/order_bottom_sheet.dart' as widgets;
import '../../models/article.dart';
import '../../models/article_category.dart';

class ArticleState {
  final List<ArticleCategory> categories; // Non-nullable avec valeur par défaut
  final List<Article> articles;
  final bool isLoading;
  final String? error;
  final Map<String, List<Article>>
      articlesByCategory; // Non-nullable avec valeur par défaut

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
