import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:prima/services/article_service.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';

class ArticleProvider extends ChangeNotifier {
  final ArticleService _articleService;
  List<Article> _articles = [];
  List<ArticleCategory> _categories =
      []; // Changed from Set<String> to List<ArticleCategory>
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

      final articlesResult = await _articleService.getArticles();
      _articles = articlesResult;

      // Extract unique categories from articles
      final Set<ArticleCategory> categorySet = {};
      for (var article in articlesResult) {
        if (article.category != null) {
          try {
            categorySet.add(ArticleCategory.fromJson(article.category!));
          } catch (e) {
            print('Error parsing category for article ${article.id}: $e');
          }
        }
      }
      _categories = categorySet.toList();

      print(
          'Loaded ${_articles.length} articles and ${_categories.length} categories');
      notifyListeners();
    } catch (e) {
      print('Error in loadData: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Article> getArticlesForCategory(String categoryId) {
    print('Getting articles for category: $categoryId');
    final articles =
        _articles.where((article) => article.categoryId == categoryId).toList();
    print('Found ${articles.length} articles for category $categoryId');
    return articles;
  }
}
