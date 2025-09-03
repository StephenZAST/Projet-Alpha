import '../services/api_service.dart';
import '../models/offer.dart';

class OfferService {
  static const String _baseUrl = '/api/offers';
  static final ApiService _apiService = ApiService();

  /// Récupère toutes les offres
  static Future<List<Offer>> getAllOffers() async {
    try {
      print('[OfferService] Getting all offers...');
      final response = await _apiService.get(_baseUrl);
      
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['data'] != null) {
        final List<Offer> offers = (response.data['data'] as List)
            .map((item) => Offer.fromJson(item))
            .toList();
        print('[OfferService] ✅ Retrieved ${offers.length} offers');
        return offers;
      }
      print('[OfferService] ⚠️ No offers data in response');
      return [];
    } catch (e) {
      print('[OfferService] ❌ Error getting offers: $e');
      rethrow;
    }
  }

  /// Récupère toutes les offres sous forme de Map (pour compatibilité)
  static Future<List<Map<String, dynamic>>> getAllOffersAsMap() async {
    try {
      final offers = await getAllOffers();
      return offers.map((offer) => offer.toMap()).toList();
    } catch (e) {
      print('[OfferService] ❌ Error getting offers as map: $e');
      rethrow;
    }
  }

  /// Récupère une offre par son ID
  static Future<Offer?> getOfferById(String offerId) async {
    try {
      print('[OfferService] Getting offer by ID: $offerId');
      final response = await _apiService.get('$_baseUrl/$offerId');
      
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['data'] != null) {
        final offer = Offer.fromJson(response.data['data']);
        print('[OfferService] ✅ Retrieved offer: ${offer.name}');
        return offer;
      }
      print('[OfferService] ⚠️ Offer not found');
      return null;
    } catch (e) {
      print('[OfferService] ❌ Error getting offer by ID: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle offre
  static Future<Offer?> createOffer(CreateOfferDTO offerData) async {
    try {
      print('[OfferService] Creating offer: ${offerData.name}');
      print('[OfferService] Offer data: ${offerData.toJson()}');
      
      final response = await _apiService.post(_baseUrl, data: offerData.toJson());
      
      if (response.statusCode == 201 &&
          response.data != null &&
          response.data['data'] != null) {
        final offer = Offer.fromJson(response.data['data']);
        print('[OfferService] ✅ Offer created successfully: ${offer.id}');
        return offer;
      }
      print('[OfferService] ❌ Failed to create offer - no data returned');
      return null;
    } catch (e) {
      print('[OfferService] ❌ Error creating offer: $e');
      rethrow;
    }
  }

  /// Crée une offre à partir d'un Map (pour compatibilité)
  static Future<Map<String, dynamic>?> createOfferFromMap(Map<String, dynamic> data) async {
    try {
      final dto = _mapToCreateOfferDTO(data);
      final offer = await createOffer(dto);
      return offer?.toMap();
    } catch (e) {
      print('[OfferService] ❌ Error creating offer from map: $e');
      rethrow;
    }
  }

  /// Met à jour une offre
  static Future<Offer?> updateOffer(String offerId, UpdateOfferDTO updateData) async {
    try {
      print('[OfferService] Updating offer: $offerId');
      print('[OfferService] Update data: ${updateData.toJson()}');
      
      final response = await _apiService.patch('$_baseUrl/$offerId', data: updateData.toJson());
      
      if (response.statusCode == 200) {
        if (response.data != null && response.data['data'] != null) {
          final offer = Offer.fromJson(response.data['data']);
          print('[OfferService] ✅ Offer updated successfully');
          return offer;
        } else if (response.data != null && response.data['success'] == true) {
          print('[OfferService] ✅ Offer updated (no data returned)');
          // Récupérer l'offre mise à jour
          return await getOfferById(offerId);
        }
      }
      
      print('[OfferService] ❌ Failed to update offer - status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('[OfferService] ❌ Error updating offer: $e');
      rethrow;
    }
  }

  /// Met à jour une offre à partir d'un Map (pour compatibilité)
  static Future<Map<String, dynamic>?> updateOfferFromMap(String offerId, Map<String, dynamic> data) async {
    try {
      final dto = _mapToUpdateOfferDTO(data);
      final offer = await updateOffer(offerId, dto);
      return offer?.toMap();
    } catch (e) {
      print('[OfferService] ❌ Error updating offer from map: $e');
      rethrow;
    }
  }

  /// Supprime une offre
  static Future<bool> deleteOffer(String offerId) async {
    try {
      print('[OfferService] Deleting offer: $offerId');
      final response = await _apiService.delete('$_baseUrl/$offerId');
      
      final success = response.statusCode == 200;
      if (success) {
        print('[OfferService] �� Offer deleted successfully');
      } else {
        print('[OfferService] ❌ Failed to delete offer - status: ${response.statusCode}');
      }
      return success;
    } catch (e) {
      print('[OfferService] ❌ Error deleting offer: $e');
      rethrow;
    }
  }

  /// Change le statut d'une offre (actif/inactif)
  static Future<bool> toggleOfferStatus(String offerId, bool isActive) async {
    try {
      print('[OfferService] Toggling offer status: $offerId -> $isActive');
      final response = await _apiService.patch(
        '$_baseUrl/$offerId/status',
        data: {'isActive': isActive},
      );
      
      final success = response.statusCode == 200;
      if (success) {
        print('[OfferService] ✅ Offer status updated successfully');
      } else {
        print('[OfferService] ❌ Failed to update offer status - status: ${response.statusCode}');
      }
      return success;
    } catch (e) {
      print('[OfferService] ❌ Error toggling offer status: $e');
      rethrow;
    }
  }

  /// Récupère les offres disponibles pour un utilisateur
  static Future<List<Offer>> getAvailableOffers() async {
    try {
      print('[OfferService] Getting available offers...');
      final response = await _apiService.get('$_baseUrl/available');
      
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['data'] != null) {
        final List<Offer> offers = (response.data['data'] as List)
            .map((item) => Offer.fromJson(item))
            .toList();
        print('[OfferService] ✅ Retrieved ${offers.length} available offers');
        return offers;
      }
      print('[OfferService] ⚠️ No available offers data in response');
      return [];
    } catch (e) {
      print('[OfferService] ❌ Error getting available offers: $e');
      rethrow;
    }
  }

  // Méthodes utilitaires pour la conversion Map <-> DTO

  static CreateOfferDTO _mapToCreateOfferDTO(Map<String, dynamic> data) {
    return CreateOfferDTO(
      name: data['name'],
      description: data['description'] ?? '',
      discountType: data['discountType'],
      discountValue: (data['discountValue'] as num).toDouble(),
      minPurchaseAmount: data['minPurchaseAmount'] != null 
          ? (data['minPurchaseAmount'] as num).toDouble() 
          : null,
      maxDiscountAmount: data['maxDiscountAmount'] != null 
          ? (data['maxDiscountAmount'] as num).toDouble() 
          : null,
      isCumulative: data['isCumulative'] ?? false,
      startDate: data['startDate'] is String 
          ? DateTime.parse(data['startDate']) 
          : data['startDate'],
      endDate: data['endDate'] is String 
          ? DateTime.parse(data['endDate']) 
          : data['endDate'],
      isActive: data['isActive'] ?? true,
      pointsRequired: data['pointsRequired'],
      articleIds: data['articles'] is List 
          ? (data['articles'] as List).cast<String>() 
          : data['articleIds'] is List 
              ? (data['articleIds'] as List).cast<String>() 
              : null,
    );
  }

  static UpdateOfferDTO _mapToUpdateOfferDTO(Map<String, dynamic> data) {
    return UpdateOfferDTO(
      name: data['name'],
      description: data['description'],
      discountType: data['discountType'],
      discountValue: data['discountValue'] != null 
          ? (data['discountValue'] as num).toDouble() 
          : null,
      minPurchaseAmount: data['minPurchaseAmount'] != null 
          ? (data['minPurchaseAmount'] as num).toDouble() 
          : null,
      maxDiscountAmount: data['maxDiscountAmount'] != null 
          ? (data['maxDiscountAmount'] as num).toDouble() 
          : null,
      isCumulative: data['isCumulative'],
      startDate: data['startDate'] is String 
          ? DateTime.parse(data['startDate']) 
          : data['startDate'],
      endDate: data['endDate'] is String 
          ? DateTime.parse(data['endDate']) 
          : data['endDate'],
      isActive: data['isActive'],
      pointsRequired: data['pointsRequired'],
      articleIds: data['articles'] is List 
          ? (data['articles'] as List).cast<String>() 
          : data['articleIds'] is List 
              ? (data['articleIds'] as List).cast<String>() 
              : null,
    );
  }
}