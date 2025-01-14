import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:prima/services/article_service.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';

class ArticleProvider extends ChangeNotifier {
  final ArticleService _articleService;
  List<ArticleCategory> _categories = [];
  List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;

  ArticleProvider(this._articleService);

  List<Article> get articles => _articles;
  List<ArticleCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final categoriesResult = await _articleService.getCategories();
      final articlesResult = await _articleService.getArticlesByCategory('all');

      _categories = List<ArticleCategory>.from(categoriesResult);
      _articles = List<Article>.from(articlesResult);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading articles/categories: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Article> getArticlesForCategory(String categoryId) {
    return _articles
        .where((article) => article.categoryId == categoryId)
        .toList();
  }
}
