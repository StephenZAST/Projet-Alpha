import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';

class OfferProvider with ChangeNotifier {
  final OfferService _offerService;
  List<Offer> _offers = [];
  bool _isLoading = false;
  String? _error;
  Offer? _selectedOffer;

  OfferProvider(this._offerService);

  List<Offer> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Offer? get selectedOffer => _selectedOffer;

  Future<void> loadOffers() async {
    try {
      _isLoading = true;
      notifyListeners();

      _offers = await _offerService.getAvailableOffers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectOffer(Offer? offer) {
    _selectedOffer = offer;
    notifyListeners();
  }

  Future<void> applySelectedOffer(String orderId) async {
    if (_selectedOffer == null) return;

    try {
      await _offerService.applyOffer(orderId, _selectedOffer!.id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
