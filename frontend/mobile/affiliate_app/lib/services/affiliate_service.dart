import '../constants.dart';
import '../models/affiliate_profile.dart';
import 'api_service.dart';

/// 💼 Service Affilié - Alpha Affiliate App
///
/// Service pour toutes les opérations liées aux affiliés basé sur
/// la documentation backend `affiliate_api.md`

class AffiliateService {
  static final AffiliateService _instance = AffiliateService._internal();
  factory AffiliateService() => _instance;
  AffiliateService._internal();

  final ApiService _apiService = ApiService();

  /// 👤 Récupérer le profil affilié
  /// GET /api/affiliate/profile
  Future<ApiResponse<AffiliateProfile>> getProfile() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConfig.profile,
    );

    return response.map((data) {
      if (data['success'] == true && data['data'] != null) {
        return AffiliateProfile.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Format de réponse invalide');
    });
  }

  /// 🆕 Créer un profil affilié
  /// POST /api/affiliate/create-profile
  Future<ApiResponse<AffiliateProfile>> createProfile() async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.affiliateEndpoint}/create-profile',
    );

    return response.map((data) {
      if (data['success'] == true && data['data'] != null) {
        return AffiliateProfile.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Format de réponse invalide');
    });
  }

  /// 👤 Mettre à jour le profil affilié
  /// PUT /api/affiliate/profile
  Future<ApiResponse<AffiliateProfile>> updateProfile({
    String? phone,
    Map<String, dynamic>? notificationPreferences,
  }) async {
    final data = <String, dynamic>{};
    
    if (phone != null) data['phone'] = phone;
    if (notificationPreferences != null) {
      data['notificationPreferences'] = notificationPreferences;
    }

    final response = await _apiService.put<Map<String, dynamic>>(
      ApiConfig.profile,
      data: data,
    );

    return response.map((data) {
      if (data['success'] == true && data['data'] != null) {
        return AffiliateProfile.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Format de réponse invalide');
    });
  }

  /// 💰 Récupérer les commissions
  /// GET /api/affiliate/commissions
  Future<ApiResponse<PaginatedCommissions>> getCommissions({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConfig.commissions,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return response.map((data) {
      final commissions = (data['data'] as List)
          .map((item) => CommissionTransaction.fromJson(item as Map<String, dynamic>))
          .toList();
      
      final pagination = data['pagination'] as Map<String, dynamic>?;
      
      return PaginatedCommissions(
        data: commissions,
        pagination: pagination != null ? PaginationInfo.fromJson(pagination) : null,
      );
    });
  }

  /// 💸 Demander un retrait
  /// POST /api/affiliate/withdrawal
  Future<ApiResponse<CommissionTransaction>> requestWithdrawal({
    required double amount,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConfig.withdrawal,
      data: {
        'amount': amount,
      },
    );

    return response.map((data) {
      if (data['success'] == true && data['data'] != null) {
        return CommissionTransaction.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Format de réponse invalide');
    });
  }

  /// 👥 Récupérer les filleuls
  /// GET /api/affiliate/referrals
  Future<ApiResponse<List<AffiliateReferral>>> getReferrals() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConfig.referrals,
    );

    return response.map((data) {
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((item) => AffiliateReferral.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return <AffiliateReferral>[];
    });
  }

  /// 🎯 Récupérer les niveaux
  /// GET /api/affiliate/levels
  Future<ApiResponse<LevelsResponse>> getLevels() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConfig.levels,
    );

    return response.map((data) {
      final levels = (data['data']['levels'] as List)
          .map((item) => AffiliateLevel.fromJson(item as Map<String, dynamic>))
          .toList();
      
      final additionalInfo = data['data']['additionalInfo'] as Map<String, dynamic>?;
      
      return LevelsResponse(
        levels: levels,
        additionalInfo: additionalInfo,
      );
    });
  }

  /// 🎯 Récupérer le niveau actuel
  /// GET /api/affiliate/current-level
  Future<ApiResponse<AffiliateLevel?>> getCurrentLevel() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConfig.currentLevel,
    );

    return response.map((data) {
      if (data['data'] != null) {
        return AffiliateLevel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// 🔗 Générer un code affilié
  /// POST /api/affiliate/generate-code
  Future<ApiResponse<String>> generateAffiliateCode() async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConfig.generateCode,
    );

    return response.map((data) {
      if (data['success'] == true && data['data'] != null) {
        return data['data']['affiliateCode'] as String;
      }
      throw Exception('Format de réponse invalide');
    });
  }

  /// 👤 Créer un client avec code affilié
  /// POST /api/affiliate/register-with-code
  Future<ApiResponse<Map<String, dynamic>>> createCustomerWithAffiliateCode({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String affiliateCode,
    String? phone,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConfig.registerWithCode,
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'affiliateCode': affiliateCode,
        if (phone != null) 'phone': phone,
      },
    );

    return response.map((data) {
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>;
      }
      throw Exception('Format de réponse invalide');
    });
  }

  /// 📊 Récupérer les statistiques (si disponible)
  Future<ApiResponse<AffiliateStats>> getStats() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.affiliateEndpoint}/stats',
    );

    return response.map((data) {
      if (data['data'] != null) {
        return AffiliateStats.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Format de réponse invalide');
    });
  }
}

/// 📄 Réponse paginée des commissions
class PaginatedCommissions {
  final List<CommissionTransaction> data;
  final PaginationInfo? pagination;

  const PaginatedCommissions({
    required this.data,
    this.pagination,
  });
}

/// 📄 Information de pagination
class PaginationInfo {
  final int total;
  final int currentPage;
  final int limit;
  final int totalPages;

  const PaginationInfo({
    required this.total,
    required this.currentPage,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] as int,
      currentPage: json['currentPage'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
}

/// 🎯 Réponse des niveaux
class LevelsResponse {
  final List<AffiliateLevel> levels;
  final Map<String, dynamic>? additionalInfo;

  const LevelsResponse({
    required this.levels,
    this.additionalInfo,
  });

  double? get indirectCommissionRate {
    return additionalInfo?['indirectCommission']?['rate']?.toDouble();
  }

  double? get profitMarginRate {
    return additionalInfo?['profitMargin']?['rate']?.toDouble();
  }
}

/// 📊 Statistiques affilié
class AffiliateStats {
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final int totalReferrals;
  final int activeReferrals;
  final int totalWithdrawals;
  final double pendingWithdrawals;

  const AffiliateStats({
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.weeklyEarnings,
    required this.totalReferrals,
    required this.activeReferrals,
    required this.totalWithdrawals,
    required this.pendingWithdrawals,
  });

  factory AffiliateStats.fromJson(Map<String, dynamic> json) {
    return AffiliateStats(
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      monthlyEarnings: (json['monthlyEarnings'] as num).toDouble(),
      weeklyEarnings: (json['weeklyEarnings'] as num).toDouble(),
      totalReferrals: json['totalReferrals'] as int,
      activeReferrals: json['activeReferrals'] as int,
      totalWithdrawals: json['totalWithdrawals'] as int,
      pendingWithdrawals: (json['pendingWithdrawals'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'monthlyEarnings': monthlyEarnings,
      'weeklyEarnings': weeklyEarnings,
      'totalReferrals': totalReferrals,
      'activeReferrals': activeReferrals,
      'totalWithdrawals': totalWithdrawals,
      'pendingWithdrawals': pendingWithdrawals,
    };
  }
}