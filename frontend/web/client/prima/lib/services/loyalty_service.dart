import 'package:dio/dio.dart';
import '../models/loyalty_points.dart';

class LoyaltyService {
  final Dio _dio;

  LoyaltyService(this._dio);

  Future<LoyaltyPoints> getPointsBalance() async {
    try {
      final response = await _dio.get('/api/loyalty/points-balance');
      return LoyaltyPoints.fromJson(response.data['data']);
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
      return LoyaltyPoints.fromJson(response.data['data']);
    } catch (e) {
      print('Error earning points: $e');
      rethrow;
    }
  }
}
