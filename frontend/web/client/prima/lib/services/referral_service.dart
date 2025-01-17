import 'package:dio/dio.dart';

class ReferralService {
  final Dio _dio;

  ReferralService(this._dio);

  Future<String> getReferralCode() async {
    try {
      final response = await _dio.get('/api/referral/code');
      return response.data['data']['code'];
    } catch (e) {
      print('Error getting referral code: $e');
      rethrow;
    }
  }

  Future<void> validateReferralCode(String code) async {
    try {
      await _dio.post('/api/referral/validate', data: {'code': code});
    } catch (e) {
      print('Error validating referral code: $e');
      rethrow;
    }
  }
}
