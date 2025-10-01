import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address.dart';
import '../utils/storage_service.dart';
import '../../constants.dart';

/// 🏠 Service de Gestion des Adresses - Alpha Client App
///
/// Gère les adresses utilisateur avec le backend Alpha Pressing
/// Référence: backend/src/routes/address.routes.ts
class AddressService {
  /// 📋 Récupérer toutes les adresses de l'utilisateur
  /// Endpoint: GET /api/addresses/all
  Future<AddressList> getAllAddresses() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.url('/addresses/all')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AddressList.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            error['error'] ?? 'Erreur lors de la récupération des adresses');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// ➕ Créer une nouvelle adresse
  /// Endpoint: POST /api/addresses/create
  Future<AddressResult> createAddress(CreateAddressRequest request) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      if (!request.isValid) {
        throw Exception('Données d\'adresse invalides');
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.url('/addresses/create')),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddressResult.fromJson(data);
      } else {
        return AddressResult.error(
            data['error'] ?? 'Erreur lors de la création de l\'adresse');
      }
    } catch (e) {
      return AddressResult.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// ✏️ Mettre à jour une adresse
  /// Endpoint: PATCH /api/addresses/update/:addressId
  Future<AddressResult> updateAddress(
      String addressId, UpdateAddressRequest request) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      if (!request.hasChanges) {
        throw Exception('Aucune modification détectée');
      }

      final response = await http
          .patch(
            Uri.parse(ApiConfig.url('/addresses/update/$addressId')),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AddressResult.fromJson(data);
      } else {
        return AddressResult.error(
            data['error'] ?? 'Erreur lors de la mise à jour de l\'adresse');
      }
    } catch (e) {
      return AddressResult.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🗑️ Supprimer une adresse
  /// Endpoint: DELETE /api/addresses/delete/:addressId
  Future<AddressResult> deleteAddress(String addressId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.url('/addresses/delete/$addressId')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return AddressResult.success(
          message: 'Adresse supprimée avec succès',
        );
      } else {
        final data = jsonDecode(response.body);
        return AddressResult.error(
            data['error'] ?? 'Erreur lors de la suppression de l\'adresse');
      }
    } catch (e) {
      return AddressResult.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🏠 Définir une adresse comme par défaut
  /// Endpoint: PATCH /api/addresses/update/:addressId
  Future<AddressResult> setDefaultAddress(String addressId) async {
    try {
      final request = UpdateAddressRequest(isDefault: true);
      return await updateAddress(addressId, request);
    } catch (e) {
      return AddressResult.error(
          'Erreur lors de la définition de l\'adresse par défaut: ${e.toString()}');
    }
  }

  /// 📍 Récupérer les adresses d'un utilisateur spécifique (Admin)
  /// Endpoint: GET /api/addresses/user/:userId
  Future<AddressList> getAddressesByUserId(String userId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.url('/addresses/user/$userId')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AddressList.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            error['error'] ?? 'Erreur lors de la récupération des adresses');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🔍 Valider une adresse avec un service externe (Future)
  Future<bool> validateAddress(CreateAddressRequest request) async {
    try {
      // TODO: Intégrer avec un service de validation d'adresses (Google Maps, etc.)
      // Pour l'instant, validation basique
      return request.isValid;
    } catch (e) {
      return false;
    }
  }

  /// 🗺️ Géocoder une adresse (Future)
  Future<Map<String, double>?> geocodeAddress(String fullAddress) async {
    try {
      // TODO: Intégrer avec un service de géocodage (Google Maps, etc.)
      // Pour l'instant, retourner null
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 📊 Obtenir des suggestions d'adresses (Future)
  Future<List<String>> getAddressSuggestions(String query) async {
    try {
      // TODO: Intégrer avec un service d'autocomplétion d'adresses
      // Pour l'instant, retourner une liste vide
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 💾 Sauvegarder une adresse en brouillon localement
  Future<void> saveDraftAddress(CreateAddressRequest request) async {
    final draftData = {
      'address': request.toJson(),
      'savedAt': DateTime.now().toIso8601String(),
    };

    await StorageService.saveAppSettings({
      ...await StorageService.getAppSettings() ?? {},
      'addressDraft': draftData,
    });
  }

  /// 📥 Récupérer le brouillon d'adresse
  Future<CreateAddressRequest?> getDraftAddress() async {
    try {
      final settings = await StorageService.getAppSettings();
      final draftData = settings?['addressDraft'];

      if (draftData != null && draftData['address'] != null) {
        final addressJson = draftData['address'];
        return CreateAddressRequest(
          name: addressJson['name'] ?? '',
          street: addressJson['street'] ?? '',
          city: addressJson['city'] ?? '',
          postalCode: addressJson['postal_code'] ?? '',
          gpsLatitude: addressJson['gps_latitude']?.toDouble(),
          gpsLongitude: addressJson['gps_longitude']?.toDouble(),
          isDefault: addressJson['is_default'] ?? false,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 🗑️ Supprimer le brouillon d'adresse
  Future<void> clearDraftAddress() async {
    final settings = await StorageService.getAppSettings() ?? {};
    settings.remove('addressDraft');
    await StorageService.saveAppSettings(settings);
  }

  /// 📊 Statistiques d'utilisation des adresses (Future)
  Future<Map<String, dynamic>> getAddressStats() async {
    try {
      final addresses = await getAllAddresses();

      return {
        'totalAddresses': addresses.total,
        'hasDefaultAddress': addresses.hasDefaultAddress,
        'addressesWithGPS': addresses.addresses
            .where((address) => address.hasGpsCoordinates)
            .length,
        'citiesCount':
            addresses.addresses.map((address) => address.city).toSet().length,
      };
    } catch (e) {
      return {
        'totalAddresses': 0,
        'hasDefaultAddress': false,
        'addressesWithGPS': 0,
        'citiesCount': 0,
      };
    }
  }
}
