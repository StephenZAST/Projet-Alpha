import 'package:affiliate_app/constants.dart';

import '../models/affiliate_profile.dart';
import '../services/api_service.dart';

/// 👤 Service Profil - Alpha Affiliate App
///
/// Gère les opérations liées au profil utilisateur

class ProfileService {
  static final ApiService _apiService = ApiService();

  /// 📝 Mettre à jour le profil utilisateur
  /// PUT /api/affiliate/profile
  static Future<ApiResponse<AffiliateProfile>> updateProfile({
    String? phone,
    Map<String, dynamic>? notificationPreferences,
  }) async {
    final data = <String, dynamic>{};

    if (phone != null) data['phone'] = phone;
    if (notificationPreferences != null) {
      data['notificationPreferences'] = notificationPreferences;
    }

    final response = await _apiService.put<Map<String, dynamic>>(
      '${ApiConfig.affiliateEndpoint}/profile',
      data: data,
    );

    return response.map((data) {
      if (data['success'] == true && data['data'] != null) {
        return AffiliateProfile.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Format de réponse invalide');
    });
  }

  /// 🔔 Mettre à jour les préférences de notification
  /// PUT /api/affiliate/profile
  static Future<ApiResponse<bool>> updateNotificationPreferences({
    bool? email,
    bool? push,
    bool? sms,
    bool? orderUpdates,
    bool? commissionUpdates,
    bool? withdrawalUpdates,
    bool? promotions,
    bool? levelUpdates,
    bool? referralUpdates,
  }) async {
    final preferences = <String, dynamic>{};

    if (email != null) preferences['email'] = email;
    if (push != null) preferences['push'] = push;
    if (sms != null) preferences['sms'] = sms;
    if (orderUpdates != null) preferences['order_updates'] = orderUpdates;
    if (commissionUpdates != null)
      preferences['commission_updates'] = commissionUpdates;
    if (withdrawalUpdates != null)
      preferences['withdrawal_updates'] = withdrawalUpdates;
    if (promotions != null) preferences['promotions'] = promotions;
    if (levelUpdates != null) preferences['level_updates'] = levelUpdates;
    if (referralUpdates != null)
      preferences['referral_updates'] = referralUpdates;

    final response = await _apiService.put<Map<String, dynamic>>(
      '${ApiConfig.affiliateEndpoint}/profile',
      data: {
        'notificationPreferences': preferences,
      },
    );

    return response.map((data) {
      return data['success'] == true;
    });
  }

  /// 📱 Mettre à jour le numéro de téléphone
  /// PUT /api/affiliate/profile
  static Future<ApiResponse<bool>> updatePhoneNumber(String phone) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '${ApiConfig.affiliateEndpoint}/profile',
      data: {
        'phone': phone,
      },
    );

    return response.map((data) {
      return data['success'] == true;
    });
  }

  /// 🔐 Changer le mot de passe
  /// PUT /api/auth/change-password
  static Future<ApiResponse<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    return response.map((data) {
      return data['success'] == true;
    });
  }

  /// 📊 Récupérer les statistiques du profil
  /// GET /api/affiliate/profile/stats
  static Future<ApiResponse<Map<String, dynamic>>> getProfileStats() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.affiliateEndpoint}/profile/stats',
    );

    return response.map((data) {
      if (data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    });
  }

  /// 🗑️ Supprimer le compte
  /// DELETE /api/affiliate/profile
  static Future<ApiResponse<bool>> deleteAccount({
    required String password,
    String? reason,
  }) async {
    final response = await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.affiliateEndpoint}/profile',
      data: {
        'password': password,
        if (reason != null) 'reason': reason,
      },
    );

    return response.map((data) {
      return data['success'] == true;
    });
  }

  /// 📤 Exporter les données du profil
  /// GET /api/affiliate/profile/export
  static Future<ApiResponse<Map<String, dynamic>>> exportProfileData() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.affiliateEndpoint}/profile/export',
    );

    return response.map((data) {
      if (data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    });
  }

  /// 🔄 Synchroniser le profil
  /// GET /api/affiliate/profile/sync
  static Future<ApiResponse<AffiliateProfile>> syncProfile() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.affiliateEndpoint}/profile/sync',
    );

    return response.map((data) {
      if (data['success'] == true && data['data'] != null) {
        return AffiliateProfile.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Format de réponse invalide');
    });
  }
}
