import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/flash_order.dart';
import '../utils/storage_service.dart';
import '../../constants.dart';

/// ⚡ Service de Commande Flash - Alpha Client App
///
/// Gère les commandes flash avec le backend Alpha Pressing
/// Référence: backend/docs/REFERENCE_ARTICLE_SERVICE.md - Flash Orders
class FlashOrderService {
  /// ⚡ Créer une commande flash (DRAFT)
  /// Endpoint: POST /api/orders/flash
  ///
  /// Crée une commande flash en mode brouillon avec seulement l'adresse et les notes.
  /// Les admins complèteront ensuite la commande avec les articles.
  Future<FlashOrderResult> createFlashOrder(FlashOrder flashOrder) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return FlashOrderResult.error('Token d\'authentification manquant');
      }

      // 🎯 Récupérer l'adresse par défaut de l'utilisateur
      final defaultAddress = await _getDefaultAddress(token);
      if (defaultAddress == null) {
        return FlashOrderResult.error(
            'Aucune adresse par défaut configurée. Veuillez configurer une adresse dans votre profil.');
      }

      // 📦 Préparer les données pour le backend (format simplifié)
      final requestBody = {
        'addressId': defaultAddress['id'],
        'notes': flashOrder.notes ??
            'Commande flash créée depuis l\'application mobile',
      };

      debugPrint(
          '🚀 [FlashOrderService] Creating flash order with data: $requestBody');

      final response = await http
          .post(
            Uri.parse(ApiConfig.url('/orders/flash')),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.timeout);

      debugPrint(
          '📊 [FlashOrderService] Response status: ${response.statusCode}');
      debugPrint('📦 [FlashOrderService] Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // ✅ Succès - Créer le résultat
        final orderData = data['data'];

        return FlashOrderResult.success(
          orderId: orderData['id'],
          orderReference: orderData['orderReference'] ??
              'FLASH-${orderData['id'].substring(0, 8).toUpperCase()}',
          message:
              'Votre commande flash a été créée avec succès ! Notre équipe va la traiter rapidement.',
        );
      } else {
        return FlashOrderResult.error(data['error'] ??
            data['message'] ??
            'Erreur lors de la création de la commande flash');
      }
    } catch (e) {
      debugPrint('❌ [FlashOrderService] Error: $e');
      return FlashOrderResult.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 📍 Récupérer l'adresse par défaut de l'utilisateur
  Future<Map<String, dynamic>?> _getDefaultAddress(String token) async {
    try {
      debugPrint('🔍 [FlashOrderService] Fetching addresses...');

      final response = await http.get(
        Uri.parse(ApiConfig.url('/addresses/all')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      debugPrint(
          '📊 [FlashOrderService] Addresses response status: ${response.statusCode}');
      debugPrint(
          '📦 [FlashOrderService] Addresses response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> addresses =
            data is List ? data : (data['data'] ?? []);

        debugPrint(
            '📍 [FlashOrderService] Found ${addresses.length} addresses');

        // Afficher toutes les adresses pour debug
        for (var i = 0; i < addresses.length; i++) {
          final addr = addresses[i];
          debugPrint(
              '   Address $i: id=${addr['id']}, isDefault=${addr['isDefault']}, is_default=${addr['is_default']}, label=${addr['label']}');
        }

        // Chercher l'adresse par défaut (vérifier plusieurs formats)
        Map<String, dynamic>? defaultAddress;
        for (var address in addresses) {
          if (address['isDefault'] == true ||
              address['is_default'] == true ||
              address['isDefault'] == 1 ||
              address['is_default'] == 1) {
            defaultAddress = address;
            debugPrint(
                '✅ [FlashOrderService] Found default address: ${address['id']} - ${address['label']}');
            break;
          }
        }

        // Si pas d'adresse par défaut, prendre la première
        if (defaultAddress == null && addresses.isNotEmpty) {
          defaultAddress = addresses.first;
          debugPrint(
              '⚠️ [FlashOrderService] No default address found, using first address: ${defaultAddress?['id']} - ${defaultAddress?['label']}');
        }

        if (defaultAddress == null) {
          debugPrint('❌ [FlashOrderService] No addresses found at all');
        }

        return defaultAddress;
      } else {
        debugPrint(
            '❌ [FlashOrderService] Failed to fetch addresses: ${response.statusCode}');
        debugPrint('   Response: ${response.body}');
      }

      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ [FlashOrderService] Error fetching default address: $e');
      debugPrint('   Stack trace: $stackTrace');
      return null;
    }
  }

  /// 📋 Récupérer les articles populaires pour commande flash
  /// Endpoint: GET /api/orders/flash/popular-items
  Future<List<PopularFlashItem>> getPopularFlashItems() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return _getDefaultPopularItems();
      }

      final response = await http.get(
        Uri.parse(ApiConfig.url('/orders/flash/popular-items')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsJson = data['items'] ?? [];

        return itemsJson
            .map((json) => PopularFlashItem.fromJson(json))
            .toList();
      } else {
        // Fallback vers les items par défaut
        return _getDefaultPopularItems();
      }
    } catch (e) {
      // En cas d'erreur, retourner les items par défaut
      return _getDefaultPopularItems();
    }
  }

  /// 💰 Estimer le prix d'une commande flash
  /// Endpoint: POST /api/orders/flash/estimate
  Future<double?> estimateFlashOrderPrice(FlashOrder flashOrder) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;

      final response = await http
          .post(
            Uri.parse(ApiConfig.url('/orders/flash/estimate')),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(flashOrder.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['estimatedPrice'] ?? 0).toDouble();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 📊 Récupérer l'historique des commandes flash
  /// Endpoint: GET /api/orders/flash/history
  Future<List<FlashOrderResult>> getFlashOrderHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(
            ApiConfig.url('/orders/flash/history?page=$page&limit=$limit')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ordersJson = data['orders'] ?? [];

        return ordersJson
            .map((json) => FlashOrderResult.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// 🔍 Vérifier le statut d'une commande flash
  /// Endpoint: GET /api/orders/flash/:orderId/status
  Future<FlashOrderStatus?> getFlashOrderStatus(String orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConfig.url('/orders/flash/$orderId/status')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final statusString = data['status']?.toString().toLowerCase();

        return FlashOrderStatus.values.firstWhere(
          (status) => status.name.toLowerCase() == statusString,
          orElse: () => FlashOrderStatus.draft,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// ❌ Annuler une commande flash (si en statut draft)
  /// Endpoint: DELETE /api/orders/flash/:orderId
  Future<bool> cancelFlashOrder(String orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse(ApiConfig.url('/orders/flash/$orderId')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 💾 Sauvegarder un brouillon de commande flash
  Future<void> saveDraftFlashOrder(FlashOrder flashOrder) async {
    final draftData = {
      'flashOrder': flashOrder.toJson(),
      'savedAt': DateTime.now().toIso8601String(),
    };

    await StorageService.saveAppSettings({
      ...await StorageService.getAppSettings() ?? {},
      'flashOrderDraft': draftData,
    });
  }

  /// 📥 Récupérer le brouillon de commande flash
  Future<FlashOrder?> getDraftFlashOrder() async {
    try {
      final settings = await StorageService.getAppSettings();
      final draftData = settings?['flashOrderDraft'];

      if (draftData != null && draftData['flashOrder'] != null) {
        final flashOrderJson = draftData['flashOrder'];
        final items = (flashOrderJson['items'] as List<dynamic>)
            .map((item) => FlashOrderItem.fromJson(item))
            .toList();

        return FlashOrder(
          items: items,
          pickupAddressId: flashOrderJson['pickupAddressId'],
          deliveryAddressId: flashOrderJson['deliveryAddressId'],
          notes: flashOrderJson['notes'],
          preferredPickupDate: flashOrderJson['preferredPickupDate'] != null
              ? DateTime.parse(flashOrderJson['preferredPickupDate'])
              : null,
          preferredDeliveryDate: flashOrderJson['preferredDeliveryDate'] != null
              ? DateTime.parse(flashOrderJson['preferredDeliveryDate'])
              : null,
          useDefaultAddresses: flashOrderJson['useDefaultAddresses'] ?? true,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 🗑️ Supprimer le brouillon de commande flash
  Future<void> clearDraftFlashOrder() async {
    final settings = await StorageService.getAppSettings() ?? {};
    settings.remove('flashOrderDraft');
    await StorageService.saveAppSettings(settings);
  }

  /// 🎯 Articles populaires par défaut (fallback)
  List<PopularFlashItem> _getDefaultPopularItems() {
    return [
      PopularFlashItem(
        articleId: 'default_shirt',
        articleName: 'Chemise',
        serviceId: 'default_dry_clean',
        serviceName: 'Nettoyage à sec',
        serviceTypeId: 'default_standard',
        serviceTypeName: 'Standard',
        basePrice: 8.0,
        iconName: 'checkroom',
        color: const Color(0xFF10B981),
        isPopular: true,
      ),
      PopularFlashItem(
        articleId: 'default_pants',
        articleName: 'Pantalon',
        serviceId: 'default_dry_clean',
        serviceName: 'Nettoyage à sec',
        serviceTypeId: 'default_standard',
        serviceTypeName: 'Standard',
        basePrice: 10.0,
        iconName: 'checkroom_outlined',
        color: const Color(0xFFF59E0B),
        isPopular: true,
      ),
      PopularFlashItem(
        articleId: 'default_suit',
        articleName: 'Costume',
        serviceId: 'default_dry_clean',
        serviceName: 'Nettoyage à sec',
        serviceTypeId: 'default_premium',
        serviceTypeName: 'Premium',
        basePrice: 25.0,
        iconName: 'work_outline',
        color: const Color(0xFF3B82F6),
        isPopular: true,
      ),
      PopularFlashItem(
        articleId: 'default_dress',
        articleName: 'Robe',
        serviceId: 'default_dry_clean',
        serviceName: 'Nettoyage à sec',
        serviceTypeId: 'default_standard',
        serviceTypeName: 'Standard',
        basePrice: 15.0,
        iconName: 'woman',
        color: const Color(0xFF8B5CF6),
        isPopular: false,
      ),
      PopularFlashItem(
        articleId: 'default_jacket',
        articleName: 'Veste',
        serviceId: 'default_dry_clean',
        serviceName: 'Nettoyage à sec',
        serviceTypeId: 'default_standard',
        serviceTypeName: 'Standard',
        basePrice: 18.0,
        iconName: 'checkroom',
        color: const Color(0xFF06B6D4),
        isPopular: false,
      ),
      PopularFlashItem(
        articleId: 'default_coat',
        articleName: 'Manteau',
        serviceId: 'default_dry_clean',
        serviceName: 'Nettoyage à sec',
        serviceTypeId: 'default_premium',
        serviceTypeName: 'Premium',
        basePrice: 30.0,
        iconName: 'checkroom',
        color: const Color(0xFFEF4444),
        isPopular: false,
      ),
    ];
  }

  /// 🔍 Rechercher des articles pour commande flash
  /// Endpoint: GET /api/orders/flash/search-items
  Future<List<PopularFlashItem>> searchFlashItems(String query) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return _getDefaultPopularItems()
            .where((item) =>
                item.articleName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      final response = await http.get(
        Uri.parse(ApiConfig.url(
            '/orders/flash/search-items?q=${Uri.encodeComponent(query)}')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsJson = data['items'] ?? [];

        return itemsJson
            .map((json) => PopularFlashItem.fromJson(json))
            .toList();
      } else {
        // Fallback vers recherche locale
        return _getDefaultPopularItems()
            .where((item) =>
                item.articleName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    } catch (e) {
      // Fallback vers recherche locale
      return _getDefaultPopularItems()
          .where((item) =>
              item.articleName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
