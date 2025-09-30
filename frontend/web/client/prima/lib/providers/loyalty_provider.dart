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

  // Statistiques calculées
  int _pointsThisMonth = 0;
  int _totalOrders = 0;
  int _totalReferrals = 0;

  LoyaltyProvider(this._loyaltyService);

  LoyaltyPoints? get points => _points;
  List<PointTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pointsThisMonth => _pointsThisMonth;
  int get totalOrders => _totalOrders;
  int get totalReferrals => _totalReferrals;

  Future<void> loadPoints() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _points = await _loyaltyService.getPointsBalance();
      _transactions = await _loyaltyService.getTransactions();

      // Calculer les statistiques
      _calculateStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    await loadPoints(); // loadTransactions fait la même chose que loadPoints
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

  Future<void> convertPointsToDiscount(int points) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _loyaltyService.spendPoints(
        points,
        'EXCHANGE',
        DateTime.now().toIso8601String(),
      );

      await loadPoints(); // Recharger les points après la conversion
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calcul du montant de réduction possible
  double calculatePossibleDiscount(int points) {
    return (points / 100).floor().toDouble(); // 100 points = 1€
  }

  void _calculateStats() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    _pointsThisMonth = _transactions
        .where((t) =>
            t.createdAt.isAfter(startOfMonth) &&
            t.type == TransactionType.EARNED)
        .fold(0, (sum, t) => sum + t.points);

    _totalOrders =
        _transactions.where((t) => t.source == TransactionSource.ORDER).length;

    _totalReferrals = _transactions
        .where((t) => t.source == TransactionSource.REFERRAL)
        .length;
  }
}
