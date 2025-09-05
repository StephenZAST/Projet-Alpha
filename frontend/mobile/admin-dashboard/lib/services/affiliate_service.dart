import '../services/api_service.dart';
import '../models/affiliate.dart';
import '../utils/debug_helper.dart';

class AffiliateService {
  static final ApiService _apiService = ApiService();
  static const String _baseUrl = '/affiliate';

  /// Récupère tous les affiliés (Admin seulement)
  static Future<List<AffiliateProfile>> getAllAffiliates({
    int page = 1,
    int limit = 10,
    AffiliateStatus? status,
    String? query,
  }) async {
    try {
      print('[AffiliateService] Getting all affiliates...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.name;
      }

      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }

      final response = await _apiService.get(
        '$_baseUrl/admin/list',
        queryParameters: queryParams,
      );

      print('[AffiliateService] Raw API response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['data'] is List) {
          final List<AffiliateProfile> affiliates = (data['data'] as List)
              .map((item) => AffiliateProfile.fromJson(item))
              .toList();
          print(
              '[AffiliateService] ✅ Retrieved ${affiliates.length} affiliates');
          return affiliates;
        }
      }

      print('[AffiliateService] ⚠️ No affiliates data in response');
      return [];
    } catch (e) {
      print('[AffiliateService] ❌ Error getting affiliates: $e');
      rethrow;
    }
  }

  /// Récupère les statistiques des affiliés
  static Future<AffiliateStats> getAffiliateStats() async {
    try {
      print('[AffiliateService] Getting affiliate stats...');

      final response = await _apiService.get('$_baseUrl/admin/stats');

      if (response.statusCode == 200 && response.data != null) {
        final stats = AffiliateStats.fromJson(response.data['data']);
        print('[AffiliateService] ✅ Retrieved affiliate stats');
        return stats;
      }

      throw Exception('Failed to load affiliate stats');
    } catch (e) {
      print('[AffiliateService] ❌ Error getting affiliate stats: $e');
      rethrow;
    }
  }

  /// Récupère un profil d'affilié par ID
  static Future<AffiliateProfile?> getAffiliateById(String affiliateId) async {
    try {
      print('[AffiliateService] Getting affiliate by ID: $affiliateId');

      final response =
          await _apiService.get('$_baseUrl/admin/affiliates/$affiliateId');

      if (response.statusCode == 200 && response.data != null) {
        final affiliate = AffiliateProfile.fromJson(response.data['data']);
        print(
            '[AffiliateService] ✅ Retrieved affiliate: ${affiliate.affiliateCode}');
        return affiliate;
      }

      print('[AffiliateService] ⚠️ Affiliate not found');
      return null;
    } catch (e) {
      print('[AffiliateService] ❌ Error getting affiliate by ID: $e');
      rethrow;
    }
  }

  /// Met à jour le statut d'un affilié
  static Future<AffiliateProfile?> updateAffiliateStatus(
    String affiliateId,
    AffiliateStatus status,
    bool isActive,
  ) async {
    try {
      print('[AffiliateService] Updating affiliate status: $affiliateId');

      final response = await _apiService.patch(
        '$_baseUrl/admin/affiliates/$affiliateId/status',
        data: {
          'status': status.name,
          'isActive': isActive,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final affiliate = AffiliateProfile.fromJson(response.data['data']);
        print('[AffiliateService] ✅ Affiliate status updated successfully');
        return affiliate;
      }

      throw Exception('Failed to update affiliate status');
    } catch (e) {
      print('[AffiliateService] ❌ Error updating affiliate status: $e');
      rethrow;
    }
  }

  /// Récupère les commissions d'un affilié
  static Future<List<CommissionTransaction>> getCommissions(
    String affiliateId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print(
          '[AffiliateService] Getting commissions for affiliate: $affiliateId');

      final response = await _apiService.get(
        '$_baseUrl/admin/affiliates/$affiliateId/commissions',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          final List<CommissionTransaction> commissions =
              data.map((item) => CommissionTransaction.fromJson(item)).toList();
          print(
              '[AffiliateService] ✅ Retrieved ${commissions.length} commissions');
          return commissions;
        }
      }

      return [];
    } catch (e) {
      print('[AffiliateService] ❌ Error getting commissions: $e');
      rethrow;
    }
  }

  /// Récupère les filleuls d'un affilié
  static Future<List<AffiliateProfile>> getReferrals(String affiliateId) async {
    try {
      print('[AffiliateService] Getting referrals for affiliate: $affiliateId');

      final response = await _apiService
          .get('$_baseUrl/admin/affiliates/$affiliateId/referrals');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          final List<AffiliateProfile> referrals =
              data.map((item) => AffiliateProfile.fromJson(item)).toList();
          print('[AffiliateService] ✅ Retrieved ${referrals.length} referrals');
          return referrals;
        }
      }

      return [];
    } catch (e) {
      print('[AffiliateService] ❌ Error getting referrals: $e');
      rethrow;
    }
  }

  /// Récupère toutes les demandes de retrait
  static Future<List<WithdrawalRequest>> getWithdrawals({
    int page = 1,
    int limit = 10,
    WithdrawalStatus? status,
  }) async {
    try {
      print('[AffiliateService] Getting withdrawal requests...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _apiService.get(
        '$_baseUrl/admin/withdrawals',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          final List<WithdrawalRequest> withdrawals =
              data.map((item) => WithdrawalRequest.fromJson(item)).toList();
          print(
              '[AffiliateService] ✅ Retrieved ${withdrawals.length} withdrawal requests');
          return withdrawals;
        }
      }

      return [];
    } catch (e) {
      print('[AffiliateService] ❌ Error getting withdrawal requests: $e');
      rethrow;
    }
  }

  /// Récupère les demandes de retrait en attente
  static Future<List<WithdrawalRequest>> getPendingWithdrawals({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('[AffiliateService] Getting pending withdrawal requests...');

      final response = await _apiService.get(
        '$_baseUrl/admin/withdrawals/pending',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          final List<WithdrawalRequest> withdrawals =
              data.map((item) => WithdrawalRequest.fromJson(item)).toList();
          print(
              '[AffiliateService] ✅ Retrieved ${withdrawals.length} pending withdrawals');
          return withdrawals;
        }
      }

      return [];
    } catch (e) {
      print('[AffiliateService] ❌ Error getting pending withdrawals: $e');
      rethrow;
    }
  }

  /// Approuve une demande de retrait
  static Future<bool> approveWithdrawal(String withdrawalId) async {
    try {
      print('[AffiliateService] Approving withdrawal: $withdrawalId');

      final response = await _apiService.patch(
        '$_baseUrl/admin/withdrawals/$withdrawalId/approve',
      );

      final success = response.statusCode == 200;
      if (success) {
        print('[AffiliateService] ✅ Withdrawal approved successfully');
      } else {
        print('[AffiliateService] ❌ Failed to approve withdrawal');
      }

      return success;
    } catch (e) {
      print('[AffiliateService] ❌ Error approving withdrawal: $e');
      rethrow;
    }
  }

  /// Rejette une demande de retrait
  static Future<bool> rejectWithdrawal(
      String withdrawalId, String reason) async {
    try {
      print('[AffiliateService] Rejecting withdrawal: $withdrawalId');

      final response = await _apiService.patch(
        '$_baseUrl/admin/withdrawals/$withdrawalId/reject',
        data: {'reason': reason},
      );

      final success = response.statusCode == 200;
      if (success) {
        print('[AffiliateService] ✅ Withdrawal rejected successfully');
      } else {
        print('[AffiliateService] ❌ Failed to reject withdrawal');
      }

      return success;
    } catch (e) {
      print('[AffiliateService] ❌ Error rejecting withdrawal: $e');
      rethrow;
    }
  }

  /// Récupère les niveaux d'affiliation
  static Future<List<AffiliateLevel>> getAffiliateLevels() async {
    try {
      print('[AffiliateService] Getting affiliate levels...');

      final response = await _apiService.get('$_baseUrl/levels');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['levels'] is List) {
          final List<AffiliateLevel> levels = (data['levels'] as List)
              .map((item) => AffiliateLevel.fromJson(item))
              .toList();
          print(
              '[AffiliateService] ✅ Retrieved ${levels.length} affiliate levels');
          return levels;
        }
      }

      return [];
    } catch (e) {
      print('[AffiliateService] ❌ Error getting affiliate levels: $e');
      rethrow;
    }
  }

  /// Crée un nouveau client avec code d'affiliation
  static Future<Map<String, dynamic>?> createCustomerWithAffiliateCode({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String affiliateCode,
    String? phone,
  }) async {
    try {
      print(
          '[AffiliateService] Creating customer with affiliate code: $affiliateCode');

      final response = await _apiService.post(
        '$_baseUrl/register-with-code',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'affiliateCode': affiliateCode,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        print(
            '[AffiliateService] ✅ Customer created with affiliate code successfully');
        return response.data['data'];
      }

      return null;
    } catch (e) {
      print(
          '[AffiliateService] ❌ Error creating customer with affiliate code: $e');
      rethrow;
    }
  }

  /// Génère des statistiques pour le dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('[AffiliateService] Getting dashboard stats...');

      // Récupérer les statistiques de base
      final stats = await getAffiliateStats();

      // Récupérer les demandes de retrait en attente
      final pendingWithdrawals = await getPendingWithdrawals(limit: 5);

      // Récupérer les top affiliés
      final topAffiliates = await getAllAffiliates(limit: 5);

      return {
        'stats': stats,
        'pendingWithdrawals': pendingWithdrawals,
        'topAffiliates': topAffiliates,
      };
    } catch (e) {
      print('[AffiliateService] ❌ Error getting dashboard stats: $e');
      rethrow;
    }
  }
}
