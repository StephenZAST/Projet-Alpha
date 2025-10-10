import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../models/user.dart';
import '../utils/storage_service.dart';
import 'api_service.dart';

/// 👤 Service de Profil Utilisateur - Alpha Client App
///
/// Service simplifié basé sur les endpoints backend disponibles
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  /// 👤 Récupérer le profil utilisateur depuis le cache
  /// L'endpoint /user/profile n'est pas disponible, on utilise le cache
  Future<User> getUserProfile() async {
    try {
      // Essayer de récupérer depuis le cache d'abord
      final cachedUser = await StorageService.getUser();
      if (cachedUser != null) {
        print('[UserProfileService] Profil récupéré depuis le cache');
        return cachedUser;
      }

      // Si pas de cache, créer un utilisateur par défaut
      // (en attendant que l'endpoint soit disponible)
      throw Exception(
          'Aucun profil utilisateur en cache. Veuillez vous reconnecter.');
    } catch (e) {
      print('[UserProfileService] Erreur getUserProfile: $e');
      throw Exception('Erreur de récupération du profil: ${e.toString()}');
    }
  }

  /// 📊 Récupérer les statistiques utilisateur basiques
  Future<UserStats> getUserStats() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      // Récupérer les points de fidélité depuis /loyalty/points-balance (backend)
      int loyaltyPoints = 0;
      try {
        final loyaltyResponse = await http.get(
          Uri.parse(ApiConfig.url('/loyalty/points-balance')),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(ApiConfig.timeout);

        print(
            '[UserProfileService] loyalty status: ${loyaltyResponse.statusCode} body: ${loyaltyResponse.body}');

        if (loyaltyResponse.statusCode == 200) {
          final loyaltyData = jsonDecode(loyaltyResponse.body);
          if (loyaltyData['data'] != null) {
            loyaltyPoints = loyaltyData['data']['pointsBalance'] ?? 0;
          }
        }
      } catch (e) {
        print('[UserProfileService] Erreur récupération points: $e');
      }

      // Récupérer les adresses depuis /addresses/all (backend)
      int addressCount = 0;

      // Préparer les métriques de commandes récentes (3 derniers mois)
      int recentOrdersCount = 0;
      double recentTotalSpent = 0.0;
      try {
        final addressesResponse = await http.get(
          Uri.parse(ApiConfig.url('/addresses/all')),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(ApiConfig.timeout);
        print(
            '[UserProfileService] addresses status: ${addressesResponse.statusCode} body: ${addressesResponse.body}');

        if (addressesResponse.statusCode == 200) {
          final addressesData = jsonDecode(addressesResponse.body);

          // Gérer plusieurs formats de réponse possibles :
          // 1) Une liste brute : [ {..}, {..} ]
          // 2) Un objet { data: [...] }
          // 3) Un objet { success: true, data: [...] }
          if (addressesData is List) {
            addressCount = addressesData.length;
          } else if (addressesData is Map) {
            if (addressesData['data'] is List) {
              addressCount = (addressesData['data'] as List).length;
            } else if (addressesData['addresses'] is List) {
              // fallback clé alternative
              addressCount = (addressesData['addresses'] as List).length;
            } else if (addressesData['total'] is int) {
              // parfois l'API peut renvoyer un total séparé
              addressCount = addressesData['total'] as int;
            }
          }

          // Récupérer les commandes des 3 derniers mois et calculer total et nombre
          try {
            final now = DateTime.now();
            final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

            final api = ApiService();
            final ordersResp = await api.get(
              '/orders/my-orders',
              queryParameters: {
                'startDate': threeMonthsAgo.toIso8601String(),
                'endDate': now.toIso8601String(),
                'limit': 1000,
              },
            );

            print(
                '[UserProfileService] ordersResp for period: $threeMonthsAgo -> $now : $ordersResp');

            if (ordersResp['success'] == true && ordersResp['data'] != null) {
              final ordersList = ordersResp['data'] as List;
              recentOrdersCount = ordersList.length;

              for (final o in ordersList) {
                final status = (o['status'] ?? '').toString().toUpperCase();
                // Considérer uniquement les commandes livrées pour le total dépensé
                if (status == 'DELIVERED' ||
                    status == 'DELIVERED'.toUpperCase()) {
                  final amt =
                      o['totalAmount'] ?? o['total'] ?? o['amount'] ?? 0;
                  final double parsed = amt is num
                      ? amt.toDouble()
                      : double.tryParse(amt.toString()) ?? 0.0;
                  recentTotalSpent += parsed;
                }
              }
            }
          } catch (e) {
            print(
                '[UserProfileService] Erreur récupération commandes récentes: $e');
          }

          print('[UserProfileService] Parsed address count: $addressCount');
        }
      } catch (e) {
        print('[UserProfileService] Erreur récupération adresses: $e');
      }

      return UserStats(
        // totalOrders et totalSpent représentent maintenant les 3 derniers mois
        totalOrders: recentOrdersCount,
        totalSpent: recentTotalSpent,
        loyaltyPoints: loyaltyPoints,
        addressCount: addressCount,
      );
    } catch (e) {
      print('[UserProfileService] Erreur getUserStats: $e');
      // Retourner des statistiques par défaut en cas d'erreur
      return UserStats(
        totalOrders: 0,
        totalSpent: 0.0,
        loyaltyPoints: 0,
        addressCount: 0,
      );
    }
  }

  /// 📝 Mettre à jour le profil utilisateur (basé sur auth.service.ts updateProfile)
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      // Utiliser l'endpoint auth updateProfile
      final response = await http
          .put(
            Uri.parse(ApiConfig.url('/auth/profile')),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'firstName': firstName,
              'lastName': lastName,
              'email': email,
              'phone': phone,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Mettre à jour les données en cache
          if (data['data'] != null) {
            final updatedUser = User.fromJson(data['data']);
            await StorageService.saveUser(updatedUser);
          }
          return true;
        }
      }

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Erreur lors de la mise à jour');
    } catch (e) {
      print('[UserProfileService] Erreur updateProfile: $e');
      throw Exception('Erreur de mise à jour: ${e.toString()}');
    }
  }

  /// 🔒 Changer le mot de passe (basé sur auth.service.ts changePassword)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final uri = Uri.parse(ApiConfig.url('/auth/change-password'));
      final requestBody = jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      print('[UserProfileService] POST $uri');
      print('[UserProfileService] Request body: $requestBody');

      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: requestBody,
          )
          .timeout(ApiConfig.timeout);

      print('[UserProfileService] Response status: ${response.statusCode}');
      print('[UserProfileService] Response body: ${response.body}');

      // Parfois le backend peut renvoyer une page HTML pour 404/500, gérer proprement
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          // Accept either explicit success=true or presence of a data object
          if (data is Map<String, dynamic>) {
            if (data['success'] == true) {
              print('[UserProfileService] changePassword: success=true');
              return true;
            }
            if (data['data'] != null) {
              print(
                  '[UserProfileService] changePassword: data object present -> treating as success');
              return true;
            }
          }
          // No success flag nor data -> treat as failure
          print(
              '[UserProfileService] changePassword: no success/data in JSON -> treating as failure');
          return false;
        } catch (e) {
          // Réponse non JSON mais status OK -> considérer comme succès
          print(
              '[UserProfileService] Non-JSON OK response, treating as success');
          return true;
        }
      }

      // Try to extract JSON error if present
      try {
        final errorData = jsonDecode(response.body);
        final errMsg =
            errorData['error'] ?? errorData['message'] ?? response.body;
        throw Exception(
            'ChangePassword failed: $errMsg (status ${response.statusCode})');
      } catch (e) {
        // If body is not JSON, include raw body for debugging
        throw Exception(
            'ChangePassword failed: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[UserProfileService] Erreur changePassword: $e');
      throw Exception('Erreur de changement de mot de passe: ${e.toString()}');
    }
  }
}

/// 📈 Modèle des statistiques utilisateur (simplifié)
class UserStats {
  final int totalOrders;
  final double totalSpent;
  final int loyaltyPoints;
  final int addressCount;

  UserStats({
    required this.totalOrders,
    required this.totalSpent,
    required this.loyaltyPoints,
    required this.addressCount,
  });

  /// Formatage du montant dépensé en FCFA
  String get formattedTotalSpent {
    return '${totalSpent.toInt().toFormattedString()} FCFA';
  }

  /// Niveau de fidélité basé sur les points
  String get loyaltyTier {
    if (loyaltyPoints >= 10000) return 'PLATINE';
    if (loyaltyPoints >= 5000) return 'OR';
    if (loyaltyPoints >= 1000) return 'ARGENT';
    return 'BRONZE';
  }

  /// Couleur du niveau de fidélité
  String get loyaltyTierColor {
    switch (loyaltyTier) {
      case 'PLATINE':
        return '#E5E7EB'; // Platine
      case 'OR':
        return '#FCD34D'; // Or
      case 'ARGENT':
        return '#D1D5DB'; // Argent
      case 'BRONZE':
        return '#F59E0B'; // Bronze
      default:
        return '#F59E0B';
    }
  }
}
