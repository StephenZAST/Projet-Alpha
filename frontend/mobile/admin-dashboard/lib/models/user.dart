import 'dart:ui';

import '../constants.dart';

enum UserRole { SUPER_ADMIN, ADMIN, CLIENT, AFFILIATE, DELIVERY }

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.SUPER_ADMIN:
        return 'Super Admin';
      case UserRole.ADMIN:
        return 'Admin';
      case UserRole.CLIENT:
        return 'Client';
      case UserRole.AFFILIATE:
        return 'Affilié';
      case UserRole.DELIVERY:
        return 'Livreur';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.SUPER_ADMIN:
      case UserRole.ADMIN:
        return AppColors.error;
      case UserRole.AFFILIATE:
        return AppColors.accent;
      case UserRole.CLIENT:
        return AppColors.success;
      case UserRole.DELIVERY:
        return AppColors.pending;
    }
  }
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  final String? referralCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int loyaltyPoints;
  final double? affiliateBalance;
  final String? affiliateCode;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    this.referralCode,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.loyaltyPoints = 0,
    this.affiliateBalance,
    this.affiliateCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] ?? '', // Valeur par défaut si null
        lastName: json['lastName'] ?? '', // Valeur par défaut si null
        phone: json['phone'],
        role: UserRole.values.firstWhere(
          (e) =>
              e.toString().split('.').last ==
              (json['role'] as String).toUpperCase(),
          orElse: () => UserRole.CLIENT,
        ),
        referralCode: json['referralCode'],
        createdAt: DateTime.parse(
            json['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json['updatedAt'] ?? DateTime.now().toIso8601String()),
        isActive: json['isActive'] ?? true,
        loyaltyPoints: json['loyaltyPoints'] ?? 0,
        affiliateBalance: json['affiliateBalance'] != null
            ? (json['affiliateBalance'] as num).toDouble()
            : null,
        affiliateCode: json['affiliateCode'],
      );
    } catch (e) {
      print('Error parsing User JSON: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role.toString().split('.').last,
      'referralCode': referralCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'loyaltyPoints': loyaltyPoints,
      'affiliateBalance': affiliateBalance,
      'affiliateCode': affiliateCode,
    };
  }

  String get fullName => '$firstName $lastName';
}
