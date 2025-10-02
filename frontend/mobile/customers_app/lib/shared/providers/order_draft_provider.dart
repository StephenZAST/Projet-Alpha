import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/order_draft.dart';
import '../../core/models/address.dart';
import '../../core/models/service_type.dart';
import '../../core/models/service.dart';
import '../../core/models/article.dart';
import '../../core/services/address_service.dart';
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
  Map<String, dynamic> _couples = {}; // Cache des couples article-service

  List<Address> get addresses => _addresses;
  List<ServiceType> get serviceTypes => _serviceTypes;
  List<Service> get services => _services;
  List<Article> get articles => _articles;

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
      // TODO: Implémenter l'API pour récupérer les types de service
      // Pour l'instant, utilisons des données mock
      _serviceTypes = [
        ServiceType(
          id: 'standard',
          name: 'Standard',
          description: 'Service standard avec délai normal',
          pricingType: 'FIXED',
          requiresWeight: false,
          supportsPremium: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ServiceType(
          id: 'express',
          name: 'Express 24h',
          description: 'Service express livré en 24h',
          pricingType: 'FIXED',
          requiresWeight: false,
          supportsPremium: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ServiceType(
          id: 'weight',
          name: 'Au poids',
          description: 'Service facturé au poids',
          pricingType: 'WEIGHT_BASED',
          requiresWeight: true,
          supportsPremium: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      notifyListeners();
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement des types de service: ${e.toString()}');
    }
  }

  /// 🛠️ Charger les services par type
  Future<void> _loadServicesByType(String serviceTypeId) async {
    try {
      // TODO: Implémenter l'API pour récupérer les services par type
      // Pour l'instant, utilisons des données mock
      _services = [
        Service(
          id: 'nettoyage-sec',
          name: 'Nettoyage à sec',
          description: 'Nettoyage professionnel à sec',
          serviceTypeId: serviceTypeId,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Service(
          id: 'repassage',
          name: 'Repassage',
          description: 'Repassage professionnel',
          serviceTypeId: serviceTypeId,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Service(
          id: 'retouches',
          name: 'Retouches',
          description: 'Retouches et ajustements',
          serviceTypeId: serviceTypeId,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      notifyListeners();
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement des services: ${e.toString()}');
    }
  }

  /// 📦 Charger les articles disponibles
  Future<void> _loadArticles() async {
    try {
      // TODO: Implémenter l'API pour récupérer les articles
      // Pour l'instant, utilisons des données mock
      _articles = [
        Article(
          id: 'chemise',
          name: 'Chemise',
          description: 'Chemise homme/femme',
          categoryId: 'vetements',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Article(
          id: 'pantalon',
          name: 'Pantalon',
          description: 'Pantalon classique',
          categoryId: 'vetements',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Article(
          id: 'costume',
          name: 'Costume',
          description: 'Costume complet',
          categoryId: 'vetements',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Article(
          id: 'robe',
          name: 'Robe',
          description: 'Robe de soirée',
          categoryId: 'vetements',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      notifyListeners();
    } catch (e) {
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

    // Charger les articles si pas encore fait
    if (_articles.isEmpty) {
      await _loadArticles();
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

  /// 💰 Obtenir le prix d'un article (mock pour l'instant)
  double _getArticlePrice(String articleId, bool isPremium) {
    // TODO: Récupérer les vrais prix depuis l'API
    final basePrices = {
      'chemise': 8.0,
      'pantalon': 10.0,
      'costume': 25.0,
      'robe': 15.0,
    };

    final basePrice = basePrices[articleId] ?? 5.0;
    return isPremium ? basePrice * 1.5 : basePrice;
  }

  /// 💰 Obtenir le prix d'un article (méthode publique)
  double getArticlePrice(String articleId, bool isPremium) {
    return _getArticlePrice(articleId, isPremium);
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

    _setSubmitting(true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final payload = _orderDraft.toPayload(userId);

      // TODO: Implémenter l'API de création de commande
      await Future.delayed(const Duration(seconds: 2)); // Simulation

      // Réinitialiser le draft après succès
      reset();

      NotificationUtils.showSuccess(
        context,
        'Commande créée avec succès !',
      );

      return true;
    } catch (e) {
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
