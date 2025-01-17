import 'package:dio/dio.dart';
import '../models/loyalty_points.dart';
import '../models/point_transaction.dart';

class LoyaltyService {
  final Dio _dio;

  LoyaltyService(this._dio);

  Future<LoyaltyPoints> getPointsBalance() async {
    try {
      final response = await _dio.get('/api/loyalty/points-balance');
      if (response.data['data'] != null) {
        return LoyaltyPoints.fromJson(response.data['data']);
      }
      throw Exception('Failed to load points balance');
    } catch (e) {
      print('Error getting points balance: $e');
      rethrow;
    }
  }

  Future<LoyaltyPoints> earnPoints(
      int points, String source, String referenceId) async {
    try {
      final response = await _dio.post('/api/loyalty/earn-points', data: {
        'points': points,
        'source': source,
        'referenceId': referenceId,
      });

      if (response.data['data'] != null) {
        return LoyaltyPoints.fromJson(response.data['data']);
      }
      throw Exception('Failed to earn points');
    } catch (e) {
      print('Error earning points: $e');
      rethrow;
    }
  }

  Future<List<PointTransaction>> getTransactions() async {
    try {
      final response = await _dio.get('/api/loyalty/transactions');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PointTransaction.fromJson(json)).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      rethrow;
    }
  }
}
