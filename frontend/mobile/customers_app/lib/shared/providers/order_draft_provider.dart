import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/order_draft.dart';
import '../../core/models/address.dart';
import '../../core/models/service_type.dart';
import '../../core/models/service.dart';
import '../../core/models/article.dart';
import '../../core/services/address_service.dart';
import '../../core/services/service_type_service.dart';
import '../../core/services/service_service.dart';
import '../../core/services/article_service.dart';
import '../../core/services/pricing_service.dart';
import '../../core/services/order_service.dart';
import '../utils/notification_utils.dart';
import 'auth_provider.dart';

/// 🔄 Provider Order Draft - Alpha Client App
///
/// Gère l'état du stepper de création de commande complète.
/// Workflow : Adresse → Service → Articles → Informations → Résumé
class OrderDraftProvider extends ChangeNotifier {
  // État du draft
  OrderDraft _orderDraft = OrderDraft();
  OrderDraft get orderDraft => _orderDraft;

  // État du stepper
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // États de chargement
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  // Données pour les étapes
  List<Address> _addresses = [];
  List<ServiceType> _serviceTypes = [];
  List<Service> _services = [];
  List<Article> _articles = [];
  List<ArticleServicePrice> _couples = []; // Couples article-service-price disponibles
  Map<String, double> _priceCache = {}; // Cache des prix (clé: articleId-serviceTypeId-serviceId-isPremium)

  List<Address> get addresses => _addresses;
  List<ServiceType> get serviceTypes => _serviceTypes;
  List<Service> get services => _services;
  List<Article> get articles => _articles;
  List<ArticleServicePrice> get couples => _couples; // Getter pour les couples

  // Sélections actuelles
  Address? _selectedAddress;
  ServiceType? _selectedServiceType;
  Service? _selectedService;
  bool _isPremium = false;

  Address? get selectedAddress => _selectedAddress;
  ServiceType? get selectedServiceType => _selectedServiceType;
  Service? get selectedService => _selectedService;
  bool get isPremium => _isPremium;

  // Getters calculés
  bool get canGoToNextStep {
    switch (_currentStep) {
      case 0: // Adresse
        return _selectedAddress != null;
      case 1: // Service
        return _selectedService != null && _selectedServiceType != null;
      case 2: // Articles
        return _orderDraft.items.isNotEmpty;
      case 3: // Informations
        return true; // Optionnel
      case 4: // Résumé
        return _orderDraft.isValid;
      default:
        return false;
    }
  }

  bool get canGoToPreviousStep => _currentStep > 0;

  /// 🚀 Initialisation
  Future<void> initialize() async {
    _setLoading(true);

    try {
      await Future.wait([
        _loadAddresses(),
        _loadServiceTypes(),
      ]);

      _clearError();
    } catch (e) {
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 📍 Charger les adresses de l'utilisateur
  Future<void> _loadAddresses() async {
    try {
      final addressList = await AddressService().getAllAddresses();
      _addresses = addressList.addresses;

      // Sélectionner l'adresse par défaut si disponible (sans dépendre d'extensions)
      Address? defaultAddress;
      for (final a in _addresses) {
        if (a.isDefault) {
          defaultAddress = a;
          break;
        }
      }
      if (defaultAddress == null && _addresses.isNotEmpty) {
        // fallback: use first address if none marked as default
        defaultAddress = _addresses.first;
      }
      if (defaultAddress != null) {
        selectAddress(defaultAddress);
      }

      notifyListeners();
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement des adresses: ${e.toString()}');
    }
  }

  /// 🏷️ Charger les types de service
  Future<void> _loadServiceTypes() async {
    try {
      debugPrint('🔍 [OrderDraftProvider] Loading service types from API...');
      _serviceTypes = await ServiceTypeService().getAllServiceTypes();
      debugPrint('✅ [OrderDraftProvider] Loaded ${_serviceTypes.length} service types');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [OrderDraftProvider] Error loading service types: $e');
      throw Exception(
          'Erreur lors du chargement des types de service: ${e.toString()}');
    }
  }

  /// 🛠️ Charger les services par type
  Future<void> _loadServicesByType(String serviceTypeId) async {
    try {
      debugPrint('🔍 [OrderDraftProvider] Loading services for type: $serviceTypeId');
      _services = await ServiceService().getServicesByType(serviceTypeId);
      debugPrint('✅ [OrderDraftProvider] Loaded ${_services.length} services');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [OrderDraftProvider] Error loading services: $e');
      throw Exception(
          'Erreur lors du chargement des services: ${e.toString()}');
    }
  }

  /// 📦 Charger les articles disponibles
  Future<void> _loadArticles() async {
    try {
      debugPrint('🔍 [OrderDraftProvider] Loading articles from API...');
      _articles = await ArticleService().getAllArticles(onlyActive: true);
      debugPrint('✅ [OrderDraftProvider] Loaded ${_articles.length} articles');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [OrderDraftProvider] Error loading articles: $e');
      throw Exception(
          'Erreur lors du chargement des articles: ${e.toString()}');
    }
  }

  /// 🎯 Sélectionner une adresse
  void selectAddress(Address address) {
    _selectedAddress = address;
    _orderDraft.addressId = address.id;
    notifyListeners();
  }

  /// 🏷️ Sélectionner un type de service
  Future<void> selectServiceType(ServiceType serviceType) async {
    _selectedServiceType = serviceType;
    _orderDraft.serviceTypeId = serviceType.id;

    // Reset des sélections suivantes
    _selectedService = null;
    _orderDraft.serviceId = null;
    _services.clear();

    notifyListeners();

    // Charger les services compatibles
    await _loadServicesByType(serviceType.id);
  }

  /// 🛠️ Sélectionner un service
  Future<void> selectService(Service service) async {
    _selectedService = service;
    _orderDraft.serviceId = service.id;

    notifyListeners();

    // Charger les couples article-service-price disponibles
    await _loadCouples();
  }

  /// 💰 Charger les couples article-service-price
  Future<void> _loadCouples() async {
    if (_selectedService == null || _selectedServiceType == null) {
      return;
    }

    try {
      debugPrint('🔍 [OrderDraftProvider] Loading couples for service: ${_selectedService!.id}, type: ${_selectedServiceType!.id}');
      
      // Récupérer tous les prix disponibles pour ce couple service/serviceType
      final allPrices = await PricingService().getAllPrices();
      
      // Filtrer les couples pour le service et serviceType sélectionnés
      _couples = allPrices.where((price) {
        return price.serviceId == _selectedService!.id &&
               price.serviceTypeId == _selectedServiceType!.id &&
               price.isAvailable;
      }).toList();
      
      debugPrint('✅ [OrderDraftProvider] Loaded ${_couples.length} couples');
      
      // Mettre en cache les prix
      for (final couple in _couples) {
        final baseCacheKey = '${couple.articleId}-${couple.serviceTypeId}-${couple.serviceId}-false';
        final premiumCacheKey = '${couple.articleId}-${couple.serviceTypeId}-${couple.serviceId}-true';
        
        _priceCache[baseCacheKey] = couple.basePrice;
        if (couple.premiumPrice != null) {
          _priceCache[premiumCacheKey] = couple.premiumPrice!;
        }
      }
      
      debugPrint('✅ [OrderDraftProvider] Cached ${_priceCache.length} prices');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [OrderDraftProvider] Error loading couples: $e');
      throw Exception('Erreur lors du chargement des articles: ${e.toString()}');
    }
  }

  /// 💎 Basculer le mode premium
  void togglePremium() {
    _isPremium = !_isPremium;
    notifyListeners();
  }

  /// 📦 Ajouter un article au draft
  void addArticle(Article article, int quantity, {double? weight}) {
    // Vérifier si l'article existe déjà avec le même mode premium
    final existingIndex = _orderDraft.items.indexWhere(
      (item) => item.articleId == article.id && item.isPremium == _isPremium,
    );

    final basePrice = _getArticlePrice(article.id, false);
    final premiumPrice = _getArticlePrice(article.id, true);

    if (existingIndex != -1) {
      // Mettre à jour la quantité
      final existingItem = _orderDraft.items[existingIndex];
      _orderDraft.items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Ajouter un nouvel item
      _orderDraft.items.add(OrderDraftItem(
        articleId: article.id,
        articleName: article.name,
        articleDescription: article.description,
        quantity: quantity,
        isPremium: _isPremium,
        basePrice: basePrice,
        premiumPrice: premiumPrice,
        weight: weight,
        serviceId: _selectedService?.id,
      ));
    }

    notifyListeners();
  }

  /// 📦 Mettre à jour la quantité d'un article
  void updateArticleQuantity(
      String articleId, bool isPremium, int newQuantity) {
    final index = _orderDraft.items.indexWhere(
      (item) => item.articleId == articleId && item.isPremium == isPremium,
    );

    if (index != -1) {
      if (newQuantity <= 0) {
        _orderDraft.items.removeAt(index);
      } else {
        _orderDraft.items[index] = _orderDraft.items[index].copyWith(
          quantity: newQuantity,
        );
      }
      notifyListeners();
    }
  }

  /// 📦 Supprimer un article du draft
  void removeArticle(String articleId, bool isPremium) {
    _orderDraft.items.removeWhere(
      (item) => item.articleId == articleId && item.isPremium == isPremium,
    );
    notifyListeners();
  }

  /// 💰 Obtenir le prix d'un article depuis le cache ou l'API
  /// ⚠️ IMPORTANT: Utilise le TRIO (article_id, service_type_id, service_id)
  Future<double> _getArticlePriceAsync(String articleId, bool isPremium) async {
    if (_selectedService == null || _selectedServiceType == null) {
      debugPrint('⚠️ [OrderDraftProvider] Cannot get price: service or serviceType not selected');
      return 0.0;
    }

    // Clé de cache
    final cacheKey = '$articleId-${_selectedServiceType!.id}-${_selectedService!.id}-$isPremium';

    // Vérifier le cache
    if (_priceCache.containsKey(cacheKey)) {
      debugPrint('💾 [OrderDraftProvider] Price from cache: $cacheKey = ${_priceCache[cacheKey]}');
      return _priceCache[cacheKey]!;
    }

    try {
      debugPrint('🔍 [OrderDraftProvider] Fetching price for: $cacheKey');
      final priceData = await PricingService().getPrice(
        articleId: articleId,
        serviceTypeId: _selectedServiceType!.id,
        serviceId: _selectedService!.id,
      );

      if (priceData == null) {
        debugPrint('❌ [OrderDraftProvider] No price found for: $cacheKey');
        return 0.0;
      }

      final price = isPremium ? (priceData.premiumPrice ?? 0.0) : priceData.basePrice;
      
      // Mettre en cache
      _priceCache[cacheKey] = price;
      debugPrint('✅ [OrderDraftProvider] Price fetched and cached: $cacheKey = $price');
      
      return price;
    } catch (e) {
      debugPrint('❌ [OrderDraftProvider] Error fetching price: $e');
      return 0.0;
    }
  }

  /// 💰 Obtenir le prix d'un article (synchrone, utilise le cache)
  /// Pour la compatibilité avec le code existant
  double _getArticlePrice(String articleId, bool isPremium) {
    if (_selectedService == null || _selectedServiceType == null) {
      return 0.0;
    }

    final cacheKey = '$articleId-${_selectedServiceType!.id}-${_selectedService!.id}-$isPremium';
    return _priceCache[cacheKey] ?? 0.0;
  }

  /// 💰 Obtenir le prix d'un article (méthode publique asynchrone)
  Future<double> getArticlePriceAsync(String articleId, bool isPremium) async {
    return await _getArticlePriceAsync(articleId, isPremium);
  }

  /// 💰 Obtenir le prix d'un article (méthode publique synchrone depuis le cache)
  double getArticlePrice(String articleId, bool isPremium) {
    return _getArticlePrice(articleId, isPremium);
  }

  /// 🔄 Pré-charger les prix pour tous les articles
  Future<void> _preloadPrices() async {
    if (_selectedService == null || _selectedServiceType == null || _articles.isEmpty) {
      return;
    }

    debugPrint('🔄 [OrderDraftProvider] Preloading prices for ${_articles.length} articles...');
    
    try {
      // Charger les prix pour chaque article (base et premium)
      for (final article in _articles) {
        // Prix base
        await _getArticlePriceAsync(article.id, false);
        
        // Prix premium si supporté
        if (_selectedServiceType!.supportsPremium) {
          await _getArticlePriceAsync(article.id, true);
        }
      }
      
      debugPrint('✅ [OrderDraftProvider] Preloaded ${_priceCache.length} prices');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [OrderDraftProvider] Error preloading prices: $e');
    }
  }

  /// ➡️ Aller à l'étape suivante
  Future<void> nextStep() async {
    if (!canGoToNextStep) return;

    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// ⬅️ Aller à l'étape précédente
  void previousStep() {
    if (canGoToPreviousStep) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// 🎯 Aller à une étape spécifique
  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      _currentStep = step;
      notifyListeners();
    }
  }

  /// 📤 Soumettre la commande
  Future<bool> submitOrder(BuildContext context) async {
    if (!_orderDraft.isValid) {
      _setError('Commande invalide');
      return false;
    }

    // Vérifier que tous les éléments nécessaires sont présents
    if (_selectedAddress == null) {
      _setError('Veuillez sélectionner une adresse');
      return false;
    }

    if (_selectedService == null || _selectedServiceType == null) {
      _setError('Veuillez sélectionner un service');
      return false;
    }

    if (_orderDraft.items.isEmpty) {
      _setError('Veuillez ajouter au moins un article');
      return false;
    }

    _setSubmitting(true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      debugPrint('🚀 [OrderDraftProvider] Creating order...');
      debugPrint('   Service Type: ${_selectedServiceType!.id}');
      debugPrint('   Service: ${_selectedService!.id}');
      debugPrint('   Address: ${_selectedAddress!.id}');
      debugPrint('   Items: ${_orderDraft.items.length}');

      // Créer le payload pour l'API avec dates au format ISO-8601 complet avec timezone UTC
      final request = CreateOrderRequest(
        serviceTypeId: _selectedServiceType!.id,
        serviceId: _selectedService!.id,
        addressId: _selectedAddress!.id,
        items: _orderDraft.items.map((item) => OrderItemRequest(
          articleId: item.articleId,
          serviceId: _selectedService!.id,
          serviceTypeId: _selectedServiceType!.id,
          quantity: item.quantity,
          isPremium: item.isPremium,
          weight: item.weight,
        )).toList(),
        note: _orderDraft.note,
        paymentMethod: _orderDraft.paymentMethod ?? 'CASH',
        // Convertir les dates en format ISO-8601 complet avec timezone UTC (ajout de .toUtc())
        collectionDate: _orderDraft.collectionDate != null 
            ? DateTime(_orderDraft.collectionDate!.year, _orderDraft.collectionDate!.month, _orderDraft.collectionDate!.day, 10, 0, 0).toUtc()
            : null,
        deliveryDate: _orderDraft.deliveryDate != null
            ? DateTime(_orderDraft.deliveryDate!.year, _orderDraft.deliveryDate!.month, _orderDraft.deliveryDate!.day, 18, 0, 0).toUtc()
            : null,
        affiliateCode: _orderDraft.affiliateCode,
        isRecurring: _orderDraft.recurrenceType != null && _orderDraft.recurrenceType != 'NONE',
        recurrenceType: _orderDraft.recurrenceType,
      );

      debugPrint('📦 [OrderDraftProvider] Sending request to API...');

      // Appeler l'API
      final order = await OrderService().createOrder(request);

      debugPrint('✅ [OrderDraftProvider] Order created successfully!');
      debugPrint('   Order ID: ${order.id}');
      debugPrint('   Reference: ${order.shortOrderId}');

      // Réinitialiser le draft après succès
      reset();

      NotificationUtils.showSuccess(
        context,
        'Commande créée avec succès ! Référence: ${order.shortOrderId}',
      );

      return true;
    } catch (e) {
      debugPrint('❌ [OrderDraftProvider] Error creating order: $e');
      _setError('Erreur lors de la création: ${e.toString()}');
      NotificationUtils.showError(
        context,
        'Erreur lors de la création: ${e.toString()}',
      );
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// 🧹 Réinitialiser le provider
  void reset() {
    _orderDraft.reset();
    _currentStep = 0;
    _selectedAddress = null;
    _selectedServiceType = null;
    _selectedService = null;
    _isPremium = false;
    _clearError();
    notifyListeners();
  }

  /// 🔧 Méthodes utilitaires privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
