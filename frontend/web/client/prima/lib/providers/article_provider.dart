import 'package:flutter/material.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';
import 'package:prima/models/service.dart';
import 'package:prima/services/article_service.dart';

class ArticleProvider extends ChangeNotifier {
  final ArticleService _articleService;
  List<ArticleCategory> _categories = [];
  Map<String, List<Article>> _articlesByCategory = {};
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  ArticleProvider(this._articleService);

  // Getters
  List<ArticleCategory> get categories => _categories;
  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Méthodes pour obtenir les articles
  List<Article> getArticlesForCategory(String categoryId) {
    return _articlesByCategory[categoryId] ?? [];
  }

  Article? findArticleById(String id) {
    for (var articles in _articlesByCategory.values) {
      try {
        return articles.firstWhere((article) => article.id == id);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // Chargement des services
  Future<void> loadServices() async {
    try {
      print('Starting to load services...');
      _setLoading(true);
      final fetchedServices = await _articleService.getServices();
      print('Fetched ${fetchedServices.length} services');

      // Remplacer setState par une mise à jour directe
      _services = fetchedServices;
      notifyListeners(); // Notifier directement ici
    } catch (e) {
      print('Error loading services: $e');
      _setError('Erreur lors du chargement des services: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Chargement des catégories
  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      _categories = await _articleService.getCategories();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des catégories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Chargement des articles par catégorie
  Future<void> loadArticlesForCategory(String categoryId) async {
    try {
      if (_articlesByCategory.containsKey(categoryId)) return;

      _setLoading(true);
      final articles = await _articleService.getArticlesByCategory(categoryId);
      _articlesByCategory[categoryId] = articles;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des articles: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Méthodes utilitaires
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Méthode pour réinitialiser l'état
  void reset() {
    _categories = [];
    _articlesByCategory = {};
    _services = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
