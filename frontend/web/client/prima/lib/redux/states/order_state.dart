import 'dart:developer';
import 'package:prima/widgets/order_bottom_sheet.dart';

import '../../models/service.dart';

class OrderState {
  final Service? selectedService;
  final Map<String, int> selectedArticles;
  final List<Article> articles;
  final List<ArticleCategory> articleCategories;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final bool isLoading;
  final String? error;

  OrderState({
    this.selectedService,
    this.selectedArticles = const {},
    this.articles = const [],
    this.articleCategories = const [],
    this.collectionDate,
    this.deliveryDate,
    this.isLoading = false,
    this.error,
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
    );
  }
}
