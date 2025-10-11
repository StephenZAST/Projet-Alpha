import 'package:flutter/material.dart';
import '../core/models/article.dart';
import '../core/models/service.dart';
import '../core/models/service_type.dart';
import '../core/services/article_service.dart';
import '../core/services/service_service.dart';
import '../core/services/pricing_service.dart';
import '../core/services/category_service.dart' as cat;

/// 🛠️ Provider des Services - Alpha Client App
///
/// Gère l'état global des services, articles et tarifs
class ServicesProvider extends ChangeNotifier {
  final ArticleService _articleService = ArticleService();
  final ServiceService _serviceService = ServiceService();
  final PricingService _pricingService = PricingService();
  final cat.CategoryService _categoryService = cat.CategoryService();

  // État
  bool _isLoading = false;
  String? _error;

  // Données
  List<Article> _articles = [];
  List<Service> _services = [];
  List<ServiceType> _serviceTypes = [];
  List<ArticleServicePrice> _prices = [];
  List<cat.ArticleCategory> _categories = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Article> get articles => _articles;
  List<Service> get services => _services;
  List<ServiceType> get serviceTypes => _serviceTypes;
  List<ArticleServicePrice> get prices => _prices;
  List<cat.ArticleCategory> get categories => _categories;

  bool get hasData => _articles.isNotEmpty || _services.isNotEmpty;

  /// 🚀 Initialiser et charger toutes les données
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // 1. Charger les catégories d'abord
      await loadCategories();
      
      // 2. Charger les autres données en parallèle
      await Future.wait([
        loadArticles(),
        loadServices(),
        loadServiceTypes(),
        loadPrices(),
      ]);
      
      // 3. Enrichir les articles avec les noms de catégories
      _enrichArticlesWithCategoryNames();
    } catch (e) {
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 📦 Charger tous les articles
  Future<void> loadArticles() async {
    try {
      _articles = await _articleService.getAllArticles();
      notifyListeners();
    } catch (e) {
      debugPrint('[ServicesProvider] Erreur chargement articles: $e');
      // Ne pas bloquer si les articles ne se chargent pas
    }
  }

  /// 🛠️ Charger tous les services
  Future<void> loadServices() async {
    try {
      _services = await _serviceService.getAllServices();
      notifyListeners();
    } catch (e) {
      debugPrint('[ServicesProvider] Erreur chargement services: $e');
    }
  }

  /// 🏷️ Charger tous les types de service
  Future<void> loadServiceTypes() async {
    try {
      _serviceTypes = await _serviceService.getAllServiceTypes();
      notifyListeners();
    } catch (e) {
      debugPrint('[ServicesProvider] Erreur chargement types de service: $e');
    }
  }

  /// 💰 Charger tous les prix
  Future<void> loadPrices() async {
    try {
      _prices = await _pricingService.getAllPrices();
      notifyListeners();
    } catch (e) {
      debugPrint('[ServicesProvider] Erreur chargement prix: $e');
    }
  }

  /// 📂 Charger toutes les catégories
  Future<void> loadCategories() async {
    try {
      _categories = await _categoryService.getAllCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('[ServicesProvider] Erreur chargement catégories: $e');
    }
  }

  /// 🔗 Enrichir les articles avec les noms de catégories
  void _enrichArticlesWithCategoryNames() {
    for (var i = 0; i < _articles.length; i++) {
      final article = _articles[i];
      try {
        final category = _categories.firstWhere(
          (cat) => cat.id == article.categoryId,
        );
        // Utiliser copyWith pour créer un nouvel article avec le nom de catégorie
        _articles[i] = article.copyWith(
          categoryName: category.name,
          categoryDescription: category.description,
        );
      } catch (e) {
        // Catégorie non trouvée, garder l'article tel quel
        debugPrint('[ServicesProvider] Catégorie non trouvée pour article ${article.id}: ${article.categoryId}');
      }
    }
    notifyListeners();
  }

  /// 🔄 Rafraîchir toutes les données
  Future<void> refresh() async {
    await initialize();
  }

  /// 🔍 Rechercher des articles par nom
  List<Article> searchArticles(String query) {
    if (query.isEmpty) return _articles;
    
    final lowerQuery = query.toLowerCase();
    return _articles.where((article) {
      return article.name.toLowerCase().contains(lowerQuery) ||
          (article.description.toLowerCase().contains(lowerQuery)) ||
          (article.categoryName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// 🔍 Rechercher des services par nom
  List<Service> searchServices(String query) {
    if (query.isEmpty) return _services;
    
    final lowerQuery = query.toLowerCase();
    return _services.where((service) {
      return service.name.toLowerCase().contains(lowerQuery) ||
          service.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 📂 Obtenir les articles par catégorie
  List<Article> getArticlesByCategory(String categoryId) {
    return _articles.where((article) => article.categoryId == categoryId).toList();
  }

  /// 🏷️ Obtenir les services par type
  List<Service> getServicesByType(String serviceTypeId) {
    return _services.where((service) => service.serviceTypeId == serviceTypeId).toList();
  }

  /// 💵 Obtenir le prix pour un couple article-service-type
  ArticleServicePrice? getPrice({
    required String articleId,
    required String serviceId,
    required String serviceTypeId,
  }) {
    try {
      return _prices.firstWhere(
        (price) =>
            price.articleId == articleId &&
            price.serviceId == serviceId &&
            price.serviceTypeId == serviceTypeId &&
            price.isAvailable,
      );
    } catch (e) {
      return null;
    }
  }

  /// 💰 Calculer le prix total
  Future<double> calculatePrice({
    required String articleId,
    required String serviceId,
    required String serviceTypeId,
    bool isPremium = false,
    double? weight,
    int quantity = 1,
  }) async {
    try {
      final unitPrice = await _pricingService.calculatePrice(
        articleId: articleId,
        serviceId: serviceId,
        serviceTypeId: serviceTypeId,
        isPremium: isPremium,
        weight: weight,
      );
      return unitPrice * quantity;
    } catch (e) {
      debugPrint('[ServicesProvider] Erreur calcul prix: $e');
      return 0.0;
    }
  }

  /// 📊 Obtenir les statistiques
  Map<String, int> getStatistics() {
    return {
      'articles': _articles.length,
      'services': _services.length,
      'serviceTypes': _serviceTypes.length,
      'prices': _prices.length,
      'categories': _categories.length,
    };
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
