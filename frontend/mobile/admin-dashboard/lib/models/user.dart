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

  String toApiString() {
    return toString().split('.').last;
  }

  static UserRole? fromString(String? value) {
    if (value == null) return null;
    try {
      return UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == value.toUpperCase(),
      );
    } catch (e) {
      print('[UserRole] Invalid role value: $value');
      return null;
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
      print('[User] Parsing user data: ${json['id']}');

      String safeString(dynamic value, String defaultValue) {
        if (value == null) return defaultValue;
        return value.toString();
      }

      return User(
        id: safeString(json['id'], ''),
        email: safeString(json['email'], ''),
        firstName: safeString(
            json['firstName'] ?? json['first_name'], ''), // Ajout de first_name
        lastName: safeString(
            json['lastName'] ?? json['last_name'], ''), // Ajout de last_name
        phone: json['phone']?.toString(),
        role: UserRole.values.firstWhere(
          (e) =>
              e.toString().split('.').last ==
              (json['role'] ?? 'CLIENT').toString().toUpperCase(),
          orElse: () => UserRole.CLIENT,
        ),
        referralCode: json['referralCode']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : DateTime.now(),
        isActive: json['isActive'] ?? true,
        loyaltyPoints: json['loyaltyPoints'] ?? 0,
        affiliateBalance: json['affiliateBalance'] != null
            ? (json['affiliateBalance'] as num).toDouble()
            : null,
        affiliateCode: json['affiliateCode']?.toString(),
      );
    } catch (e) {
      print('[User] Error parsing User JSON: $e');
      print('[User] Problematic JSON: $json');
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
