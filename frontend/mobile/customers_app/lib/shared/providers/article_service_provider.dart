import 'package:flutter/material.dart';
import '../../core/models/article_service_price.dart';
import '../../core/models/service_type.dart';
import '../../core/models/service.dart';
import '../../core/models/article.dart';
import '../../core/services/article_service_price_service.dart';

/// 🔗 Provider Article-Service - Alpha Client App
///
/// Gère l'état du workflow de sélection :
/// ServiceType → Service → ArticleServicePrice avec prix basic/premium
class ArticleServiceProvider extends ChangeNotifier {
  final ArticleServicePriceService _service = ArticleServicePriceService();

  // États de chargement
  bool _isLoading = false;
  bool _isLoadingServices = false;
  bool _isLoadingCouples = false;
  String? _error;

  // Données
  List<ServiceType> _serviceTypes = [];
  List<Service> _services = [];
  List<ArticleServicePrice> _couples = [];
  List<Article> _articles = [];

  // Sélections actuelles
  ServiceType? _selectedServiceType;
  Service? _selectedService;
  bool _isPremium = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingServices => _isLoadingServices;
  bool get isLoadingCouples => _isLoadingCouples;
  String? get error => _error;
  
  List<ServiceType> get serviceTypes => _serviceTypes;
  List<Service> get services => _services;
  List<ArticleServicePrice> get couples => _couples;
  List<Article> get articles => _articles;
  
  ServiceType? get selectedServiceType => _selectedServiceType;
  Service? get selectedService => _selectedService;
  bool get isPremium => _isPremium;

  // Getters calculés
  bool get hasServiceTypeSelected => _selectedServiceType != null;
  bool get hasServiceSelected => _selectedService != null;
  bool get canSelectCouples => hasServiceSelected && _couples.isNotEmpty;
  
  List<ArticleServicePrice> get availableCouples => 
      _couples.where((couple) => couple.isAvailable).toList();
  
  List<ArticleServicePrice> get premiumSupportedCouples => 
      availableCouples.where((couple) => couple.supportsPremium).toList();

  /// 🚀 Initialisation
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await Future.wait([
        loadServiceTypes(),
        loadArticles(),
      ]);
      
      _clearError();
    } catch (e) {
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 🏷️ Charger les types de service
  Future<void> loadServiceTypes() async {
    try {
      _serviceTypes = await _service.getServiceTypes();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des types de service: ${e.toString()}');
    }
  }

  /// 🛠️ Charger les services par type
  Future<void> loadServicesByType(String serviceTypeId) async {
    _setLoadingServices(true);
    
    try {
      _services = await _service.getServicesByType(serviceTypeId);
      
      // Reset des sélections suivantes
      _selectedService = null;
      _couples.clear();
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des services: ${e.toString()}');
    } finally {
      _setLoadingServices(false);
    }
  }

  /// 🔗 Charger les couples article-service
  Future<void> loadCouples() async {
    if (_selectedService == null) return;
    
    _setLoadingCouples(true);
    
    try {
      _couples = await _service.getArticleServiceCouples(
        serviceTypeId: _selectedServiceType?.id,
        serviceId: _selectedService?.id,
      );
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des couples: ${e.toString()}');
    } finally {
      _setLoadingCouples(false);
    }
  }

  /// 📦 Charger les articles
  Future<void> loadArticles() async {
    try {
      _articles = await _service.getArticles();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des articles: ${e.toString()}');
    }
  }

  /// 🎯 Sélectionner un type de service
  Future<void> selectServiceType(ServiceType serviceType) async {
    _selectedServiceType = serviceType;
    
    // Reset des sélections suivantes
    _selectedService = null;
    _services.clear();
    _couples.clear();
    
    notifyListeners();
    
    // Charger les services compatibles
    await loadServicesByType(serviceType.id);
  }

  /// 🛠️ Sélectionner un service
  Future<void> selectService(Service service) async {
    _selectedService = service;
    notifyListeners();
    
    // Charger les couples disponibles
    await loadCouples();
  }

  /// 💎 Basculer le mode premium
  void togglePremium() {
    _isPremium = !_isPremium;
    notifyListeners();
  }

  /// 💎 Définir le mode premium
  void setPremium(bool isPremium) {
    _isPremium = isPremium;
    notifyListeners();
  }

  /// 💰 Obtenir le prix d'un couple
  double getCouplePrice(ArticleServicePrice couple, {double? weight, int quantity = 1}) {
    final unitPrice = couple.getPrice(isPremium: _isPremium, weight: weight);
    return unitPrice * quantity;
  }

  /// 🧮 Calculer le prix total d'une liste d'items
  double calculateTotalPrice(List<CartItem> items) {
    double total = 0.0;
    
    for (final item in items) {
      final couple = _couples.firstWhere(
        (c) => c.id == item.coupleId,
        orElse: () => throw Exception('Couple non trouvé'),
      );
      
      total += getCouplePrice(couple, weight: item.weight, quantity: item.quantity);
    }
    
    return total;
  }

  /// 🔍 Rechercher des couples par nom d'article
  List<ArticleServicePrice> searchCouples(String query) {
    if (query.isEmpty) return availableCouples;
    
    final lowerQuery = query.toLowerCase();
    return availableCouples.where((couple) =>
        couple.articleName?.toLowerCase().contains(lowerQuery) == true ||
        couple.serviceName?.toLowerCase().contains(lowerQuery) == true
    ).toList();
  }

  /// 📊 Obtenir les statistiques des couples
  CoupleStats get stats {
    return CoupleStats(
      totalCouples: _couples.length,
      availableCouples: availableCouples.length,
      premiumSupportedCouples: premiumSupportedCouples.length,
      fixedPriceCouples: _couples.where((c) => c.pricingType == PricingType.fixed).length,
      weightBasedCouples: _couples.where((c) => c.pricingType == PricingType.weightBased).length,
    );
  }

  /// 🔄 Réinitialiser les sélections
  void resetSelections() {
    _selectedServiceType = null;
    _selectedService = null;
    _services.clear();
    _couples.clear();
    _isPremium = false;
    _clearError();
    notifyListeners();
  }

  /// 🔧 Méthodes utilitaires privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingServices(bool loading) {
    _isLoadingServices = loading;
    notifyListeners();
  }

  void _setLoadingCouples(bool loading) {
    _isLoadingCouples = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// 🧹 Nettoyage des ressources
  @override
  void dispose() {
    super.dispose();
  }
}

/// 📊 Statistiques des couples
class CoupleStats {
  final int totalCouples;
  final int availableCouples;
  final int premiumSupportedCouples;
  final int fixedPriceCouples;
  final int weightBasedCouples;

  CoupleStats({
    required this.totalCouples,
    required this.availableCouples,
    required this.premiumSupportedCouples,
    required this.fixedPriceCouples,
    required this.weightBasedCouples,
  });
}

/// 🛒 Item de panier pour le calcul de prix
class CartItem {
  final String coupleId;
  final int quantity;
  final double? weight;

  CartItem({
    required this.coupleId,
    required this.quantity,
    this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'coupleId': coupleId,
      'quantity': quantity,
      'weight': weight,
    };
  }
}