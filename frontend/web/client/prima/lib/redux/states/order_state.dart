import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';
import '../../models/service.dart';
import '../../models/order.dart';

class OrderState {
  final Service? selectedService;
  final Map<String, int> selectedArticles;
  final List<Article> articles;
  final List<ArticleCategory> articleCategories;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final bool isLoading;
  final String? error;
  final List<Order> orders;

  OrderState({
    this.selectedService,
    this.selectedArticles = const {},
    this.articles = const [],
    this.articleCategories = const [],
    this.collectionDate,
    this.deliveryDate,
    this.isLoading = false,
    this.error,
    this.orders = const [],
  });

  OrderState copyWith({
    Service? selectedService,
    Map<String, int>? selectedArticles,
    List<Article>? articles,
    List<ArticleCategory>? articleCategories,
    DateTime? collectionDate,
    DateTime? deliveryDate,
    bool? isLoading,
    String? error,
    List<Order>? orders, // Ajout du paramètre dans copyWith
  }) {
    return OrderState(
      selectedService: selectedService ?? this.selectedService,
      selectedArticles: selectedArticles ?? this.selectedArticles,
      articles: articles ?? this.articles,
      articleCategories: articleCategories ?? this.articleCategories,
      collectionDate: collectionDate ?? this.collectionDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      orders: orders ?? this.orders, // Copie de orders
    );
  }
}
