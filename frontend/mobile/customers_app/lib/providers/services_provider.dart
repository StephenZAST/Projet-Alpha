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
/// Gère l'état global des services, articles et tarifs avec système de cache
class ServicesProvider extends ChangeNotifier {
  final ArticleService _articleService = ArticleService();
  final ServiceService _serviceService = ServiceService();
  final PricingService _pricingService = PricingService();
  final cat.CategoryService _categoryService = cat.CategoryService();

  // État
  bool _isLoading = false;
  String? _error;

  // 🔥 Cache Management
  DateTime? _lastFetch;
  bool _isInitialized = false;
  static const Duration _cacheDuration = Duration(minutes: 10);

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
  
  // 🔥 Cache Getters
  bool get isInitialized => _isInitialized;
  DateTime? get lastFetch => _lastFetch;
  
  bool get _shouldRefresh {
    if (_lastFetch == null) return true;
    final difference = DateTime.now().difference(_lastFetch!);
    return difference > _cacheDuration;
  }
  
  String get cacheStatus {
    if (_lastFetch == null) return 'Aucune donnée';
    final difference = DateTime.now().difference(_lastFetch!);
    final minutes = difference.inMinutes;
    if (minutes < 1) return 'À l\'instant';
    if (minutes == 1) return 'Il y a 1 minute';
    return 'Il y a $minutes minutes';
  }

  /// 🚀 Initialiser et charger toutes les données
  Future<void> initialize({bool forceRefresh = false}) async {
    // 🔥 Vérifier le cache avant de charger
    if (_isInitialized && !forceRefresh && !_shouldRefresh && hasData) {
      debugPrint('✅ [ServicesProvider] Cache valide - Pas de rechargement');
      debugPrint('📊 [ServicesProvider] Dernière mise à jour: $cacheStatus');
      debugPrint('📦 [ServicesProvider] Données: ${_articles.length} articles, ${_services.length} services');
      return;
    }

    if (forceRefresh) {
      debugPrint('🔄 [ServicesProvider] Rechargement forcé');
    } else if (_shouldRefresh) {
      debugPrint('⏰ [ServicesProvider] Cache expiré - Rechargement');
    } else {
      debugPrint('🆕 [ServicesProvider] Première initialisation');
    }

    _setLoading(true);
    _clearError();

    try {
      final startTime = DateTime.now();
      
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
      
      // 🔥 Marquer comme initialisé et mettre à jour le timestamp
      _isInitialized = true;
      _lastFetch = DateTime.now();
      
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [ServicesProvider] Chargement terminé en ${duration.inMilliseconds}ms');
      debugPrint('📦 [ServicesProvider] ${_articles.length} articles, ${_services.length} services, ${_prices.length} prix');
      
    } catch (e) {
      debugPrint('❌ [ServicesProvider] Erreur: $e');
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 📦 Charger tous les articles
  Future<void> loadArticles() async {
    try {
      final startTime = DateTime.now();
      _articles = await _articleService.getAllArticles();
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Articles] ${_articles.length} articles chargés en ${duration.inMilliseconds}ms');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Articles] Erreur: $e');
      // Ne pas bloquer si les articles ne se chargent pas
      rethrow; // Propager l'erreur pour la gestion globale
    }
  }

  /// 🛠️ Charger tous les services
  Future<void> loadServices() async {
    try {
      final startTime = DateTime.now();
      _services = await _serviceService.getAllServices();
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Services] ${_services.length} services chargés en ${duration.inMilliseconds}ms');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Services] Erreur: $e');
      rethrow;
    }
  }

  /// 🏷️ Charger tous les types de service
  Future<void> loadServiceTypes() async {
    try {
      final startTime = DateTime.now();
      _serviceTypes = await _serviceService.getAllServiceTypes();
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [ServiceTypes] ${_serviceTypes.length} types chargés en ${duration.inMilliseconds}ms');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [ServiceTypes] Erreur: $e');
      rethrow;
    }
  }

  /// 💰 Charger tous les prix
  Future<void> loadPrices() async {
    try {
      final startTime = DateTime.now();
      _prices = await _pricingService.getAllPrices();
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Prices] ${_prices.length} prix chargés en ${duration.inMilliseconds}ms');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Prices] Erreur: $e');
      rethrow;
    }
  }

  /// 📂 Charger toutes les catégories
  Future<void> loadCategories() async {
    try {
      final startTime = DateTime.now();
      _categories = await _categoryService.getAllCategories();
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Categories] ${_categories.length} catégories chargées en ${duration.inMilliseconds}ms');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Categories] Erreur: $e');
      rethrow;
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

  /// 🔄 Rafraîchir toutes les données (force le rechargement)
  Future<void> refresh() async {
    debugPrint('🔄 [ServicesProvider] Rafraîchissement manuel');
    await initialize(forceRefresh: true);
  }
  
  /// 🗑️ Invalider le cache (pour forcer un rechargement au prochain accès)
  void invalidateCache() {
    debugPrint('🗑️ [ServicesProvider] Cache invalidé');
    _isInitialized = false;
    _lastFetch = null;
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
