import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/order.dart';
import '../widgets/order/recurrence_selection.dart';

class OrderService {
  final Dio _dio;

  OrderService(this._dio);

  Future<Order> createOrder({
    required String serviceId,
    required String addressId,
    required DateTime collectionDate,
    required DateTime deliveryDate,
    required List<Map<String, dynamic>> items,
    TimeOfDay? collectionTime,
    TimeOfDay? deliveryTime,
    String? affiliateCode,
    bool isRecurring = false,
    RecurrenceType? recurrenceType,
  }) async {
    try {
      print('🔵 [OrderService] Début de createOrder');
      print('🔵 [OrderService] Paramètres reçus:');
      print('  - serviceId: $serviceId');
      print('  - addressId: $addressId');
      print('  - collectionDate: $collectionDate');
      print('  - deliveryDate: $deliveryDate');
      print('  - items: $items');
      print('  - collectionTime: $collectionTime');
      print('  - deliveryTime: $deliveryTime');
      print('  - recurrenceType: $recurrenceType');

      // Garantir que les valeurs de récurrence correspondent exactement au backend
      final String recurrenceTypeStr = recurrenceType != null
          ? switch (recurrenceType) {
              RecurrenceType.none => 'NONE',
              RecurrenceType.weekly => 'WEEKLY',
              RecurrenceType.biweekly => 'BIWEEKLY',
              RecurrenceType.monthly => 'MONTHLY',
            }
          : 'NONE';

      print('🔵 [OrderService] RecurrenceType converti: $recurrenceTypeStr');

      final requestData = {
        'serviceId': serviceId,
        'addressId': addressId,
        'collectionDate': collectionDate.toIso8601String(),
        'deliveryDate': deliveryDate.toIso8601String(),
        'collectionTime': collectionTime != null
            ? '${collectionTime.hour.toString().padLeft(2, '0')}:${collectionTime.minute.toString().padLeft(2, '0')}'
            : null,
        'deliveryTime': deliveryTime != null
            ? '${deliveryTime.hour.toString().padLeft(2, '0')}:${deliveryTime.minute.toString().padLeft(2, '0')}'
            : null,
        'items': items,
        'affiliateCode': affiliateCode,
        'isRecurring': recurrenceType != RecurrenceType.none,
        'recurrenceType': recurrenceTypeStr,
      };

      print('🔵 [OrderService] Données de requête préparées:');
      print(requestData);

      print('🔵 [OrderService] Envoi de la requête à l\'API...');
      final response = await _dio.post(
        '/api/orders',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) =>
              true, // Pour voir tous les codes de statut
        ),
      );

      print('🔵 [OrderService] Réponse reçue:');
      print('  - Status code: ${response.statusCode}');
      print('  - Data: ${response.data}');

      // Modifié ici : accepter 200 ou 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['data'] != null) {
          print('✅ [OrderService] Commande créée avec succès');
          return Order.fromJson(response.data['data']);
        }
      }

      // Si on arrive ici, c'est qu'il y a une erreur
      print('❌ [OrderService] Échec de la création de commande:');
      print('  - Status code: ${response.statusCode}');
      print('  - Error message: ${response.data['error'] ?? 'Unknown error'}');
      throw Exception(response.data['error'] ?? 'Failed to create order');
    } catch (e, stackTrace) {
      print('❌ [OrderService] Exception détaillée:');
      print('  - Error: $e');
      print('  - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<double> calculateTotal({
    required String serviceId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _dio.post('/api/orders/calculate', data: {
        'serviceId': serviceId,
        'items': items,
      });

      if (response.statusCode == 200) {
        return (response.data['data']['total'] as num).toDouble();
      }

      throw Exception(response.data['message'] ?? 'Failed to calculate total');
    } catch (e) {
      throw Exception('Error calculating total: $e');
    }
  }
}
