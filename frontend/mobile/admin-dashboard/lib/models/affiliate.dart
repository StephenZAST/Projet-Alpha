import 'package:flutter/material.dart';

enum AffiliateStatus { PENDING, ACTIVE, SUSPENDED }

extension AffiliateStatusExtension on AffiliateStatus {
  String get label {
    switch (this) {
      case AffiliateStatus.PENDING:
        return 'En attente';
      case AffiliateStatus.ACTIVE:
        return 'Actif';
      case AffiliateStatus.SUSPENDED:
        return 'Suspendu';
    }
  }

  Color get color {
    switch (this) {
      case AffiliateStatus.PENDING:
        return Colors.orange;
      case AffiliateStatus.ACTIVE:
        return Colors.green;
      case AffiliateStatus.SUSPENDED:
        return Colors.red;
    }
  }
}

class Affiliate {
  final String id;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String affiliateCode;
  final double commissionBalance;
  final double totalEarned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double commissionRate;
  final AffiliateStatus status;
  final bool isActive;
  final int totalReferrals;
  final double monthlyEarnings;

  Affiliate({
    required this.id,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.affiliateCode,
    required this.commissionBalance,
    required this.totalEarned,
    required this.createdAt,
    required this.updatedAt,
    required this.commissionRate,
    required this.status,
    required this.isActive,
    required this.totalReferrals,
    required this.monthlyEarnings,
  });

  factory Affiliate.fromJson(Map<String, dynamic> json) {
    return Affiliate(
      id: json['id'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      affiliateCode: json['affiliateCode'] as String,
      commissionBalance: (json['commissionBalance'] as num).toDouble(),
      totalEarned: (json['totalEarned'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      commissionRate: (json['commissionRate'] as num).toDouble(),
      status: AffiliateStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String),
        orElse: () => AffiliateStatus.PENDING,
      ),
      isActive: json['isActive'] as bool,
      totalReferrals: json['totalReferrals'] as int,
      monthlyEarnings: (json['monthlyEarnings'] as num).toDouble(),
    );
  }

  String get fullName => '$firstName $lastName';
}

class AffiliateStats {
  final int pendingWithdrawals;
  final double totalCommissionsPaid;
  final int activeAffiliates;

  AffiliateStats({
    required this.pendingWithdrawals,
    required this.totalCommissionsPaid,
    required this.activeAffiliates,
  });

  factory AffiliateStats.fromJson(Map<String, dynamic> json) {
    return AffiliateStats(
      pendingWithdrawals: json['pendingWithdrawals'] as int,
      totalCommissionsPaid: (json['totalCommissionsPaid'] as num).toDouble(),
      activeAffiliates: json['activeAffiliates'] as int,
    );
  }
}

class CommissionConfig {
  final double commissionRate;
  final int rewardPoints;

  CommissionConfig({
    required this.commissionRate,
    required this.rewardPoints,
  });

  factory CommissionConfig.fromJson(Map<String, dynamic> json) {
    return CommissionConfig(
      commissionRate: (json['commissionRate'] as num).toDouble(),
      rewardPoints: json['rewardPoints'] as int,
    );
  }
}

class AffiliateResponse {
  final List<Affiliate> affiliates;
  final int total;
  final int currentPage;
  final int totalPages;

  AffiliateResponse({
    required this.affiliates,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  factory AffiliateResponse.fromJson(Map<String, dynamic> json) {
    return AffiliateResponse(
      affiliates: (json['data'] as List)
          .map((item) => Affiliate.fromJson(item))
          .toList(),
      total: json['total'] as int,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class WithdrawalRequest {
  final String id;
  final String affiliateId;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? notes;

  WithdrawalRequest({
    required this.id,
    required this.affiliateId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.notes,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'] as String,
      affiliateId: json['affiliateId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}
