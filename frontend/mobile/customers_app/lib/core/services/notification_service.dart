import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../utils/storage_service.dart';
import '../../constants.dart';

/// 📲 Service de Notifications - Alpha Client App
///
/// Gère les notifications push, locales et la communication avec le backend
/// Référence: backend/docs/REFERENCE_ARTICLE_SERVICE.md section "Notification"
class NotificationService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// 📋 Récupérer toutes les notifications
  /// Endpoint: GET /api/notifications
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isRead,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (type != null) queryParams['type'] = type;
      if (isRead != null) queryParams['isRead'] = isRead.toString();

      final uri = Uri.parse('$_baseUrl/api/notifications').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notifications = (data['notifications'] as List)
            .map((json) => AppNotification.fromJson(json))
            .toList();
        
        return notifications;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la récupération des notifications');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// 📊 Récupérer le nombre de notifications non lues
  /// Endpoint: GET /api/notifications/unread
  Future<int> getUnreadCount() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('$_baseUrl/api/notifications/unread'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  /// ✅ Marquer une notification comme lue
  /// Endpoint: PATCH /api/notifications/:notificationId/read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/notifications/$notificationId/read'),
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

  /// ✅ Marquer toutes les notifications comme lues
  /// Endpoint: PATCH /api/notifications/mark-all-read
  Future<bool> markAllAsRead() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/notifications/mark-all-read'),
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

  /// 🗑️ Supprimer une notification
  /// Endpoint: DELETE /api/notifications/:notificationId
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/notifications/$notificationId'),
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

  /// ⚙️ Récupérer les préférences de notification
  /// Endpoint: GET /api/notifications/preferences
  Future<NotificationPreferences?> getPreferences() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/api/notifications/preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NotificationPreferences.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// ⚙️ Mettre à jour les préférences de notification
  /// Endpoint: PUT /api/notifications/preferences
  Future<bool> updatePreferences(NotificationPreferences preferences) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/api/notifications/preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(preferences.toJson()),
      ).timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 📱 Enregistrer le token FCM pour les push notifications
  Future<bool> registerFCMToken(String fcmToken) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications/fcm-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      ).timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// 🔔 Préférences de notification
class NotificationPreferences {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool orderUpdates;
  final bool promotionalOffers;
  final bool loyaltyUpdates;

  NotificationPreferences({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.orderUpdates = true,
    this.promotionalOffers = true,
    this.loyaltyUpdates = true,
  });

  /// 📊 Conversion depuis JSON
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushNotifications: json['pushNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? false,
      orderUpdates: json['orderUpdates'] ?? true,
      promotionalOffers: json['promotionalOffers'] ?? true,
      loyaltyUpdates: json['loyaltyUpdates'] ?? true,
    );
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'orderUpdates': orderUpdates,
      'promotionalOffers': promotionalOffers,
      'loyaltyUpdates': loyaltyUpdates,
    };
  }

  /// 🔄 Copie avec modifications
  NotificationPreferences copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? orderUpdates,
    bool? promotionalOffers,
    bool? loyaltyUpdates,
  }) {
    return NotificationPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      loyaltyUpdates: loyaltyUpdates ?? this.loyaltyUpdates,
    );
  }
}