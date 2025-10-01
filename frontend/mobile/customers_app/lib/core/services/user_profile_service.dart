import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/storage_service.dart';
import '../../constants.dart';

/// 👤 Service de Profil Utilisateur - Alpha Client App
///
/// Gère les opérations sur le profil utilisateur avec le backend Alpha Pressing
/// Référence: backend/src/routes/user.routes.ts
class UserProfileService {
  /// 👤 Récupérer le profil utilisateur complet
  /// Endpoint: GET /api/users/profile
  Future<User?> getUserProfile() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.url('/users/profile')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user'] ?? data);

        // Sauvegarder localement
        await StorageService.saveUser(user);

        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            error['error'] ?? 'Erreur lors de la récupération du profil');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// ✏️ Mettre à jour le profil utilisateur
  /// Endpoint: PUT /api/users/profile
  Future<UserProfileResult> updateUserProfile(
      UpdateUserProfileRequest request) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http
          .put(
            Uri.parse(ApiConfig.url('/users/profile')),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(data['user'] ?? data);

        // Sauvegarder localement
        await StorageService.saveUser(updatedUser);

        return UserProfileResult.success(
          user: updatedUser,
          message: data['message'] ?? 'Profil mis à jour avec succès',
        );
      } else {
        return UserProfileResult.error(
            data['error'] ?? 'Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      return UserProfileResult.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🔒 Changer le mot de passe
  /// Endpoint: PUT /api/users/change-password
  Future<UserProfileResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http
          .put(
            Uri.parse(ApiConfig.url('/users/change-password')),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return UserProfileResult.success(
          message: data['message'] ?? 'Mot de passe modifié avec succès',
        );
      } else {
        return UserProfileResult.error(
            data['error'] ?? 'Erreur lors du changement de mot de passe');
      }
    } catch (e) {
      return UserProfileResult.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 🔔 Mettre à jour les préférences de notification
  /// Endpoint: PUT /api/users/notification-preferences
  Future<UserProfileResult> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http
          .put(
            Uri.parse(ApiConfig.url('/users/notification-preferences')),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(preferences.toJson()),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return UserProfileResult.success(
          message: data['message'] ?? 'Préférences mises à jour avec succès',
        );
      } else {
        return UserProfileResult.error(
            data['error'] ?? 'Erreur lors de la mise à jour des préférences');
      }
    } catch (e) {
      return UserProfileResult.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 📊 Récupérer les statistiques utilisateur
  /// Endpoint: GET /api/users/stats
  Future<UserStats?> getUserStats() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.url('/users/stats')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserStats.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// 🗑️ Supprimer le compte utilisateur
  /// Endpoint: DELETE /api/users/account
  Future<UserProfileResult> deleteAccount(String password) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http
          .delete(
            Uri.parse(ApiConfig.url('/users/account')),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Nettoyer les données locales
        await StorageService.clearUser();
        await StorageService.clearToken();

        return UserProfileResult.success(
          message: data['message'] ?? 'Compte supprimé avec succès',
        );
      } else {
        return UserProfileResult.error(
            data['error'] ?? 'Erreur lors de la suppression du compte');
      }
    } catch (e) {
      return UserProfileResult.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 📱 Mettre à jour le token de notification push
  /// Endpoint: PUT /api/users/push-token
  Future<bool> updatePushToken(String pushToken) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http
          .put(
            Uri.parse(ApiConfig.url('/users/push-token')),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'pushToken': pushToken,
            }),
          )
          .timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// 📋 Résultat d'opération sur le profil utilisateur
class UserProfileResult {
  final bool isSuccess;
  final User? user;
  final String? message;
  final String? error;

  UserProfileResult._({
    required this.isSuccess,
    this.user,
    this.message,
    this.error,
  });

  /// ✅ Résultat de succès
  factory UserProfileResult.success({
    User? user,
    String? message,
  }) {
    return UserProfileResult._(
      isSuccess: true,
      user: user,
      message: message ?? 'Opération réussie',
    );
  }

  /// ❌ Résultat d'erreur
  factory UserProfileResult.error(String error) {
    return UserProfileResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// 🎯 DTO pour mise à jour du profil
class UpdateUserProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;

  UpdateUserProfileRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.gender,
  });

  /// ✅ Vérifier si au moins un champ est modifié
  bool get hasChanges {
    return firstName != null ||
        lastName != null ||
        phone != null ||
        email != null ||
        dateOfBirth != null ||
        gender != null;
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (firstName != null) json['firstName'] = firstName!.trim();
    if (lastName != null) json['lastName'] = lastName!.trim();
    if (phone != null) json['phone'] = phone!.trim();
    if (email != null) json['email'] = email!.trim();
    if (dateOfBirth != null)
      json['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (gender != null) json['gender'] = gender;

    return json;
  }
}

/// 🔔 Préférences de notification
class NotificationPreferences {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool orderUpdates;
  final bool promotionalOffers;
  final bool loyaltyUpdates;

  NotificationPreferences({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.orderUpdates = true,
    this.promotionalOffers = true,
    this.loyaltyUpdates = true,
  });

  /// 📊 Conversion depuis JSON
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? false,
      orderUpdates: json['orderUpdates'] ?? true,
      promotionalOffers: json['promotionalOffers'] ?? true,
      loyaltyUpdates: json['loyaltyUpdates'] ?? true,
    );
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
      'orderUpdates': orderUpdates,
      'promotionalOffers': promotionalOffers,
      'loyaltyUpdates': loyaltyUpdates,
    };
  }

  /// 🔄 Copie avec modifications
  NotificationPreferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? orderUpdates,
    bool? promotionalOffers,
    bool? loyaltyUpdates,
  }) {
    return NotificationPreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      loyaltyUpdates: loyaltyUpdates ?? this.loyaltyUpdates,
    );
  }
}

/// 📊 Statistiques utilisateur
class UserStats {
  final int totalOrders;
  final double totalSpent;
  final int loyaltyPoints;
  final String loyaltyTier;
  final int addressesCount;
  final DateTime? lastOrderDate;
  final String? favoriteService;

  UserStats({
    required this.totalOrders,
    required this.totalSpent,
    required this.loyaltyPoints,
    required this.loyaltyTier,
    required this.addressesCount,
    this.lastOrderDate,
    this.favoriteService,
  });

  /// 📊 Conversion depuis JSON
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      loyaltyTier: json['loyaltyTier'] ?? 'Bronze',
      addressesCount: json['addressesCount'] ?? 0,
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.parse(json['lastOrderDate'])
          : null,
      favoriteService: json['favoriteService'],
    );
  }
}
