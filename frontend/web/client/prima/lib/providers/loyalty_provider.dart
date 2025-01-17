import 'package:flutter/foundation.dart';
import '../services/loyalty_service.dart';
import '../models/loyalty_points.dart';

class LoyaltyProvider with ChangeNotifier {
  final LoyaltyService _loyaltyService;
  LoyaltyPoints? _points;
  bool _isLoading = false;
  String? _error;

  LoyaltyProvider(this._loyaltyService);

  LoyaltyPoints? get points => _points;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPoints() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _points = await _loyaltyService.getPointsBalance();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPoints() => loadPoints();
}
