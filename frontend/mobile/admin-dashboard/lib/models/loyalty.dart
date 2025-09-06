// Imports nécessaires
import 'package:flutter/material.dart';
import '../constants.dart';
import 'user.dart';
import 'order.dart';

class LoyaltyPoints {
  final String id;
  final String userId;
  final int pointsBalance;
  final int totalEarned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  const LoyaltyPoints({
    required this.id,
    required this.userId,
    required this.pointsBalance,
    required this.totalEarned,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      pointsBalance:
          json['pointsBalance'] as int? ?? json['points_balance'] as int? ?? 0,
      totalEarned:
          json['totalEarned'] as int? ?? json['total_earned'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String? ??
          json['created_at'] as String? ??
          DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ??
          json['updated_at'] as String? ??
          DateTime.now().toIso8601String()),
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : (json['users'] != null
              ? User.fromJson(json['users'] as Map<String, dynamic>)
              : null),
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
      'user': user?.toJson(),
    };
  }

  LoyaltyPoints copyWith({
    String? id,
    String? userId,
    int? pointsBalance,
    int? totalEarned,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return LoyaltyPoints(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  // Getters utilitaires
  String get fullName =>
      user != null ? '${user!.firstName} ${user!.lastName}' : 'N/A';
  String get email => user?.email ?? 'N/A';
  String get phone => user?.phone ?? 'N/A';

  String get formattedBalance => '${pointsBalance.toString()} pts';
  String get formattedTotalEarned => '${totalEarned.toString()} pts';

  double get conversionValue => pointsBalance * 0.01; // 1 point = 0.01 FCFA
  String get formattedConversionValue =>
      '${conversionValue.toStringAsFixed(0)} FCFA';

  bool get hasPoints => pointsBalance > 0;
  bool get canRedeem =>
      pointsBalance >= 100; // Minimum 100 points pour échanger
}

class PointTransaction {
  final String id;
  final String userId;
  final int points;
  final PointTransactionType type;
  final PointSource source;
  final String referenceId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User? user;
  final Order? order;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.source,
    required this.referenceId,
    required this.createdAt,
    this.updatedAt,
    this.user,
    this.order,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      type: PointTransactionType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'EARNED'),
        orElse: () => PointTransactionType.EARNED,
      ),
      source: PointSource.values.firstWhere(
        (e) => e.name == (json['source'] as String? ?? 'ORDER'),
        orElse: () => PointSource.ORDER,
      ),
      referenceId: json['referenceId'] as String? ??
          json['reference_id'] as String? ??
          '',
      createdAt: DateTime.parse(json['createdAt'] as String? ??
          json['created_at'] as String? ??
          DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse((json['updatedAt'] as String?) ??
              (json['updated_at'] as String?) ??
              DateTime.now().toIso8601String())
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      order: json['order'] != null
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'type': type.name,
      'source': source.name,
      'referenceId': referenceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
      'order': order?.toJson(),
    };
  }

  String get formattedPoints {
    final sign = type == PointTransactionType.EARNED ? '+' : '-';
    return '$sign${points.abs()} pts';
  }

  String get typeLabel {
    switch (type) {
      case PointTransactionType.EARNED:
        return 'Gagné';
      case PointTransactionType.SPENT:
        return 'Dépensé';
    }
  }

  String get sourceLabel {
    switch (source) {
      case PointSource.ORDER:
        return 'Commande';
      case PointSource.REFERRAL:
        return 'Parrainage';
      case PointSource.REWARD:
        return 'Récompense';
    }
  }

  bool get isEarned => type == PointTransactionType.EARNED;
  bool get isSpent => type == PointTransactionType.SPENT;
}

class Reward {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final RewardType type;
  final double? discountValue;
  final String? discountType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? maxRedemptions;
  final int? currentRedemptions;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.type,
    this.discountValue,
    this.discountType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.maxRedemptions,
    this.currentRedemptions,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      pointsCost:
          json['pointsCost'] as int? ?? json['points_cost'] as int? ?? 0,
      type: RewardType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'DISCOUNT'),
        orElse: () => RewardType.DISCOUNT,
      ),
      discountValue: (json['discountValue'] as num?)?.toDouble() ??
          (json['discount_value'] as num?)?.toDouble(),
      discountType:
          json['discountType'] as String? ?? json['discount_type'] as String?,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String? ??
          json['created_at'] as String? ??
          DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ??
          json['updated_at'] as String? ??
          DateTime.now().toIso8601String()),
      maxRedemptions:
          json['maxRedemptions'] as int? ?? json['max_redemptions'] as int?,
      currentRedemptions: json['currentRedemptions'] as int? ??
          json['current_redemptions'] as int? ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsCost': pointsCost,
      'type': type.name,
      'discountValue': discountValue,
      'discountType': discountType,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'maxRedemptions': maxRedemptions,
      'currentRedemptions': currentRedemptions,
    };
  }

  String get formattedPointsCost => '${pointsCost} pts';
  String get formattedDiscountValue {
    if (discountValue == null) return '';
    if (discountType == 'PERCENTAGE') {
      return '${discountValue!.toStringAsFixed(0)}%';
    }
    return '${discountValue!.toStringAsFixed(0)} FCFA';
  }

  bool get isAvailable {
    if (!isActive) return false;
    if (maxRedemptions == null) return true;
    return (currentRedemptions ?? 0) < maxRedemptions!;
  }

  String get availabilityText {
    if (!isActive) return 'Indisponible';
    if (maxRedemptions == null) return 'Disponible';
    final remaining = maxRedemptions! - (currentRedemptions ?? 0);
    return remaining > 0 ? '$remaining restant(s)' : 'Épuisé';
  }
}

class RewardClaim {
  final String id;
  final String userId;
  final String rewardId;
  final int pointsUsed;
  final RewardClaimStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final User? user;
  final Reward? reward;

  const RewardClaim({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.pointsUsed,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.user,
    this.reward,
  });

  factory RewardClaim.fromJson(Map<String, dynamic> json) {
    return RewardClaim(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      rewardId:
          json['rewardId'] as String? ?? json['reward_id'] as String? ?? '',
      pointsUsed:
          json['pointsUsed'] as int? ?? json['points_used'] as int? ?? 0,
      status: RewardClaimStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'PENDING'),
        orElse: () => RewardClaimStatus.PENDING,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String? ??
          json['created_at'] as String? ??
          DateTime.now().toIso8601String()),
      processedAt: json['processedAt'] != null || json['processed_at'] != null
          ? DateTime.parse((json['processedAt'] as String?) ??
              (json['processed_at'] as String?) ??
              DateTime.now().toIso8601String())
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      reward: json['reward'] != null
          ? Reward.fromJson(json['reward'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'rewardId': rewardId,
      'pointsUsed': pointsUsed,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'user': user?.toJson(),
      'reward': reward?.toJson(),
    };
  }

  String get formattedPointsUsed => '${pointsUsed} pts';

  String get statusLabel {
    switch (status) {
      case RewardClaimStatus.PENDING:
        return 'En attente';
      case RewardClaimStatus.APPROVED:
        return 'Approuvée';
      case RewardClaimStatus.REJECTED:
        return 'Rejetée';
      case RewardClaimStatus.USED:
        return 'Utilisée';
    }
  }

  bool get isPending => status == RewardClaimStatus.PENDING;
  bool get isApproved => status == RewardClaimStatus.APPROVED;
  bool get isRejected => status == RewardClaimStatus.REJECTED;
  bool get isUsed => status == RewardClaimStatus.USED;
}

class LoyaltyStats {
  final int totalUsers;
  final int activeUsers;
  final int totalPointsDistributed;
  final int totalPointsRedeemed;
  final double averagePointsPerUser;
  final int totalRewardsClaimed;
  final int pendingClaims;
  final Map<String, int> pointsBySource;
  final Map<String, int> redemptionsByType;

  const LoyaltyStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalPointsDistributed,
    required this.totalPointsRedeemed,
    required this.averagePointsPerUser,
    required this.totalRewardsClaimed,
    required this.pendingClaims,
    required this.pointsBySource,
    required this.redemptionsByType,
  });

  factory LoyaltyStats.fromJson(Map<String, dynamic> json) {
    return LoyaltyStats(
      totalUsers:
          json['totalUsers'] as int? ?? json['total_users'] as int? ?? 0,
      activeUsers:
          json['activeUsers'] as int? ?? json['active_users'] as int? ?? 0,
      totalPointsDistributed: json['totalPointsDistributed'] as int? ??
          json['total_points_distributed'] as int? ??
          0,
      totalPointsRedeemed: json['totalPointsRedeemed'] as int? ??
          json['total_points_redeemed'] as int? ??
          0,
      averagePointsPerUser:
          (json['averagePointsPerUser'] as num?)?.toDouble() ??
              (json['average_points_per_user'] as num?)?.toDouble() ??
              0.0,
      totalRewardsClaimed: json['totalRewardsClaimed'] as int? ??
          json['total_rewards_claimed'] as int? ??
          0,
      pendingClaims:
          json['pendingClaims'] as int? ?? json['pending_claims'] as int? ?? 0,
      pointsBySource: Map<String, int>.from(json['pointsBySource'] as Map? ??
          json['points_by_source'] as Map? ??
          {}),
      redemptionsByType: Map<String, int>.from(
          json['redemptionsByType'] as Map? ??
              json['redemptions_by_type'] as Map? ??
              {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalPointsDistributed': totalPointsDistributed,
      'totalPointsRedeemed': totalPointsRedeemed,
      'averagePointsPerUser': averagePointsPerUser,
      'totalRewardsClaimed': totalRewardsClaimed,
      'pendingClaims': pendingClaims,
      'pointsBySource': pointsBySource,
      'redemptionsByType': redemptionsByType,
    };
  }

  String get formattedTotalPointsDistributed =>
      '${totalPointsDistributed.toString()} pts';
  String get formattedTotalPointsRedeemed =>
      '${totalPointsRedeemed.toString()} pts';
  String get formattedAveragePoints =>
      '${averagePointsPerUser.toStringAsFixed(0)} pts';

  double get redemptionRate {
    if (totalPointsDistributed == 0) return 0.0;
    return (totalPointsRedeemed / totalPointsDistributed) * 100;
  }

  String get formattedRedemptionRate => '${redemptionRate.toStringAsFixed(1)}%';

  double get userEngagementRate {
    if (totalUsers == 0) return 0.0;
    return (activeUsers / totalUsers) * 100;
  }

  String get formattedEngagementRate =>
      '${userEngagementRate.toStringAsFixed(1)}%';
}

// Enums
enum PointTransactionType {
  EARNED,
  SPENT,
}

enum PointSource {
  ORDER,
  REFERRAL,
  REWARD,
}

enum RewardType {
  DISCOUNT,
  FREE_DELIVERY,
  CASHBACK,
  GIFT,
}

enum RewardClaimStatus {
  PENDING,
  APPROVED,
  REJECTED,
  USED,
}

// Extensions pour les couleurs et icônes
extension PointTransactionTypeExtension on PointTransactionType {
  Color get color {
    switch (this) {
      case PointTransactionType.EARNED:
        return AppColors.success;
      case PointTransactionType.SPENT:
        return AppColors.warning;
    }
  }

  IconData get icon {
    switch (this) {
      case PointTransactionType.EARNED:
        return Icons.add_circle;
      case PointTransactionType.SPENT:
        return Icons.remove_circle;
    }
  }
}

extension PointSourceExtension on PointSource {
  Color get color {
    switch (this) {
      case PointSource.ORDER:
        return AppColors.primary;
      case PointSource.REFERRAL:
        return AppColors.success;
      case PointSource.REWARD:
        return AppColors.violet;
    }
  }

  IconData get icon {
    switch (this) {
      case PointSource.ORDER:
        return Icons.shopping_cart;
      case PointSource.REFERRAL:
        return Icons.people;
      case PointSource.REWARD:
        return Icons.card_giftcard;
    }
  }
}

extension RewardTypeExtension on RewardType {
  Color get color {
    switch (this) {
      case RewardType.DISCOUNT:
        return AppColors.primary;
      case RewardType.FREE_DELIVERY:
        return AppColors.success;
      case RewardType.CASHBACK:
        return AppColors.warning;
      case RewardType.GIFT:
        return AppColors.violet;
    }
  }

  IconData get icon {
    switch (this) {
      case RewardType.DISCOUNT:
        return Icons.percent;
      case RewardType.FREE_DELIVERY:
        return Icons.local_shipping;
      case RewardType.CASHBACK:
        return Icons.account_balance_wallet;
      case RewardType.GIFT:
        return Icons.card_giftcard;
    }
  }
}

extension RewardClaimStatusExtension on RewardClaimStatus {
  Color get color {
    switch (this) {
      case RewardClaimStatus.PENDING:
        return AppColors.warning;
      case RewardClaimStatus.APPROVED:
        return AppColors.success;
      case RewardClaimStatus.REJECTED:
        return AppColors.error;
      case RewardClaimStatus.USED:
        return AppColors.info;
    }
  }

  IconData get icon {
    switch (this) {
      case RewardClaimStatus.PENDING:
        return Icons.hourglass_empty;
      case RewardClaimStatus.APPROVED:
        return Icons.check_circle;
      case RewardClaimStatus.REJECTED:
        return Icons.cancel;
      case RewardClaimStatus.USED:
        return Icons.check_circle_outline;
    }
  }
}
