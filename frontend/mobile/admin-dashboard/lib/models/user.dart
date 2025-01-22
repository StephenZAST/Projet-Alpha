import 'dart:math';

enum UserRole {
  SUPER_ADMIN('Super Admin'),
  ADMIN('Admin'),
  DELIVER('Livreur');

  final String label;
  const UserRole(this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.toString().split('.').last == value.toUpperCase(),
      orElse: () => UserRole.ADMIN,
    );
  }

  bool get isSuperAdmin => this == UserRole.SUPER_ADMIN;
  bool get isAdmin => this == UserRole.ADMIN || this == UserRole.SUPER_ADMIN;
  bool get isDeliver => this == UserRole.DELIVER;
}

class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Map<String, dynamic>>? addresses;
  final String? referralCode;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.addresses,
    this.referralCode,
  });

  String get name => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory User.fromJson(Map<String, dynamic> json) {
    print('[User] Creating user from JSON: $json'); // Log pour déboguer
    try {
      final user = User(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        phone: json['phone'] as String?,
        avatar: json['avatar'] as String?,
        role: UserRole.fromString(json['role'] as String),
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        addresses: json['addresses'] != null
            ? List<Map<String, dynamic>>.from(json['addresses'] as List)
            : null,
        referralCode: json['referral_code'] as String?,
      );
      print('[User] Successfully created user object: ${user.toJson()}');
      return user;
    } catch (e) {
      print('[User] Error creating user from JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'avatar': avatar,
        'role': role.toString().split('.').last,
        'isActive': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'addresses': addresses,
        'referral_code': referralCode,
      };

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? addresses,
    String? referralCode,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addresses: addresses ?? this.addresses,
      referralCode: referralCode ?? this.referralCode,
    );
  }

  bool hasPermission(Set<UserRole> allowedRoles) {
    return allowedRoles.contains(role) || role == UserRole.SUPER_ADMIN;
  }

  String get initials {
    if (firstName != null &&
        firstName!.isNotEmpty &&
        lastName != null &&
        lastName!.isNotEmpty) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    return email.substring(0, min(2, email.length)).toUpperCase();
  }

  String get displayRole => role.label;

  bool get canManageUsers => role.isAdmin;
  bool get canManageSettings => role.isSuperAdmin;
  bool get canViewReports => role.isAdmin;
  bool get canManageDeliveries => role.isAdmin || role.isDeliver;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() => 'User(id: $id, email: $email, role: ${role.label})';
}

// Extension utilitaire pour la gestion des dates
extension UserDateExtension on User {
  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedUpdatedAt {
    if (updatedAt == null) return 'Non modifié';
    return '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}';
  }

  bool get isRecentlyActive {
    final lastActivity = updatedAt ?? createdAt;
    return DateTime.now().difference(lastActivity) < Duration(days: 7);
  }
}
