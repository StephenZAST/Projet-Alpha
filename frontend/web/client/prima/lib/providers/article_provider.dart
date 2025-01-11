import 'package:flutter/material.dart';
import 'package:prima/services/article_service.dart';
import 'package:prima/widgets/order_bottom_sheet.dart';

class ArticleProvider extends ChangeNotifier {
  final ArticleService _articleService;
  List<ArticleCategory> _categories = [];
  Map<String, List<Article>> _articlesByCategory = {};
  bool _isLoading = false;
  String? _error;

  ArticleProvider(this._articleService);

  List<ArticleCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Article> getArticlesForCategory(String categoryId) {
    return _articlesByCategory[categoryId] ?? [];
  }

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await _articleService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArticlesForCategory(String categoryId) async {
    try {
      if (_articlesByCategory.containsKey(categoryId)) return;

      _isLoading = true;
      notifyListeners();

      final articles = await _articleService.getArticlesByCategory(categoryId);
      _articlesByCategory[categoryId] = articles;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
