import '../services/api_service.dart';
import '../models/loyalty.dart';

class LoyaltyService {
  static final ApiService _apiService = ApiService();
  static const String _baseUrl = '/loyalty';

  /// Récupère tous les points de fidélité des utilisateurs (Admin seulement)
  static Future<List<LoyaltyPoints>> getAllLoyaltyPoints({
    int page = 1,
    int limit = 10,
    String? query,
  }) async {
    try {
      print('[LoyaltyService] Getting all loyalty points...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }

      final response = await _apiService.get(
        '$_baseUrl/admin/points',
        queryParameters: queryParams,
      );

      print('[LoyaltyService] Raw API response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        print('[LoyaltyService] Full response structure: ${responseData.toString()}');
        
        // Le backend retourne { success: true, data: { data: [...], pagination: {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          if (data['data'] is List) {
            final List<LoyaltyPoints> loyaltyPoints = (data['data'] as List)
                .map((item) => LoyaltyPoints.fromJson(item))
                .toList();
            print('[LoyaltyService] ✅ Retrieved ${loyaltyPoints.length} loyalty points');
            return loyaltyPoints;
          }
        }
      }

      print('[LoyaltyService] ⚠️ No loyalty points data in response');
      return [];
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting loyalty points: $e');
      rethrow;
    }
  }

  /// Récupère les statistiques du système de fidélité
  static Future<LoyaltyStats> getLoyaltyStats() async {
    try {
      print('[LoyaltyService] Getting loyalty stats...');

      final response = await _apiService.get('$_baseUrl/admin/stats');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        print('[LoyaltyService] Stats response structure: ${responseData.toString()}');
        
        // Le backend retourne { success: true, data: {...} }
        if (responseData['success'] == true && responseData['data'] != null) {
          final stats = LoyaltyStats.fromJson(responseData['data']);
          print('[LoyaltyService] ✅ Retrieved loyalty stats');
          return stats;
        }
      }

      throw Exception('Failed to load loyalty stats');
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting loyalty stats: $e');
      rethrow;
    }
  }

  /// Récupère les points de fidélité d'un utilisateur par ID
  static Future<LoyaltyPoints?> getLoyaltyPointsByUserId(String userId) async {
    try {
      print('[LoyaltyService] Getting loyalty points by user ID: $userId');

      final response =
          await _apiService.get('$_baseUrl/admin/users/$userId/points');

      if (response.statusCode == 200 && response.data != null) {
        final loyaltyPoints = LoyaltyPoints.fromJson(response.data['data']);
        print(
            '[LoyaltyService] ✅ Retrieved loyalty points for user: $userId');
        return loyaltyPoints;
      }

      print('[LoyaltyService] ⚠️ Loyalty points not found for user');
      return null;
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting loyalty points by user ID: $e');
      rethrow;
    }
  }

  /// Récupère toutes les transactions de points
  static Future<List<PointTransaction>> getPointTransactions({
    int page = 1,
    int limit = 10,
    String? userId,
    PointTransactionType? type,
    PointSource? source,
  }) async {
    try {
      print('[LoyaltyService] Getting point transactions...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (userId != null) {
        queryParams['userId'] = userId;
      }

      if (type != null) {
        queryParams['type'] = type.name;
      }

      if (source != null) {
        queryParams['source'] = source.name;
      }

      final response = await _apiService.get(
        '$_baseUrl/admin/transactions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        // Le backend retourne { success: true, data: { data: [...], pagination: {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          if (data['data'] is List) {
            final List<PointTransaction> transactions = (data['data'] as List)
                .map((item) => PointTransaction.fromJson(item))
                .toList();
            print('[LoyaltyService] ✅ Retrieved ${transactions.length} point transactions');
            return transactions;
          }
        }
      }

      return [];
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting point transactions: $e');
      rethrow;
    }
  }

  /// Ajoute des points à un utilisateur
  static Future<PointTransaction?> addPointsToUser(
    String userId,
    int points,
    PointSource source,
    String referenceId,
  ) async {
    try {
      print('[LoyaltyService] Adding points to user: $userId');

      final response = await _apiService.post(
        '$_baseUrl/admin/users/$userId/add-points',
        data: {
          'points': points,
          'source': source.name,
          'referenceId': referenceId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final transaction = PointTransaction.fromJson(response.data['data']);
        print('[LoyaltyService] ✅ Points added successfully');
        return transaction;
      }

      throw Exception('Failed to add points to user');
    } catch (e) {
      print('[LoyaltyService] ❌ Error adding points to user: $e');
      rethrow;
    }
  }

  /// Déduit des points d'un utilisateur
  static Future<PointTransaction?> deductPointsFromUser(
    String userId,
    int points,
    PointSource source,
    String referenceId,
  ) async {
    try {
      print('[LoyaltyService] Deducting points from user: $userId');

      final response = await _apiService.post(
        '$_baseUrl/admin/users/$userId/deduct-points',
        data: {
          'points': points,
          'source': source.name,
          'referenceId': referenceId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final transaction = PointTransaction.fromJson(response.data['data']);
        print('[LoyaltyService] ✅ Points deducted successfully');
        return transaction;
      }

      throw Exception('Failed to deduct points from user');
    } catch (e) {
      print('[LoyaltyService] ❌ Error deducting points from user: $e');
      rethrow;
    }
  }

  /// Récupère toutes les récompenses
  static Future<List<Reward>> getAllRewards({
    int page = 1,
    int limit = 10,
    bool? isActive,
    RewardType? type,
  }) async {
    try {
      print('[LoyaltyService] Getting all rewards...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (isActive != null) {
        queryParams['isActive'] = isActive;
      }

      if (type != null) {
        queryParams['type'] = type.name;
      }

      final response = await _apiService.get(
        '$_baseUrl/admin/rewards',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        // Le backend retourne { success: true, data: { data: [...], pagination: {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          if (data['data'] is List) {
            final List<Reward> rewards = (data['data'] as List)
                .map((item) => Reward.fromJson(item))
                .toList();
            print('[LoyaltyService] ✅ Retrieved ${rewards.length} rewards');
            return rewards;
          }
        }
      }

      return [];
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting rewards: $e');
      rethrow;
    }
  }

  /// Récupère une récompense par ID
  static Future<Reward?> getRewardById(String rewardId) async {
    try {
      print('[LoyaltyService] Getting reward by ID: $rewardId');

      final response =
          await _apiService.get('$_baseUrl/admin/rewards/$rewardId');

      if (response.statusCode == 200 && response.data != null) {
        final reward = Reward.fromJson(response.data['data']);
        print('[LoyaltyService] ✅ Retrieved reward: ${reward.name}');
        return reward;
      }

      print('[LoyaltyService] ⚠️ Reward not found');
      return null;
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting reward by ID: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle récompense
  static Future<Reward?> createReward({
    required String name,
    required String description,
    required int pointsCost,
    required RewardType type,
    double? discountValue,
    String? discountType,
    int? maxRedemptions,
  }) async {
    try {
      print('[LoyaltyService] Creating new reward: $name');

      final response = await _apiService.post(
        '$_baseUrl/admin/rewards',
        data: {
          'name': name,
          'description': description,
          'pointsCost': pointsCost,
          'type': type.name,
          if (discountValue != null) 'discountValue': discountValue,
          if (discountType != null) 'discountType': discountType,
          if (maxRedemptions != null) 'maxRedemptions': maxRedemptions,
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        final reward = Reward.fromJson(response.data['data']);
        print('[LoyaltyService] ✅ Reward created successfully');
        return reward;
      }

      throw Exception('Failed to create reward');
    } catch (e) {
      print('[LoyaltyService] ❌ Error creating reward: $e');
      rethrow;
    }
  }

  /// Met à jour une récompense
  static Future<Reward?> updateReward(
    String rewardId, {
    String? name,
    String? description,
    int? pointsCost,
    RewardType? type,
    double? discountValue,
    String? discountType,
    bool? isActive,
    int? maxRedemptions,
  }) async {
    try {
      print('[LoyaltyService] Updating reward: $rewardId');

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (pointsCost != null) data['pointsCost'] = pointsCost;
      if (type != null) data['type'] = type.name;
      if (discountValue != null) data['discountValue'] = discountValue;
      if (discountType != null) data['discountType'] = discountType;
      if (isActive != null) data['isActive'] = isActive;
      if (maxRedemptions != null) data['maxRedemptions'] = maxRedemptions;

      final response = await _apiService.patch(
        '$_baseUrl/admin/rewards/$rewardId',
        data: data,
      );

      if (response.statusCode == 200 && response.data != null) {
        final reward = Reward.fromJson(response.data['data']);
        print('[LoyaltyService] ✅ Reward updated successfully');
        return reward;
      }

      throw Exception('Failed to update reward');
    } catch (e) {
      print('[LoyaltyService] ❌ Error updating reward: $e');
      rethrow;
    }
  }

  /// Supprime une récompense
  static Future<bool> deleteReward(String rewardId) async {
    try {
      print('[LoyaltyService] Deleting reward: $rewardId');

      final response =
          await _apiService.delete('$_baseUrl/admin/rewards/$rewardId');

      final success = response.statusCode == 200;
      if (success) {
        print('[LoyaltyService] ✅ Reward deleted successfully');
      } else {
        print('[LoyaltyService] ❌ Failed to delete reward');
      }

      return success;
    } catch (e) {
      print('[LoyaltyService] ❌ Error deleting reward: $e');
      rethrow;
    }
  }

  /// Récupère toutes les demandes de récompenses
  static Future<List<RewardClaim>> getRewardClaims({
    int page = 1,
    int limit = 10,
    RewardClaimStatus? status,
    String? userId,
    String? rewardId,
  }) async {
    try {
      print('[LoyaltyService] Getting reward claims...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.name;
      }

      if (userId != null) {
        queryParams['userId'] = userId;
      }

      if (rewardId != null) {
        queryParams['rewardId'] = rewardId;
      }

      final response = await _apiService.get(
        '$_baseUrl/admin/claims',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        // Le backend retourne { success: true, data: { data: [...], pagination: {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          if (data['data'] is List) {
            final List<RewardClaim> claims = (data['data'] as List)
                .map((item) => RewardClaim.fromJson(item))
                .toList();
            print('[LoyaltyService] ✅ Retrieved ${claims.length} reward claims');
            return claims;
          }
        }
      }

      return [];
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting reward claims: $e');
      rethrow;
    }
  }

  /// Récupère les demandes de récompenses en attente
  static Future<List<RewardClaim>> getPendingRewardClaims({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('[LoyaltyService] Getting pending reward claims...');

      final response = await _apiService.get(
        '$_baseUrl/admin/claims/pending',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        // Le backend retourne { success: true, data: { data: [...], pagination: {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          if (data['data'] is List) {
            final List<RewardClaim> claims = (data['data'] as List)
                .map((item) => RewardClaim.fromJson(item))
                .toList();
            print('[LoyaltyService] ✅ Retrieved ${claims.length} pending reward claims');
            return claims;
          }
        }
      }

      return [];
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting pending reward claims: $e');
      rethrow;
    }
  }

  /// Approuve une demande de récompense
  static Future<bool> approveRewardClaim(String claimId) async {
    try {
      print('[LoyaltyService] Approving reward claim: $claimId');

      final response = await _apiService.patch(
        '$_baseUrl/admin/claims/$claimId/approve',
      );

      final success = response.statusCode == 200;
      if (success) {
        print('[LoyaltyService] ✅ Reward claim approved successfully');
      } else {
        print('[LoyaltyService] ❌ Failed to approve reward claim');
      }

      return success;
    } catch (e) {
      print('[LoyaltyService] ❌ Error approving reward claim: $e');
      rethrow;
    }
  }

  /// Rejette une demande de récompense
  static Future<bool> rejectRewardClaim(String claimId, String reason) async {
    try {
      print('[LoyaltyService] Rejecting reward claim: $claimId');

      final response = await _apiService.patch(
        '$_baseUrl/admin/claims/$claimId/reject',
        data: {'reason': reason},
      );

      final success = response.statusCode == 200;
      if (success) {
        print('[LoyaltyService] ✅ Reward claim rejected successfully');
      } else {
        print('[LoyaltyService] ❌ Failed to reject reward claim');
      }

      return success;
    } catch (e) {
      print('[LoyaltyService] ❌ Error rejecting reward claim: $e');
      rethrow;
    }
  }

  /// Marque une demande de récompense comme utilisée
  static Future<bool> markRewardClaimAsUsed(String claimId) async {
    try {
      print('[LoyaltyService] Marking reward claim as used: $claimId');

      final response = await _apiService.patch(
        '$_baseUrl/admin/claims/$claimId/use',
      );

      final success = response.statusCode == 200;
      if (success) {
        print('[LoyaltyService] ✅ Reward claim marked as used successfully');
      } else {
        print('[LoyaltyService] ❌ Failed to mark reward claim as used');
      }

      return success;
    } catch (e) {
      print('[LoyaltyService] ❌ Error marking reward claim as used: $e');
      rethrow;
    }
  }

  /// Récupère l'historique des transactions de points d'un utilisateur
  static Future<List<PointTransaction>> getUserPointHistory(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('[LoyaltyService] Getting point history for user: $userId');

      final response = await _apiService.get(
        '$_baseUrl/admin/users/$userId/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        // Le backend retourne { success: true, data: { data: [...], pagination: {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          if (data['data'] is List) {
            final List<PointTransaction> history = (data['data'] as List)
                .map((item) => PointTransaction.fromJson(item))
                .toList();
            print('[LoyaltyService] ✅ Retrieved ${history.length} point transactions for user');
            return history;
          }
        }
      }

      return [];
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting user point history: $e');
      rethrow;
    }
  }

  /// Génère des statistiques pour le dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('[LoyaltyService] Getting dashboard stats...');

      // Récupérer les statistiques de base
      final stats = await getLoyaltyStats();

      // Récupérer les demandes de récompenses en attente
      final pendingClaims = await getPendingRewardClaims(limit: 5);

      // Récupérer les dernières transactions
      final recentTransactions = await getPointTransactions(limit: 5);

      // Récupérer les récompenses actives
      final activeRewards = await getAllRewards(limit: 5, isActive: true);

      return {
        'stats': stats,
        'pendingClaims': pendingClaims,
        'recentTransactions': recentTransactions,
        'activeRewards': activeRewards,
      };
    } catch (e) {
      print('[LoyaltyService] ❌ Error getting dashboard stats: $e');
      rethrow;
    }
  }

  /// Calcule les points à attribuer pour une commande
  static Future<int> calculateOrderPoints(double orderAmount) async {
    try {
      print('[LoyaltyService] Calculating points for order amount: $orderAmount');

      final response = await _apiService.post(
        '$_baseUrl/calculate-points',
        data: {'orderAmount': orderAmount},
      );

      if (response.statusCode == 200 && response.data != null) {
        final points = response.data['data']['points'] as int;
        print('[LoyaltyService] ✅ Calculated $points points for order');
        return points;
      }

      return 0;
    } catch (e) {
      print('[LoyaltyService] ❌ Error calculating order points: $e');
      return 0;
    }
  }

  /// Traite les points pour une commande
  static Future<PointTransaction?> processOrderPoints(
    String userId,
    String orderId,
    double orderAmount,
  ) async {
    try {
      print('[LoyaltyService] Processing order points for user: $userId');

      final response = await _apiService.post(
        '$_baseUrl/process-order-points',
        data: {
          'userId': userId,
          'orderId': orderId,
          'orderAmount': orderAmount,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final transaction = PointTransaction.fromJson(response.data['data']);
        print('[LoyaltyService] ✅ Order points processed successfully');
        return transaction;
      }

      return null;
    } catch (e) {
      print('[LoyaltyService] ❌ Error processing order points: $e');
      rethrow;
    }
  }
}