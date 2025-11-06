import 'package:flutter/foundation.dart';
import '../core/models/offer.dart';
import '../core/services/offer_service.dart';

/// 🎁 Provider Offres - Alpha Client App
///
/// Gère l'état global des offres avec cache et refresh.
class OffersProvider extends ChangeNotifier {
  List<Offer> _availableOffers = [];
  List<Offer> _userSubscriptions = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  // Getters
  List<Offer> get availableOffers => _availableOffers;
  List<Offer> get userSubscriptions => _userSubscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Initialiser le provider (charger les offres)
  Future<void> initialize() async {
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
      debugPrint('[OffersProvider] Using cached offers (< 5 min)');
      return;
    }

    await loadAvailableOffers();
    await loadUserSubscriptions();
  }

  /// 📋 Charger les offres disponibles
  Future<void> loadAvailableOffers() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('[OffersProvider] Loading available offers...');
      final offers = await OfferService.getAvailableOffers();
      _availableOffers = offers;
      _lastFetchTime = DateTime.now();
      debugPrint('[OffersProvider] ✅ Loaded ${offers.length} available offers');
    } catch (e) {
      _setError('Erreur lors du chargement des offres: $e');
      debugPrint('[OffersProvider] ❌ Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 🎯 Charger les abonnements de l'utilisateur
  Future<void> loadUserSubscriptions() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('[OffersProvider] Loading user subscriptions...');
      final subscriptions = await OfferService.getUserSubscriptions();
      _userSubscriptions = subscriptions;
      debugPrint('[OffersProvider] ✅ Loaded ${subscriptions.length} subscriptions');
    } catch (e) {
      _setError('Erreur lors du chargement des abonnements: $e');
      debugPrint('[OffersProvider] ❌ Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ S'abonner à une offre
  Future<void> subscribeToOffer(String offerId) async {
    try {
      debugPrint('[OffersProvider] Subscribing to offer: $offerId');
      await OfferService.subscribeToOffer(offerId);

      // Mettre à jour l'état local
      final offerIndex =
          _availableOffers.indexWhere((o) => o.id == offerId);
      if (offerIndex != -1) {
        _availableOffers[offerIndex] =
            _availableOffers[offerIndex].copyWith(isSubscribed: true);
      }

      // Recharger les abonnements
      await loadUserSubscriptions();
      notifyListeners();

      debugPrint('[OffersProvider] ✅ Successfully subscribed');
    } catch (e) {
      _setError('Erreur lors de l\'abonnement: $e');
      debugPrint('[OffersProvider] ❌ Error: $e');
      rethrow;
    }
  }

  /// ❌ Se désabonner d'une offre
  Future<void> unsubscribeFromOffer(String offerId) async {
    try {
      debugPrint('[OffersProvider] Unsubscribing from offer: $offerId');
      await OfferService.unsubscribeFromOffer(offerId);

      // Mettre à jour l'état local
      final offerIndex =
          _availableOffers.indexWhere((o) => o.id == offerId);
      if (offerIndex != -1) {
        _availableOffers[offerIndex] =
            _availableOffers[offerIndex].copyWith(isSubscribed: false);
      }

      // Recharger les abonnements
      await loadUserSubscriptions();
      notifyListeners();

      debugPrint('[OffersProvider] ✅ Successfully unsubscribed');
    } catch (e) {
      _setError('Erreur lors de la désinscription: $e');
      debugPrint('[OffersProvider] ❌ Error: $e');
      rethrow;
    }
  }

  /// 🔄 Rafraîchir les offres
  Future<void> refresh() async {
    _lastFetchTime = null;
    await initialize();
  }

  // Helpers privés
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
