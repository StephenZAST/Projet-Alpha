import 'dart:convert';
import 'package:get/get.dart';
import '../models/order_map.dart';
import 'api_service.dart';

class OrderMapService {
  static final ApiService _apiService = Get.find<ApiService>();

  /// Récupère les commandes pour affichage sur carte
  static Future<OrderMapResponse> getOrdersForMap({
    String? status,
    String? startDate,
    String? endDate,
    String? collectionDateStart,
    String? collectionDateEnd,
    String? deliveryDateStart,
    String? deliveryDateEnd,
    bool? isFlashOrder,
    String? serviceTypeId,
    String? paymentMethod,
    String? city,
    String? postalCode,
    MapBounds? bounds,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }
      if (collectionDateStart != null && collectionDateStart.isNotEmpty) {
        queryParams['collectionDateStart'] = collectionDateStart;
      }
      if (collectionDateEnd != null && collectionDateEnd.isNotEmpty) {
        queryParams['collectionDateEnd'] = collectionDateEnd;
      }
      if (deliveryDateStart != null && deliveryDateStart.isNotEmpty) {
        queryParams['deliveryDateStart'] = deliveryDateStart;
      }
      if (deliveryDateEnd != null && deliveryDateEnd.isNotEmpty) {
        queryParams['deliveryDateEnd'] = deliveryDateEnd;
      }
      if (isFlashOrder != null) {
        queryParams['isFlashOrder'] = isFlashOrder.toString();
      }
      if (serviceTypeId != null && serviceTypeId.isNotEmpty && serviceTypeId != 'all') {
        queryParams['serviceTypeId'] = serviceTypeId;
      }
      if (paymentMethod != null && paymentMethod.isNotEmpty && paymentMethod != 'all') {
        queryParams['paymentMethod'] = paymentMethod;
      }
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (postalCode != null && postalCode.isNotEmpty) {
        queryParams['postalCode'] = postalCode;
      }
      if (bounds != null) {
        queryParams['bounds'] = jsonEncode(bounds.toJson());
      }

      print('[OrderMapService] Getting orders for map with params: $queryParams');

      final response = await _apiService.get(
        '/orders/map/orders',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          try {
            return OrderMapResponse.fromJson(data['data']);
          } catch (parseError) {
            print('[OrderMapService] JSON parsing error: $parseError');
            print('[OrderMapService] Raw data: ${data['data']}');
            throw Exception('Erreur de parsing des données: $parseError');
          }
        } else {
          throw Exception(data['error'] ?? 'Erreur lors de la récupération des commandes pour la carte');
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      print('[OrderMapService] Error getting orders for map: $e');
      rethrow;
    }
  }

  /// Récupère les statistiques géographiques des commandes
  static Future<OrderGeoStats> getOrdersGeoStats({
    String? status,
    String? startDate,
    String? endDate,
    bool? isFlashOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }
      if (isFlashOrder != null) {
        queryParams['isFlashOrder'] = isFlashOrder.toString();
      }

      print('[OrderMapService] Getting geo stats with params: $queryParams');

      final response = await _apiService.get(
        '/orders/map/stats',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return OrderGeoStats.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Erreur lors de la récupération des statistiques géographiques');
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      print('[OrderMapService] Error getting geo stats: $e');
      rethrow;
    }
  }

  /// Récupère les commandes dans une zone géographique spécifique
  static Future<OrderMapResponse> getOrdersInBounds({
    required MapBounds bounds,
    String? status,
    bool? isFlashOrder,
  }) async {
    return getOrdersForMap(
      bounds: bounds,
      status: status,
      isFlashOrder: isFlashOrder,
    );
  }

  /// Récupère les commandes par ville
  static Future<OrderMapResponse> getOrdersByCity({
    required String city,
    String? status,
    bool? isFlashOrder,
  }) async {
    return getOrdersForMap(
      city: city,
      status: status,
      isFlashOrder: isFlashOrder,
    );
  }

  /// Récupère les commandes par code postal
  static Future<OrderMapResponse> getOrdersByPostalCode({
    required String postalCode,
    String? status,
    bool? isFlashOrder,
  }) async {
    return getOrdersForMap(
      postalCode: postalCode,
      status: status,
      isFlashOrder: isFlashOrder,
    );
  }
}