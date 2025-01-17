import 'package:flutter/foundation.dart';
import '../services/loyalty_service.dart';
import '../models/loyalty_points.dart';
import '../models/point_transaction.dart';

class LoyaltyProvider with ChangeNotifier {
  final LoyaltyService _loyaltyService;
  LoyaltyPoints? _points;
  List<PointTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  LoyaltyProvider(this._loyaltyService);

  LoyaltyPoints? get points => _points;
  List<PointTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPoints() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _points = await _loyaltyService.getPointsBalance();
      _transactions = await _loyaltyService.getTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> earnPoints(int points, String source, String referenceId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedPoints = await _loyaltyService.earnPoints(
        points,
        source,
        referenceId,
      );

      _points = updatedPoints;
      await loadPoints(); // Recharger les transactions aussi
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> spendPoints(
      int points, String source, String referenceId) async {
    try {
      if (_points == null || _points!.pointsBalance < points) {
        throw Exception('Solde de points insuffisant');
      }

      _isLoading = true;
      notifyListeners();

      final updatedPoints = await _loyaltyService.spendPoints(
        points,
        source,
        referenceId,
      );

      _points = updatedPoints;
      await loadPoints(); // Recharger les transactions aussi
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPoints() => loadPoints();
}
