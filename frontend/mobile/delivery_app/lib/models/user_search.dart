import 'package:flutter/material.dart';
import '../constants.dart';

/// 👤 Modèle Utilisateur pour la Recherche
/// 
/// Représente un utilisateur générique pour la recherche par ID
/// Compatible avec l'API backend /api/users/search-by-id
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée un utilisateur depuis JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      phone: json['phone'] as String?,
      role: _parseRole(json['role'] as String? ?? 'CLIENT'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.now()),
    );
  }

  /// Parse le rôle depuis une chaîne
  static UserRole _parseRole(String roleString) {
    switch (roleString.toUpperCase()) {
      case 'SUPER_ADMIN':
        return UserRole.SUPER_ADMIN;
      case 'ADMIN':
        return UserRole.ADMIN;
      case 'AFFILIATE':
        return UserRole.AFFILIATE;
      case 'DELIVERY':
        return UserRole.DELIVERY;
      case 'CLIENT':
      default:
        return UserRole.CLIENT;
    }
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Nom complet de l'utilisateur
  String get fullName => '$firstName $lastName';

  /// Initiales de l'utilisateur
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 👤 Énumération des Rôles Utilisateur
enum UserRole {
  SUPER_ADMIN,
  ADMIN,
  AFFILIATE,
  DELIVERY,
  CLIENT,
}

extension UserRoleExtension on UserRole {
  /// Nom d'affichage du rôle
  String get label {
    switch (this) {
      case UserRole.SUPER_ADMIN:
        return 'Super Admin';
      case UserRole.ADMIN:
        return 'Admin';
      case UserRole.AFFILIATE:
        return 'Affilié';
      case UserRole.DELIVERY:
        return 'Livreur';
      case UserRole.CLIENT:
        return 'Client';
    }
  }

  /// Couleur du rôle - Utilise le design system AppColors
  Color get color {
    switch (this) {
      case UserRole.SUPER_ADMIN:
        return AppColors.secondary; // Violet
      case UserRole.ADMIN:
        return AppColors.primary; // Bleu
      case UserRole.AFFILIATE:
        return AppColors.accent; // Cyan
      case UserRole.DELIVERY:
        return AppColors.warning; // Amber/Orange
      case UserRole.CLIENT:
        return AppColors.info; // Bleu clair
    }
  }

  /// Icône du rôle
  IconData get icon {
    switch (this) {
      case UserRole.SUPER_ADMIN:
        return Icons.admin_panel_settings;
      case UserRole.ADMIN:
        return Icons.security;
      case UserRole.AFFILIATE:
        return Icons.handshake;
      case UserRole.DELIVERY:
        return Icons.local_shipping;
      case UserRole.CLIENT:
        return Icons.person;
    }
  }
}
