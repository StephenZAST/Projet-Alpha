import 'package:flutter/foundation.dart';
import '../models/offer.dart';
import 'api_service.dart';

/// 🎁 Service Offres - Alpha Client App
///
/// Gère la communication avec l'API backend pour les offres promotionnelles.
class OfferService {
  static const String _baseUrl = '/api/offers';

  /// 📋 Récupérer toutes les offres disponibles pour l'utilisateur
  static Future<List<Offer>> getAvailableOffers() async {
    try {
      debugPrint('[OfferService] Fetching available offers...');
      
      final response = await ApiService.get('$_baseUrl/available');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> offersData = response['data'] as List<dynamic>;
        final offers = offersData
            .map((json) => Offer.fromJson(json as Map<String, dynamic>))
            .toList();
        
        debugPrint('[OfferService] ✅ Loaded ${offers.length} available offers');
        return offers;
      }
      
      debugPrint('[OfferService] ❌ Invalid response format');
      return [];
    } catch (e) {
      debugPrint('[OfferService] ❌ Error fetching available offers: $e');
      rethrow;
    }
  }

  /// 🎯 Récupérer les offres auxquelles l'utilisateur est abonné
  static Future<List<Offer>> getUserSubscriptions() async {
    try {
      debugPrint('[OfferService] Fetching user subscriptions...');
      
      final response = await ApiService.get('$_baseUrl/my-subscriptions');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> offersData = response['data'] as List<dynamic>;
        final offers = offersData
            .map((json) => Offer.fromJson(json as Map<String, dynamic>))
            .toList();
        
        debugPrint('[OfferService] ✅ Loaded ${offers.length} user subscriptions');
        return offers;
      }
      
      debugPrint('[OfferService] ❌ Invalid response format');
      return [];
    } catch (e) {
      debugPrint('[OfferService] ❌ Error fetching user subscriptions: $e');
      rethrow;
    }
  }

  /// 📖 Récupérer les détails d'une offre
  static Future<Offer> getOfferById(String offerId) async {
    try {
      debugPrint('[OfferService] Fetching offer details: $offerId');
      
      final response = await ApiService.get('$_baseUrl/$offerId');
      
      if (response['success'] == true && response['data'] != null) {
        final offer = Offer.fromJson(response['data'] as Map<String, dynamic>);
        debugPrint('[OfferService] ✅ Loaded offer: ${offer.name}');
        return offer;
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('[OfferService] ❌ Error fetching offer: $e');
      rethrow;
    }
  }

  /// ✅ S'abonner à une offre
  static Future<void> subscribeToOffer(String offerId) async {
    try {
      debugPrint('[OfferService] Subscribing to offer: $offerId');
      
      final response = await ApiService.post(
        '$_baseUrl/$offerId/subscribe',
        {},
      );
      
      if (response['success'] == true) {
        debugPrint('[OfferService] ✅ Successfully subscribed to offer');
        return;
      }
      
      throw Exception(response['message'] ?? 'Failed to subscribe');
    } catch (e) {
      debugPrint('[OfferService] ❌ Error subscribing to offer: $e');
      rethrow;
    }
  }

  /// ❌ Se désabonner d'une offre
  static Future<void> unsubscribeFromOffer(String offerId) async {
    try {
      debugPrint('[OfferService] Unsubscribing from offer: $offerId');
      
      final response = await ApiService.post(
        '$_baseUrl/$offerId/unsubscribe',
        {},
      );
      
      if (response['success'] == true) {
        debugPrint('[OfferService] ✅ Successfully unsubscribed from offer');
        return;
      }
      
      throw Exception(response['message'] ?? 'Failed to unsubscribe');
    } catch (e) {
      debugPrint('[OfferService] ❌ Error unsubscribing from offer: $e');
      rethrow;
    }
  }
}
