import '../constants.dart';

/// 👤 Modèle Profil Affilié - Alpha Affiliate App
///
/// Modèle de données pour le profil affilié basé sur la documentation backend
/// `affiliate_api.md` et les endpoints `/api/affiliate/profile`

class AffiliateProfile {
  final String id;
  final String userId;
  final String affiliateCode;
  final String? parentAffiliateId;
  final double commissionRate;
  final double commissionBalance;
  final double totalEarned;
  final double monthlyEarnings;
  final bool isActive;
  final AffiliateStatus status;
  final String? levelId;
  final int totalReferrals;
  final int transactionsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AffiliateUser? user;
  final List<CommissionTransaction> recentTransactions;

  const AffiliateProfile({
    required this.id,
    required this.userId,
    required this.affiliateCode,
    this.parentAffiliateId,
    required this.commissionRate,
    required this.commissionBalance,
    required this.totalEarned,
    required this.monthlyEarnings,
    required this.isActive,
    required this.status,
    this.levelId,
    required this.totalReferrals,
    required this.transactionsCount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.recentTransactions = const [],
  });

  /// Factory depuis JSON (backend response)
  factory AffiliateProfile.fromJson(Map<String, dynamic> json) {
    return AffiliateProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      affiliateCode: json['affiliateCode'] as String,
      parentAffiliateId: json['parent_affiliate_id'] as String?,
      commissionRate: (json['commission_rate'] as num).toDouble(),
      commissionBalance: (json['commissionBalance'] as num).toDouble(),
      totalEarned: (json['totalEarned'] as num).toDouble(),
      monthlyEarnings: (json['monthlyEarnings'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      status: _parseStatus(json['status'] as String),
      levelId: json['levelId'] as String?,
      totalReferrals: json['totalReferrals'] as int,
      transactionsCount: json['transactionsCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: json['user'] != null
          ? AffiliateUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      recentTransactions: json['recentTransactions'] != null
          ? (json['recentTransactions'] as List)
              .map((t) =>
                  CommissionTransaction.fromJson(t as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'affiliateCode': affiliateCode,
      'parent_affiliate_id': parentAffiliateId,
      'commission_rate': commissionRate,
      'commissionBalance': commissionBalance,
      'totalEarned': totalEarned,
      'monthlyEarnings': monthlyEarnings,
      'isActive': isActive,
      'status': status.name.toUpperCase(),
      'levelId': levelId,
      'totalReferrals': totalReferrals,
      'transactionsCount': transactionsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'recentTransactions': recentTransactions.map((t) => t.toJson()).toList(),
    };
  }

  /// Copy with
  AffiliateProfile copyWith({
    String? id,
    String? userId,
    String? affiliateCode,
    String? parentAffiliateId,
    double? commissionRate,
    double? commissionBalance,
    double? totalEarned,
    double? monthlyEarnings,
    bool? isActive,
    AffiliateStatus? status,
    String? levelId,
    int? totalReferrals,
    int? transactionsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    AffiliateUser? user,
    List<CommissionTransaction>? recentTransactions,
  }) {
    return AffiliateProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      affiliateCode: affiliateCode ?? this.affiliateCode,
      parentAffiliateId: parentAffiliateId ?? this.parentAffiliateId,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionBalance: commissionBalance ?? this.commissionBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      levelId: levelId ?? this.levelId,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      transactionsCount: transactionsCount ?? this.transactionsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }

  /// Getters utilitaires
  String get displayName => user?.displayName ?? 'Affilié';
  String get email => user?.email ?? '';
  String get statusText => _getStatusText(status);
  String get levelName => AffiliateConfig.commissionLevels[levelId] ?? 'Bronze';

  bool get canWithdraw =>
      isActive &&
      status == AffiliateStatus.active &&
      commissionBalance >= AffiliateConfig.minWithdrawalAmount;

  /// Parse status depuis string
  static AffiliateStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AffiliateStatus.active;
      case 'PENDING':
        return AffiliateStatus.pending;
      case 'SUSPENDED':
        return AffiliateStatus.suspended;
      default:
        return AffiliateStatus.pending;
    }
  }

  /// Texte du statut
  static String _getStatusText(AffiliateStatus status) {
    switch (status) {
      case AffiliateStatus.active:
        return 'Actif';
      case AffiliateStatus.pending:
        return 'En attente';
      case AffiliateStatus.suspended:
        return 'Suspendu';
    }
  }

  @override
  String toString() =>
      'AffiliateProfile(id: $id, code: $affiliateCode, balance: $commissionBalance)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AffiliateProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 👤 Utilisateur Affilié
class AffiliateUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;

  const AffiliateUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  factory AffiliateUser.fromJson(Map<String, dynamic> json) {
    return AffiliateUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }

  String get displayName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  @override
  String toString() => 'AffiliateUser(id: $id, name: $displayName)';
}

/// 💰 Transaction de Commission
class CommissionTransaction {
  final String id;
  final String? orderId;
  final String affiliateId;
  final double amount;
  final WithdrawalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? orderDetails;

  const CommissionTransaction({
    required this.id,
    this.orderId,
    required this.affiliateId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.orderDetails,
  });

  factory CommissionTransaction.fromJson(Map<String, dynamic> json) {
    return CommissionTransaction(
      id: json['id'] as String,
      orderId: json['orderId'] as String?,
      affiliateId: json['affiliate_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: _parseWithdrawalStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      orderDetails: json['orders'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'affiliate_id': affiliateId,
      'amount': amount,
      'status': status.name.toUpperCase(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'orders': orderDetails,
    };
  }

  /// Type de transaction
  bool get isWithdrawal => orderId == null;
  bool get isCommission => orderId != null;

  String get typeText => isWithdrawal ? 'Retrait' : 'Commission';
  String get statusText => _getWithdrawalStatusText(status);

  /// Parse status depuis string
  static WithdrawalStatus _parseWithdrawalStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return WithdrawalStatus.pending;
      case 'APPROVED':
        return WithdrawalStatus.approved;
      case 'REJECTED':
        return WithdrawalStatus.rejected;
      default:
        return WithdrawalStatus.pending;
    }
  }

  /// Texte du statut
  static String _getWithdrawalStatusText(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.pending:
        return 'En attente';
      case WithdrawalStatus.approved:
        return 'Approuvé';
      case WithdrawalStatus.rejected:
        return 'Rejeté';
    }
  }

  @override
  String toString() =>
      'CommissionTransaction(id: $id, amount: $amount, type: $typeText)';
}

/// 🎯 Niveau d'Affiliation
class AffiliateLevel {
  final String id;
  final String name;
  final double minEarnings;
  final double commissionRate;
  final String description;
  final DateTime createdAt;

  const AffiliateLevel({
    required this.id,
    required this.name,
    required this.minEarnings,
    required this.commissionRate,
    required this.description,
    required this.createdAt,
  });

  factory AffiliateLevel.fromJson(Map<String, dynamic> json) {
    return AffiliateLevel(
      id: json['id'] as String,
      name: json['name'] as String,
      minEarnings: (json['minEarnings'] as num).toDouble(),
      commissionRate: (json['commissionRate'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minEarnings': minEarnings,
      'commissionRate': commissionRate,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'AffiliateLevel(name: $name, rate: $commissionRate%)';
}

/// 👥 Filleul (Referral)
class AffiliateReferral {
  final String id;
  final String userId;
  final String affiliateId;
  final DateTime createdAt;
  final AffiliateUser? user;

  const AffiliateReferral({
    required this.id,
    required this.userId,
    required this.affiliateId,
    required this.createdAt,
    this.user,
  });

  factory AffiliateReferral.fromJson(Map<String, dynamic> json) {
    return AffiliateReferral(
      id: json['id'] as String,
      userId: json['userId'] as String,
      affiliateId: json['affiliateId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] != null
          ? AffiliateUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'affiliateId': affiliateId,
      'createdAt': createdAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  String get displayName => user?.displayName ?? 'Filleul';

  @override
  String toString() => 'AffiliateReferral(id: $id, user: $displayName)';
}

/// 👥 Client lié à un affilié
class LinkedClient {
  final AffiliateUser client;
  final AffiliateClientLink link;
  final int ordersCount;
  final double totalCommissions; // 💰 Commissions gagnées au lieu du total dépensé

  const LinkedClient({
    required this.client,
    required this.link,
    required this.ordersCount,
    required this.totalCommissions,
  });

  factory LinkedClient.fromJson(Map<String, dynamic> json) {
    return LinkedClient(
      client: AffiliateUser.fromJson(json['client'] as Map<String, dynamic>),
      link: AffiliateClientLink.fromJson(json['link'] as Map<String, dynamic>),
      ordersCount: json['ordersCount'] as int? ?? 0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client': client.toJson(),
      'link': link.toJson(),
      'ordersCount': ordersCount,
      'totalCommissions': totalCommissions,
    };
  }

  String get displayName => client.displayName;
  String get email => client.email;

  @override
  String toString() =>
      'LinkedClient(client: $displayName, orders: $ordersCount, commissions: $totalCommissions)';
}

/// 🔗 Liaison affilié-client
class AffiliateClientLink {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? type;

  const AffiliateClientLink({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.type,
  });

  factory AffiliateClientLink.fromJson(Map<String, dynamic> json) {
    return AffiliateClientLink(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'type': type,
    };
  }

  @override
  String toString() => 'AffiliateClientLink(id: $id, active: $isActive)';
}
