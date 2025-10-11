import 'package:flutter/material.dart';
import '../../core/models/address.dart';
import '../../core/services/address_service.dart';

/// 🏠 Provider de Gestion des Adresses - Alpha Client App
///
/// Gère l'état global des adresses utilisateur avec synchronisation backend,
/// persistance automatique des brouillons et système de cache optimisé.
class AddressProvider extends ChangeNotifier {
  final AddressService _addressService = AddressService();

  // État des adresses
  AddressList? _addressList;
  Address? _selectedAddress;
  
  // États de chargement et d'erreur
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _error;
  
  // Brouillon d'adresse
  CreateAddressRequest? _draftAddress;

  // 🔥 Cache Management
  DateTime? _lastFetch;
  bool _isInitialized = false;
  static const Duration _cacheDuration = Duration(minutes: 15); // 15 min (données stables)

  // Getters
  AddressList? get addressList => _addressList;
  List<Address> get addresses => _addressList?.addresses ?? [];
  Address? get defaultAddress => _addressList?.defaultAddress;
  Address? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get error => _error;
  CreateAddressRequest? get draftAddress => _draftAddress;

  // Getters calculés
  bool get hasAddresses => addresses.isNotEmpty;
  bool get hasDefaultAddress => defaultAddress != null;
  int get totalAddresses => addresses.length;
  bool get canMakeOrders => hasDefaultAddress;

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

  /// 🚀 Initialisation du provider avec système de cache
  Future<void> initialize({bool forceRefresh = false}) async {
    // 🔥 Vérifier le cache avant de charger
    if (_isInitialized && !forceRefresh && !_shouldRefresh && hasAddresses) {
      debugPrint('✅ [AddressProvider] Cache valide - Pas de rechargement');
      debugPrint('📊 [AddressProvider] Dernière mise à jour: $cacheStatus');
      debugPrint('🏠 [AddressProvider] $totalAddresses adresse(s)');
      return;
    }

    if (forceRefresh) {
      debugPrint('🔄 [AddressProvider] Rechargement forcé');
    } else if (_shouldRefresh) {
      debugPrint('⏰ [AddressProvider] Cache expiré - Rechargement');
    } else {
      debugPrint('🆕 [AddressProvider] Première initialisation');
    }

    _setLoading(true);
    
    try {
      final startTime = DateTime.now();
      
      // Charger les adresses
      await loadAddresses();
      
      // Charger le brouillon sauvegardé
      await _loadDraftAddress();
      
      // 🔥 Marquer comme initialisé
      _isInitialized = true;
      _lastFetch = DateTime.now();
      
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [AddressProvider] Chargement terminé en ${duration.inMilliseconds}ms');
      debugPrint('🏠 [AddressProvider] $totalAddresses adresse(s), défaut: ${hasDefaultAddress ? "✓" : "✗"}');
      
      _clearError();
    } catch (e) {
      debugPrint('❌ [AddressProvider] Erreur: $e');
      _setError('Erreur d\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 📋 Charger toutes les adresses
  Future<void> loadAddresses() async {
    try {
      final startTime = DateTime.now();
      _addressList = await _addressService.getAllAddresses();
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Addresses] ${addresses.length} adresse(s) chargée(s) en ${duration.inMilliseconds}ms');
      _clearError();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Addresses] Erreur: $e');
      _setError('Erreur de chargement des adresses: ${e.toString()}');
      rethrow;
    }
  }

  /// ➕ Créer une nouvelle adresse
  Future<bool> createAddress(CreateAddressRequest request) async {
    _isCreating = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _addressService.createAddress(request);

      if (result.isSuccess && result.address != null) {
        // Recharger les adresses pour avoir la liste à jour
        await loadAddresses();
        
        // Supprimer le brouillon
        await _clearDraftAddress();
        
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors de la création de l\'adresse');
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// ✏️ Mettre à jour une adresse
  Future<bool> updateAddress(String addressId, UpdateAddressRequest request) async {
    print('[AddressProvider] Updating address $addressId with request: ${request.toJson()}');
    
    _isUpdating = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _addressService.updateAddress(addressId, request);
      print('[AddressProvider] Update result: success=${result.isSuccess}, error=${result.error}');

      if (result.isSuccess) {
        // Recharger les adresses pour avoir la liste à jour
        await loadAddresses();
        print('[AddressProvider] Addresses reloaded after update');
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors de la mise à jour de l\'adresse');
        return false;
      }
    } catch (e) {
      print('[AddressProvider] Update exception: $e');
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// 🗑️ Supprimer une adresse
  Future<bool> deleteAddress(String addressId) async {
    _isDeleting = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _addressService.deleteAddress(addressId);

      if (result.isSuccess) {
        // Recharger les adresses pour avoir la liste à jour
        await loadAddresses();
        
        // Si l'adresse supprimée était sélectionnée, la désélectionner
        if (_selectedAddress?.id == addressId) {
          _selectedAddress = null;
        }
        
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors de la suppression de l\'adresse');
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  /// 🏠 Définir une adresse comme par défaut
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final result = await _addressService.setDefaultAddress(addressId);

      if (result.isSuccess) {
        // Recharger les adresses pour avoir la liste à jour
        await loadAddresses();
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors de la définition de l\'adresse par défaut');
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    }
  }

  /// 🎯 Sélectionner une adresse
  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  /// 🎯 Désélectionner l'adresse
  void clearSelection() {
    _selectedAddress = null;
    notifyListeners();
  }

  /// 🔍 Rechercher une adresse par ID
  Address? findAddressById(String id) {
    return _addressList?.findById(id);
  }

  /// 📊 Obtenir les statistiques des adresses
  Future<Map<String, dynamic>> getAddressStats() async {
    try {
      return await _addressService.getAddressStats();
    } catch (e) {
      return {
        'totalAddresses': totalAddresses,
        'hasDefaultAddress': hasDefaultAddress,
        'addressesWithGPS': 0,
        'citiesCount': 0,
      };
    }
  }

  /// 💾 Sauvegarder un brouillon d'adresse
  Future<void> saveDraftAddress(CreateAddressRequest request) async {
    _draftAddress = request;
    await _addressService.saveDraftAddress(request);
    notifyListeners();
  }

  /// 📥 Charger le brouillon sauvegardé
  Future<void> _loadDraftAddress() async {
    try {
      _draftAddress = await _addressService.getDraftAddress();
    } catch (e) {
      // Erreur silencieuse pour le chargement du brouillon
    }
  }

  /// 🗑️ Supprimer le brouillon
  Future<void> _clearDraftAddress() async {
    _draftAddress = null;
    await _addressService.clearDraftAddress();
    notifyListeners();
  }

  /// 🔄 Actualiser les adresses (force le rechargement)
  Future<void> refresh() async {
    debugPrint('🔄 [AddressProvider] Rafraîchissement manuel');
    await initialize(forceRefresh: true);
  }
  
  /// 🗑️ Invalider le cache (pour forcer un rechargement au prochain accès)
  void invalidateCache() {
    debugPrint('🗑️ [AddressProvider] Cache invalidé');
    _isInitialized = false;
    _lastFetch = null;
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

  /// Obtenir les adresses non-par défaut
  List<Address> get nonDefaultAddresses {
    return _addressList?.nonDefaultAddresses ?? [];
  }

  /// Vérifier si une adresse est sélectionnée
  bool isAddressSelected(String addressId) {
    return _selectedAddress?.id == addressId;
  }

  /// Obtenir l'adresse par défaut ou la première disponible
  Address? get primaryAddress {
    return defaultAddress ?? (addresses.isNotEmpty ? addresses.first : null);
  }

  /// Vérifier si l'utilisateur peut créer des commandes
  bool get canCreateOrders {
    return hasAddresses && hasDefaultAddress;
  }

  /// Obtenir le nombre d'adresses par ville
  Map<String, int> get addressesByCity {
    final Map<String, int> cityCount = {};
    for (final address in addresses) {
      cityCount[address.city] = (cityCount[address.city] ?? 0) + 1;
    }
    return cityCount;
  }

  /// Obtenir les adresses avec coordonnées GPS
  List<Address> get addressesWithGPS {
    return addresses.where((address) => address.hasGpsCoordinates).toList();
  }

  /// Valider si l'utilisateur peut faire des commandes flash
  bool get canMakeFlashOrders {
    return hasDefaultAddress;
  }
}