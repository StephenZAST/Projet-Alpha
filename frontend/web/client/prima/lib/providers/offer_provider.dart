import 'package:flutter/material.dart';
import 'package:prima/providers/loyalty_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';
import 'dart:convert';

class OfferProvider with ChangeNotifier {
  static const String _recentOffersKey = 'recent_offers';
  static const String _lastSelectedOfferKey = 'last_selected_offer';

  final OfferService _offerService;
  final SharedPreferences _prefs;

  List<Offer> _offers = [];
  List<String> _recentlyUsedOfferIds = [];
  Offer? _selectedOffer;
  bool _isLoading = false;
  String? _error;

  OfferProvider(this._offerService, this._prefs) {
    _loadPersistedData();
  }

  List<Offer> get offers => _offers;
  Offer? get selectedOffer => _selectedOffer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get recentlyUsedOfferIds => _recentlyUsedOfferIds;

  Future<void> _loadPersistedData() async {
    try {
      // Charger les offres récemment utilisées
      final recentOffersJson = _prefs.getStringList(_recentOffersKey);
      if (recentOffersJson != null) {
        _recentlyUsedOfferIds = recentOffersJson;
      }

      // Charger la dernière offre sélectionnée
      final lastSelectedOfferJson = _prefs.getString(_lastSelectedOfferKey);
      if (lastSelectedOfferJson != null) {
        _selectedOffer = Offer.fromJson(json.decode(lastSelectedOfferJson));
      }
    } catch (e) {
      print('Error loading persisted offers: $e');
    }
  }

  Future<void> loadOffers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _offers = await _offerService.getAvailableOffers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectOffer(Offer? offer) async {
    _selectedOffer = offer;

    if (offer != null) {
      // Ajouter l'offre aux récemment utilisées
      if (!_recentlyUsedOfferIds.contains(offer.id)) {
        _recentlyUsedOfferIds.insert(0, offer.id);
        if (_recentlyUsedOfferIds.length > 5) {
          // Garder les 5 dernières
          _recentlyUsedOfferIds.removeLast();
        }
        await _prefs.setStringList(_recentOffersKey, _recentlyUsedOfferIds);
      }

      // Sauvegarder l'offre sélectionnée
      await _prefs.setString(_lastSelectedOfferKey, json.encode(offer));
    } else {
      // Si désélection, supprimer la sauvegarde
      await _prefs.remove(_lastSelectedOfferKey);
    }

    notifyListeners();
  }

  Future<void> applyPointsExchangeOffer(String offerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final offer = _offers.firstWhere((o) => o.id == offerId);
      if (offer.discountType != 'POINTS_EXCHANGE') {
        throw Exception('Invalid offer type');
      }

      // Vérifier le solde de points
      final points = await context.read<LoyaltyProvider>().getPointsBalance();
      if (points < (offer.pointsRequired ?? 0)) {
        throw Exception('Insufficient points');
      }

      // Sélectionner l'offre
      await selectOffer(offer);

      // La déduction des points se fait côté backend lors de la validation de la commande
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Offer> getValidOffersForAmount(double amount) {
    return _offers
        .where((offer) =>
            offer.isValid &&
            (!offer.minPurchaseAmount || offer.minPurchaseAmount! <= amount))
        .toList();
  }

  List<Offer> getRecentOffers() {
    return _recentlyUsedOfferIds
        .map((id) => _offers.firstWhere(
              (offer) => offer.id == id,
              orElse: () => null,
            ))
        .where((offer) => offer.isValid)
        .cast<Offer>()
        .toList();
  }

  void clearSelectedOffer() {
    _selectedOffer = null;
    notifyListeners();
  }
}
