import 'dart:developer';
import 'package:prima/models/order.dart';
import 'package:prima/widgets/order_bottom_sheet.dart' as bottom_sheet;
import '../../models/service.dart';
import '../../models/article.dart';
import '../../models/article_category.dart';

class OrderState {
  final Service? selectedService;
  final Map<String, int> selectedArticles;
  final List<Article> articles;
  final List<ArticleCategory> articleCategories;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final bool isLoading;
  final String? error;
  final List<Order> orders; // Nouvelle propriété

  OrderState({
    this.selectedService,
    this.selectedArticles = const {},
    this.articles = const [],
    this.articleCategories = const [],
    this.collectionDate,
    this.deliveryDate,
    this.isLoading = false,
    this.error,
    this.orders = const [], // Initialisation par défaut
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
    List<Order>? orders,
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
      orders: orders ?? this.orders,
    );
  }
}
