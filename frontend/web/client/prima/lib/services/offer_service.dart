import 'package:dio/dio.dart';
import '../models/offer.dart';

class OfferService {
  final Dio _dio;

  OfferService(this._dio);

  Future<List<Offer>> getAvailableOffers() async {
    try {
      final response = await _dio.get('/api/offers/available');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Offer.fromJson(json)).toList();
    } catch (e) {
      print('Error getting offers: $e');
      rethrow;
    }
  }

  Future<void> applyOffer(String orderId, String offerId) async {
    try {
      await _dio.post('/api/offers/apply', data: {
        'orderId': orderId,
        'offerId': offerId,
      });
    } catch (e) {
      print('Error applying offer: $e');
      rethrow;
    }
  }
}
