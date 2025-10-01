import 'package:flutter/material.dart';
import '../../core/models/flash_order.dart';
import '../../core/services/flash_order_service.dart';

/// ⚡ Provider de Commande Flash - Alpha Client App
///
/// Gère l'état global des commandes flash avec persistance automatique
/// et synchronisation avec le backend Alpha Pressing.
class FlashOrderProvider extends ChangeNotifier {
  final FlashOrderService _flashOrderService = FlashOrderService();

  // État de la commande flash actuelle
  FlashOrder? _currentFlashOrder;
  List<PopularFlashItem> _popularItems = [];
  List<FlashOrderResult> _orderHistory = [];
  
  // États de chargement et d'erreur
  bool _isLoading = false;
  bool _isCreatingOrder = false;
  bool _isLoadingPopularItems = false;
  String? _error;
  
  // Résultat de la dernière commande
  FlashOrderResult? _lastOrderResult;

  // Getters
  FlashOrder? get currentFlashOrder => _currentFlashOrder;
  List<PopularFlashItem> get popularItems => _popularItems;
  List<FlashOrderResult> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;
  bool get isCreatingOrder => _isCreatingOrder;
  bool get isLoadingPopularItems => _isLoadingPopularItems;
  String? get error => _error;
  FlashOrderResult? get lastOrderResult => _lastOrderResult;

  // Getters calculés
  bool get hasItems => _currentFlashOrder?.items.isNotEmpty ?? false;
  int get totalItems => _currentFlashOrder?.totalItems ?? 0;
  double get totalPrice => _currentFlashOrder?.totalEstimatedPrice ?? 0.0;
  bool get canCreateOrder => _currentFlashOrder?.isValid ?? false;

  /// 🚀 Initialisation du provider
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // Charger le brouillon sauvegardé
      await _loadDraftOrder();
      
      // Charger les articles populaires
      await loadPopularItems();
      
      // Charger l'historique
      await loadOrderHistory();
      
      _clearError();
    } catch (e) {
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 📋 Charger les articles populaires
  Future<void> loadPopularItems() async {
    _isLoadingPopularItems = true;
    notifyListeners();
    
    try {
      _popularItems = await _flashOrderService.getPopularFlashItems();
      _clearError();
    } catch (e) {
      _setError('Erreur de chargement des articles: ${e.toString()}');
    } finally {
      _isLoadingPopularItems = false;
      notifyListeners();
    }
  }

  /// 🆕 Créer une nouvelle commande flash
  void createNewFlashOrder() {
    _currentFlashOrder = FlashOrder(items: []);
    _lastOrderResult = null;
    _clearError();
    notifyListeners();
  }

  /// ➕ Ajouter un article à la commande
  void addItem(PopularFlashItem popularItem, {int quantity = 1, bool isPremium = false}) {
    if (_currentFlashOrder == null) {
      createNewFlashOrder();
    }

    final newItem = popularItem.toFlashOrderItem(
      quantity: quantity,
      isPremium: isPremium,
    );

    // Vérifier si l'article existe déjà
    final existingIndex = _currentFlashOrder!.items.indexWhere(
      (item) => item.articleId == newItem.articleId && 
                item.serviceId == newItem.serviceId &&
                item.isPremium == newItem.isPremium,
    );

    List<FlashOrderItem> updatedItems = List.from(_currentFlashOrder!.items);

    if (existingIndex >= 0) {
      // Mettre à jour la quantité
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
    } else {
      // Ajouter le nouvel article
      updatedItems.add(newItem);
    }

    _currentFlashOrder = _currentFlashOrder!.copyWith(items: updatedItems);
    _saveDraftOrder();
    notifyListeners();
  }

  /// ➖ Retirer un article de la commande
  void removeItem(String articleId, String serviceId, bool isPremium) {
    if (_currentFlashOrder == null) return;

    final updatedItems = _currentFlashOrder!.items.where(
      (item) => !(item.articleId == articleId && 
                  item.serviceId == serviceId &&
                  item.isPremium == isPremium),
    ).toList();

    _currentFlashOrder = _currentFlashOrder!.copyWith(items: updatedItems);
    _saveDraftOrder();
    notifyListeners();
  }

  /// 🔢 Mettre à jour la quantité d'un article
  void updateItemQuantity(String articleId, String serviceId, bool isPremium, int newQuantity) {
    if (_currentFlashOrder == null || newQuantity < 0) return;

    if (newQuantity == 0) {
      removeItem(articleId, serviceId, isPremium);
      return;
    }

    final updatedItems = _currentFlashOrder!.items.map((item) {
      if (item.articleId == articleId && 
          item.serviceId == serviceId &&
          item.isPremium == isPremium) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    _currentFlashOrder = _currentFlashOrder!.copyWith(items: updatedItems);
    _saveDraftOrder();
    notifyListeners();
  }

  /// 📝 Ajouter des notes à la commande
  void updateNotes(String notes) {
    if (_currentFlashOrder == null) return;

    _currentFlashOrder = _currentFlashOrder!.copyWith(notes: notes);
    _saveDraftOrder();
    notifyListeners();
  }

  /// 📍 Mettre à jour les adresses
  void updateAddresses({
    String? pickupAddressId,
    String? deliveryAddressId,
    bool? useDefaultAddresses,
  }) {
    if (_currentFlashOrder == null) return;

    _currentFlashOrder = _currentFlashOrder!.copyWith(
      pickupAddressId: pickupAddressId,
      deliveryAddressId: deliveryAddressId,
      useDefaultAddresses: useDefaultAddresses,
    );
    _saveDraftOrder();
    notifyListeners();
  }

  /// 📅 Mettre à jour les dates préférées
  void updatePreferredDates({
    DateTime? pickupDate,
    DateTime? deliveryDate,
  }) {
    if (_currentFlashOrder == null) return;

    _currentFlashOrder = _currentFlashOrder!.copyWith(
      preferredPickupDate: pickupDate,
      preferredDeliveryDate: deliveryDate,
    );
    _saveDraftOrder();
    notifyListeners();
  }

  /// ⚡ Créer la commande flash
  Future<bool> submitFlashOrder() async {
    if (_currentFlashOrder == null || !canCreateOrder) {
      _setError('Commande invalide');
      return false;
    }

    _isCreatingOrder = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _flashOrderService.createFlashOrder(_currentFlashOrder!);
      _lastOrderResult = result;

      if (result.isSuccess) {
        // Commande créée avec succès
        await _clearDraftOrder();
        _currentFlashOrder = null;
        
        // Recharger l'historique
        await loadOrderHistory();
        
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors de la création de la commande');
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    } finally {
      _isCreatingOrder = false;
      notifyListeners();
    }
  }

  /// 📊 Charger l'historique des commandes
  Future<void> loadOrderHistory({int page = 1}) async {
    try {
      final history = await _flashOrderService.getFlashOrderHistory(page: page);
      
      if (page == 1) {
        _orderHistory = history;
      } else {
        _orderHistory.addAll(history);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur de chargement de l\'historique: ${e.toString()}');
    }
  }

  /// 🔍 Rechercher des articles
  Future<List<PopularFlashItem>> searchItems(String query) async {
    try {
      return await _flashOrderService.searchFlashItems(query);
    } catch (e) {
      _setError('Erreur de recherche: ${e.toString()}');
      return [];
    }
  }

  /// 💰 Estimer le prix de la commande
  Future<void> estimatePrice() async {
    if (_currentFlashOrder == null) return;

    try {
      final estimatedPrice = await _flashOrderService.estimateFlashOrderPrice(_currentFlashOrder!);
      
      if (estimatedPrice != null) {
        // Mettre à jour les prix des articles avec l'estimation du backend
        // (Optionnel : pour l'instant on garde les prix locaux)
      }
    } catch (e) {
      // Erreur silencieuse pour l'estimation
    }
  }

  /// 🗑️ Vider la commande actuelle
  void clearCurrentOrder() {
    _currentFlashOrder = null;
    _lastOrderResult = null;
    _clearDraftOrder();
    _clearError();
    notifyListeners();
  }

  /// 💾 Sauvegarder le brouillon
  Future<void> _saveDraftOrder() async {
    if (_currentFlashOrder != null) {
      await _flashOrderService.saveDraftFlashOrder(_currentFlashOrder!);
    }
  }

  /// 📥 Charger le brouillon sauvegardé
  Future<void> _loadDraftOrder() async {
    try {
      _currentFlashOrder = await _flashOrderService.getDraftFlashOrder();
    } catch (e) {
      // Erreur silencieuse pour le chargement du brouillon
    }
  }

  /// 🗑️ Supprimer le brouillon
  Future<void> _clearDraftOrder() async {
    await _flashOrderService.clearDraftFlashOrder();
  }

  /// 🔧 Méthodes utilitaires privées
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

  /// 🧹 Nettoyage des ressources
  @override
  void dispose() {
    super.dispose();
  }

  /// 🎯 Méthodes utilitaires pour l'UI
  
  /// Obtenir un article par ID
  FlashOrderItem? getItemById(String articleId, String serviceId, bool isPremium) {
    return _currentFlashOrder?.items.firstWhere(
      (item) => item.articleId == articleId && 
                item.serviceId == serviceId &&
                item.isPremium == isPremium,
      orElse: () => null as FlashOrderItem,
    );
  }

  /// Vérifier si un article est dans la commande
  bool hasItem(String articleId, String serviceId, bool isPremium) {
    return getItemById(articleId, serviceId, isPremium) != null;
  }

  /// Obtenir la quantité d'un article
  int getItemQuantity(String articleId, String serviceId, bool isPremium) {
    final item = getItemById(articleId, serviceId, isPremium);
    return item?.quantity ?? 0;
  }

  /// Obtenir les articles populaires filtrés
  List<PopularFlashItem> getPopularItemsFiltered({bool onlyPopular = false}) {
    if (onlyPopular) {
      return _popularItems.where((item) => item.isPopular).toList();
    }
    return _popularItems;
  }
}