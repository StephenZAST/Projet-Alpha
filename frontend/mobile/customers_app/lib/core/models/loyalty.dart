/// 🎁 Modèles Fidélité - Alpha Client App
///
/// Modèles de données pour le système de fidélité basés sur le backend

enum PointTransactionType {
  earned,
  spent,
}

enum PointSource {
  order,
  referral,
  bonus,
  reward,
  admin,
}

enum RewardType {
  discount,
  freeService,
  gift,
  voucher,
}

/// 💰 Points de Fidélité
class LoyaltyPoints {
  final String id;
  final String userId;
  final int pointsBalance;
  final int totalEarned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoyaltyPoints({
    required this.id,
    required this.userId,
    required this.pointsBalance,
    required this.totalEarned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      id: json['id'] as String,
      // ✅ Accepte à la fois user_id (backend) et userId (fallback)
      userId: (json['user_id'] ?? json['userId']) as String,
      pointsBalance: json['pointsBalance'] as int? ?? 0,
      totalEarned: json['totalEarned'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pointsBalance': pointsBalance,
      'totalEarned': totalEarned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  LoyaltyPoints copyWith({
    String? id,
    String? userId,
    int? pointsBalance,
    int? totalEarned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoyaltyPoints(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'LoyaltyPoints(id: $id, balance: $pointsBalance)';
}

/// 📋 Transaction de Points
class PointTransaction {
  final String id;
  final String userId;
  final int points;
  final PointTransactionType type;
  final PointSource source;
  final String? referenceId;
  final String description;
  final DateTime createdAt;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.source,
    this.referenceId,
    required this.description,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      points: json['points'] as int,
      type: _parseTransactionType(json['type'] as String),
      source: _parsePointSource(json['source'] as String),
      referenceId: json['referenceId'] as String?,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'type': type.name.toUpperCase(),
      'source': source.name.toUpperCase(),
      'referenceId': referenceId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static PointTransactionType _parseTransactionType(String type) {
    switch (type.toUpperCase()) {
      case 'EARNED':
        return PointTransactionType.earned;
      case 'SPENT':
        return PointTransactionType.spent;
      default:
        return PointTransactionType.earned;
    }
  }

  static PointSource _parsePointSource(String source) {
    switch (source.toUpperCase()) {
      case 'ORDER':
        return PointSource.order;
      case 'REFERRAL':
        return PointSource.referral;
      case 'BONUS':
        return PointSource.bonus;
      case 'REWARD':
        return PointSource.reward;
      case 'ADMIN':
        return PointSource.admin;
      default:
        return PointSource.order;
    }
  }

  // Getters utilitaires
  bool get isEarned => type == PointTransactionType.earned;
  bool get isSpent => type == PointTransactionType.spent;
  
  String get typeText => isEarned ? 'Gagné' : 'Utilisé';
  String get sourceText {
    switch (source) {
      case PointSource.order:
        return 'Commande';
      case PointSource.referral:
        return 'Parrainage';
      case PointSource.bonus:
        return 'Bonus';
      case PointSource.reward:
        return 'Récompense';
      case PointSource.admin:
        return 'Administrateur';
    }
  }

  String get displayPoints => '${isSpent ? '-' : '+'}$points';

  @override
  String toString() => 'PointTransaction(id: $id, points: $displayPoints, type: $typeText)';
}

/// 🎁 Récompense
class Reward {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final int pointsRequired;
  final double? discountAmount;
  final double? discountPercentage;
  final bool isActive;
  final DateTime? validUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.pointsRequired,
    this.discountAmount,
    this.discountPercentage,
    required this.isActive,
    this.validUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: _parseRewardType(json['type'] as String),
      // ✅ Accepte points_cost, pointsRequired, points_required, ou 0 par défaut
      pointsRequired: (json['points_cost'] ?? 
                       json['pointsRequired'] ?? 
                       json['points_required'] ?? 
                       0) as int,
      // ✅ Accepte discount_value, discountAmount, value, ou null
      discountAmount: (json['discount_value'] ?? 
                       json['discountAmount'] ?? 
                       json['value'])?.toDouble(),
      discountPercentage: json['discountPercentage']?.toDouble(),
      // ✅ Accepte is_active, isActive, ou true par défaut
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      validUntil: json['validUntil'] != null 
          ? DateTime.parse(json['validUntil'] as String)
          : json['valid_until'] != null
              ? DateTime.parse(json['valid_until'] as String)
              : null,
      // ✅ Accepte created_at, createdAt, ou DateTime.now()
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      // ✅ Accepte updated_at, updatedAt, ou DateTime.now()
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name.toUpperCase(),
      'pointsRequired': pointsRequired,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
      'isActive': isActive,
      'validUntil': validUntil?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static RewardType _parseRewardType(String type) {
    switch (type.toUpperCase()) {
      case 'DISCOUNT':
        return RewardType.discount;
      case 'FREE_SERVICE':
        return RewardType.freeService;
      case 'GIFT':
        return RewardType.gift;
      case 'VOUCHER':
        return RewardType.voucher;
      default:
        return RewardType.discount;
    }
  }

  // Getters utilitaires
  bool get isExpired => validUntil != null && validUntil!.isBefore(DateTime.now());
  bool get isAvailable => isActive && !isExpired;
  
  String get typeText {
    switch (type) {
      case RewardType.discount:
        return 'Réduction';
      case RewardType.freeService:
        return 'Service Gratuit';
      case RewardType.gift:
        return 'Cadeau';
      case RewardType.voucher:
        return 'Bon d\'achat';
    }
  }

  String get valueText {
    if (discountAmount != null) {
      return '${discountAmount!.toInt()} FCFA';
    } else if (discountPercentage != null) {
      return '${discountPercentage!.toInt()}%';
    } else {
      return 'Gratuit';
    }
  }

  @override
  String toString() => 'Reward(id: $id, name: $name, points: $pointsRequired)';
}

/// 🏆 Réclamation de Récompense
class RewardClaim {
  final String id;
  final String userId;
  final String rewardId;
  final RewardClaimStatus status;
  final DateTime claimedAt;
  final DateTime? approvedAt;
  final DateTime? usedAt;
  final String? rejectionReason;
  final Reward? reward;

  const RewardClaim({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.status,
    required this.claimedAt,
    this.approvedAt,
    this.usedAt,
    this.rejectionReason,
    this.reward,
  });

  factory RewardClaim.fromJson(Map<String, dynamic> json) {
    return RewardClaim(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rewardId: json['rewardId'] as String,
      status: _parseClaimStatus(json['status'] as String),
      claimedAt: DateTime.parse(json['claimedAt'] as String),
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      usedAt: json['usedAt'] != null 
          ? DateTime.parse(json['usedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      reward: json['reward'] != null 
          ? Reward.fromJson(json['reward'] as Map<String, dynamic>)
          : null,
    );
  }

  static RewardClaimStatus _parseClaimStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return RewardClaimStatus.pending;
      case 'APPROVED':
        return RewardClaimStatus.approved;
      case 'REJECTED':
        return RewardClaimStatus.rejected;
      case 'USED':
        return RewardClaimStatus.used;
      default:
        return RewardClaimStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case RewardClaimStatus.pending:
        return 'En attente';
      case RewardClaimStatus.approved:
        return 'Approuvé';
      case RewardClaimStatus.rejected:
        return 'Rejeté';
      case RewardClaimStatus.used:
        return 'Utilisé';
    }
  }

  @override
  String toString() => 'RewardClaim(id: $id, status: $statusText)';
}

enum RewardClaimStatus {
  pending,
  approved,
  rejected,
  used,
}

/// 📊 Statistiques de Fidélité
class LoyaltyStats {
  final int totalUsers;
  final int activeUsers;
  final int totalPointsDistributed;
  final int totalPointsRedeemed;
  final double averagePointsPerUser;
  final int totalRewardsClaimed;
  final int pendingClaims;

  const LoyaltyStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalPointsDistributed,
    required this.totalPointsRedeemed,
    required this.averagePointsPerUser,
    required this.totalRewardsClaimed,
    required this.pendingClaims,
  });

  factory LoyaltyStats.fromJson(Map<String, dynamic> json) {
    return LoyaltyStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      totalPointsDistributed: json['totalPointsDistributed'] as int? ?? 0,
      totalPointsRedeemed: json['totalPointsRedeemed'] as int? ?? 0,
      averagePointsPerUser: (json['averagePointsPerUser'] as num?)?.toDouble() ?? 0.0,
      totalRewardsClaimed: json['totalRewardsClaimed'] as int? ?? 0,
      pendingClaims: json['pendingClaims'] as int? ?? 0,
    );
  }

  @override
  String toString() => 'LoyaltyStats(users: $totalUsers, points: $totalPointsDistributed)';
}