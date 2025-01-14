import 'package:flutter/material.dart';
import 'package:prima/services/article_service.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';

class ArticleProvider extends ChangeNotifier {
  final ArticleService _articleService;
  List<Article> _articles = [];
  List<ArticleCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  ArticleProvider(this._articleService);

  List<Article> get articles => _articles;
  List<ArticleCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Article> getArticlesForCategory(String categoryId) {
    return _articles
        .where((article) => article.categoryId == categoryId)
        .toList();
  }

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final categoriesResult = await _articleService.getCategories();
      _categories = List<ArticleCategory>.from(categoriesResult);

      notifyListeners();
    } catch (e) {
      print('Error loading categories: $e');
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArticles() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final articlesResult = await _articleService.getArticlesByCategory('all');
      _articles = List<Article>.from(articlesResult);

      notifyListeners();
    } catch (e) {
      print('Error loading articles: $e');
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load categories first
      await loadCategories();
      // Then load articles if categories are not empty
      if (_categories.isNotEmpty) {
        await loadArticles();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArticlesForCategory(String categoryId) async {
    try {
      if (_articles.any((article) => article.categoryId == categoryId)) return;

      _isLoading = true;
      notifyListeners();

      final categoryArticles =
          await _articleService.getArticlesByCategory(categoryId);
      _articles.addAll(List<Article>.from(categoryArticles));

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
