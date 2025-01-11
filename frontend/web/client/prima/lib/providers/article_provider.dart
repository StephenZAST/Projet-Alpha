import 'package:flutter/material.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';
import 'package:prima/models/service.dart';
import 'package:prima/services/article_service.dart';

class ArticleProvider extends ChangeNotifier {
  final ArticleService _articleService;
  bool _isLoading = false;
  String? _error;
  List<Service> _services = [];
  List<ArticleCategory> _categories = [];
  Map<String, List<Article>> _articlesByCategory = {};

  ArticleProvider(this._articleService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Service> get services => _services;
  List<ArticleCategory> get categories => _categories;

  Future<void> loadServices() async {
    if (_isLoading) return;

    try {
      print('Starting loadServices...');
      _setLoading(true);

      final fetchedServices = await _articleService.getServices();

      if (fetchedServices.isNotEmpty) {
        _services = fetchedServices;
        _error = null;
        print('Services loaded successfully: ${_services.length}');
      } else {
        _error = 'Aucun service disponible';
        print('No services found');
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading services: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Ajouter cette méthode pour debug
  void printServicesState() {
    print('Current services state:');
    print('isLoading: $_isLoading');
    print('error: $_error');
    print('services count: ${_services.length}');
    for (var service in _services) {
      print('Service: ${service.name}');
    }
  }

  // Ajouter une méthode pour vérifier si les services sont chargés
  bool get hasServices => _services.isNotEmpty;

  // Ajouter une méthode pour obtenir un service par ID
  Service? getServiceById(String id) {
    return _services.firstWhere((s) => s.id == id,
        orElse: () => null as Service);
  }

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
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
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
