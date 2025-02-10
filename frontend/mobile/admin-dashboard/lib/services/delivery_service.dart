import '../models/delivery.dart';
import './api_service.dart';

class DeliveryService {
  static final _api = ApiService();
  static const _baseUrl = '/api/deliveries';

  static Future<List<Delivery>> getDeliveries({
    DeliveryStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool? isPendingPickup,
    bool? isPendingDelivery,
  }) async {
    try {
      final queryParams = {
        if (status != null) 'status': status.toString().split('.').last,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
        if (isPendingPickup != null)
          'isPendingPickup': isPendingPickup.toString(),
        if (isPendingDelivery != null)
          'isPendingDelivery': isPendingDelivery.toString(),
      };

      final response = await _api.get(_baseUrl, queryParameters: queryParams);

      if (!response.data['success']) {
        throw response.data['message'] ??
            'Erreur lors de la récupération des livraisons';
      }

      final deliveries = (response.data['data'] as List)
          .map((json) => Delivery.fromJson(json))
          .toList();

      return deliveries;
    } catch (e) {
      print('[DeliveryService] Error: $e');
      throw 'Erreur lors de la récupération des livraisons';
    }
  }

  static Future<void> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus newStatus,
    String? notes,
  }) async {
    try {
      final response = await _api.patch(
        '$_baseUrl/$deliveryId/status',
        data: {
          'status': newStatus.toString().split('.').last,
          if (notes != null) 'notes': notes,
        },
      );

      if (!response.data['success']) {
        throw response.data['message'] ??
            'Erreur lors de la mise à jour du statut';
      }
    } catch (e) {
      print('[DeliveryService] Error updating status: $e');
      throw 'Erreur lors de la mise à jour du statut';
    }
  }

  static Future<Map<String, dynamic>> getDeliveryStats({
    DateTime? date,
  }) async {
    try {
      final queryParams = {
        if (date != null) 'date': date.toIso8601String(),
      };

      final response = await _api.get(
        '$_baseUrl/stats',
        queryParameters: queryParams,
      );

      if (!response.data['success']) {
        throw response.data['message'] ??
            'Erreur lors de la récupération des statistiques';
      }

      return response.data['data'];
    } catch (e) {
      print('[DeliveryService] Error getting stats: $e');
      throw 'Erreur lors de la récupération des statistiques';
    }
  }
}
