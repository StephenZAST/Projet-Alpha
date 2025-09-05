// Imports nécessaires
import 'package:flutter/material.dart';
import '../constants.dart';
import 'user.dart';
import 'order.dart';

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
  final AffiliateLevel? level;
  final int totalReferrals;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

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
    this.level,
    required this.totalReferrals,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory AffiliateProfile.fromJson(Map<String, dynamic> json) {
    return AffiliateProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      affiliateCode: json['affiliate_code'] as String? ??
          json['affiliateCode'] as String? ??
          '',
      parentAffiliateId: json['parent_affiliate_id'] as String?,
      commissionRate: (json['commission_rate'] is String
          ? double.tryParse(json['commission_rate']) ?? 0.0
          : (json['commission_rate'] as num?)?.toDouble() ?? 0.0),
      commissionBalance: (json['commission_balance'] is String
          ? double.tryParse(json['commission_balance']) ?? 0.0
          : (json['commission_balance'] as num?)?.toDouble() ?? 0.0),
      totalEarned: (json['total_earned'] is String
          ? double.tryParse(json['total_earned']) ?? 0.0
          : (json['total_earned'] as num?)?.toDouble() ?? 0.0),
      monthlyEarnings: (json['monthly_earnings'] is String
          ? double.tryParse(json['monthly_earnings']) ?? 0.0
          : (json['monthly_earnings'] as num?)?.toDouble() ?? 0.0),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      status: AffiliateStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'PENDING'),
        orElse: () => AffiliateStatus.PENDING,
      ),
      levelId: json['level_id'] as String?,
      level: json['level'] != null
          ? AffiliateLevel.fromJson(json['level'] as Map<String, dynamic>)
          : null,
      totalReferrals: json['total_referrals'] as int? ??
          json['totalReferrals'] as int? ??
          0,
      createdAt: DateTime.parse(json['created_at'] as String? ??
          json['createdAt'] as String? ??
          DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ??
          json['updatedAt'] as String? ??
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
      'affiliateCode': affiliateCode,
      'parent_affiliate_id': parentAffiliateId,
      'commission_rate': commissionRate,
      'commissionBalance': commissionBalance,
      'totalEarned': totalEarned,
      'monthlyEarnings': monthlyEarnings,
      'isActive': isActive,
      'status': status.name,
      'levelId': levelId,
      'level': level?.toJson(),
      'totalReferrals': totalReferrals,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }

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
    AffiliateLevel? level,
    int? totalReferrals,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
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
      level: level ?? this.level,
      totalReferrals: totalReferrals ?? this.totalReferrals,
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

  double get commissionPercentage => commissionRate;
  String get formattedCommissionRate => '${commissionRate.toStringAsFixed(1)}%';
  String get formattedBalance => '${commissionBalance.toStringAsFixed(0)} FCFA';
  String get formattedTotalEarned => '${totalEarned.toStringAsFixed(0)} FCFA';
  String get formattedMonthlyEarnings =>
      '${monthlyEarnings.toStringAsFixed(0)} FCFA';

  bool get isPending => status == AffiliateStatus.PENDING;
  bool get isApproved => status == AffiliateStatus.ACTIVE;
  bool get isSuspended => status == AffiliateStatus.SUSPENDED;

  String get statusLabel {
    switch (status) {
      case AffiliateStatus.PENDING:
        return 'En attente';
      case AffiliateStatus.ACTIVE:
        return 'Actif';
      case AffiliateStatus.SUSPENDED:
        return 'Suspendu';
    }
  }
}

class AffiliateLevel {
  final String id;
  final String name;
  final double minEarnings;
  final double commissionRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AffiliateLevel({
    required this.id,
    required this.name,
    required this.minEarnings,
    required this.commissionRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AffiliateLevel.fromJson(Map<String, dynamic> json) {
    return AffiliateLevel(
      id: json['id'] as String,
      name: json['name'] as String,
      minEarnings: (json['minEarnings'] as num).toDouble(),
      commissionRate: (json['commissionRate'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minEarnings': minEarnings,
      'commissionRate': commissionRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedMinEarnings => '${minEarnings.toStringAsFixed(0)} FCFA';
  String get formattedCommissionRate => '${commissionRate.toStringAsFixed(1)}%';
}

class CommissionTransaction {
  final String id;
  final String affiliateId;
  final String orderId;
  final double amount;
  final CommissionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Order? order;

  const CommissionTransaction({
    required this.id,
    required this.affiliateId,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.order,
  });

  factory CommissionTransaction.fromJson(Map<String, dynamic> json) {
    return CommissionTransaction(
      id: json['id'] as String,
      affiliateId: json['affiliateId'] as String,
      orderId: json['orderId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: CommissionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CommissionStatus.PENDING,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      order: json['order'] != null
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'affiliateId': affiliateId,
      'orderId': orderId,
      'amount': amount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'order': order?.toJson(),
    };
  }

  String get formattedAmount => '${amount.toStringAsFixed(0)} FCFA';

  String get statusLabel {
    switch (status) {
      case CommissionStatus.PENDING:
        return 'En attente';
      case CommissionStatus.APPROVED:
        return 'Approuvée';
      case CommissionStatus.PAID:
        return 'Payée';
      case CommissionStatus.REJECTED:
        return 'Rejetée';
    }
  }
}

class WithdrawalRequest {
  final String id;
  final String affiliateId;
  final double amount;
  final WithdrawalStatus status;
  final String? reason;
  final DateTime createdAt;
  final DateTime? processedAt;
  final AffiliateProfile? affiliate;

  const WithdrawalRequest({
    required this.id,
    required this.affiliateId,
    required this.amount,
    required this.status,
    this.reason,
    required this.createdAt,
    this.processedAt,
    this.affiliate,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'] as String,
      affiliateId: json['affiliateId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WithdrawalStatus.PENDING,
      ),
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      affiliate: json['affiliate'] != null
          ? AffiliateProfile.fromJson(json['affiliate'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'affiliateId': affiliateId,
      'amount': amount,
      'status': status.name,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'affiliate': affiliate?.toJson(),
    };
  }

  String get formattedAmount => '${amount.toStringAsFixed(0)} FCFA';

  String get statusLabel {
    switch (status) {
      case WithdrawalStatus.PENDING:
        return 'En attente';
      case WithdrawalStatus.APPROVED:
        return 'Approuvée';
      case WithdrawalStatus.REJECTED:
        return 'Rejetée';
    }
  }
}

class AffiliateStats {
  final int totalAffiliates;
  final int activeAffiliates;
  final int pendingAffiliates;
  final int suspendedAffiliates;
  final double totalCommissions;
  final double monthlyCommissions;
  final double averageCommissionRate;
  final int totalReferrals;

  const AffiliateStats({
    required this.totalAffiliates,
    required this.activeAffiliates,
    required this.pendingAffiliates,
    required this.suspendedAffiliates,
    required this.totalCommissions,
    required this.monthlyCommissions,
    required this.averageCommissionRate,
    required this.totalReferrals,
  });

  factory AffiliateStats.fromJson(Map<String, dynamic> json) {
    return AffiliateStats(
      totalAffiliates: json['totalAffiliates'] as int,
      activeAffiliates: json['activeAffiliates'] as int,
      pendingAffiliates: json['pendingAffiliates'] as int,
      suspendedAffiliates: json['suspendedAffiliates'] as int,
      totalCommissions: (json['totalCommissions'] as num).toDouble(),
      monthlyCommissions: (json['monthlyCommissions'] as num).toDouble(),
      averageCommissionRate: (json['averageCommissionRate'] as num).toDouble(),
      totalReferrals: json['totalReferrals'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAffiliates': totalAffiliates,
      'activeAffiliates': activeAffiliates,
      'pendingAffiliates': pendingAffiliates,
      'suspendedAffiliates': suspendedAffiliates,
      'totalCommissions': totalCommissions,
      'monthlyCommissions': monthlyCommissions,
      'averageCommissionRate': averageCommissionRate,
      'totalReferrals': totalReferrals,
    };
  }

  String get formattedTotalCommissions =>
      '${totalCommissions.toStringAsFixed(0)} FCFA';
  String get formattedMonthlyCommissions =>
      '${monthlyCommissions.toStringAsFixed(0)} FCFA';
  String get formattedAverageRate =>
      '${averageCommissionRate.toStringAsFixed(1)}%';
}

// Enums
enum AffiliateStatus {
  PENDING,
  ACTIVE,
  SUSPENDED,
}

enum CommissionStatus {
  PENDING,
  APPROVED,
  PAID,
  REJECTED,
}

enum WithdrawalStatus {
  PENDING,
  APPROVED,
  REJECTED,
}

// Extensions pour les couleurs
extension AffiliateStatusExtension on AffiliateStatus {
  Color get color {
    switch (this) {
      case AffiliateStatus.PENDING:
        return AppColors.warning;
      case AffiliateStatus.ACTIVE:
        return AppColors.success;
      case AffiliateStatus.SUSPENDED:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case AffiliateStatus.PENDING:
        return Icons.hourglass_empty;
      case AffiliateStatus.ACTIVE:
        return Icons.check_circle;
      case AffiliateStatus.SUSPENDED:
        return Icons.block;
    }
  }
}

extension CommissionStatusExtension on CommissionStatus {
  Color get color {
    switch (this) {
      case CommissionStatus.PENDING:
        return AppColors.warning;
      case CommissionStatus.APPROVED:
        return AppColors.info;
      case CommissionStatus.PAID:
        return AppColors.success;
      case CommissionStatus.REJECTED:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case CommissionStatus.PENDING:
        return Icons.schedule;
      case CommissionStatus.APPROVED:
        return Icons.thumb_up;
      case CommissionStatus.PAID:
        return Icons.payment;
      case CommissionStatus.REJECTED:
        return Icons.thumb_down;
    }
  }
}

extension WithdrawalStatusExtension on WithdrawalStatus {
  Color get color {
    switch (this) {
      case WithdrawalStatus.PENDING:
        return AppColors.warning;
      case WithdrawalStatus.APPROVED:
        return AppColors.success;
      case WithdrawalStatus.REJECTED:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case WithdrawalStatus.PENDING:
        return Icons.schedule;
      case WithdrawalStatus.APPROVED:
        return Icons.check_circle;
      case WithdrawalStatus.REJECTED:
        return Icons.cancel;
    }
  }
}
