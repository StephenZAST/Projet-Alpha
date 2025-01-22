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
  final String name;
  final String? phoneNumber;
  final String? avatar;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? preferences;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.avatar,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      avatar: json['avatar'] as String?,
      role: UserRole.fromString(json['role'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'avatar': avatar,
        'role': role.toString().split('.').last,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
        'preferences': preferences,
      };

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? avatar,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
    );
  }

  bool hasPermission(Set<UserRole> allowedRoles) {
    return allowedRoles.contains(role) || role == UserRole.SUPER_ADMIN;
  }

  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
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
  String toString() => 'User(id: $id, name: $name, role: ${role.label})';
}

// Extension utilitaire pour la gestion des dates
extension UserDateExtension on User {
  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedLastLogin {
    return lastLogin != null
        ? '${lastLogin!.day}/${lastLogin!.month}/${lastLogin!.year}'
        : 'Jamais connecté';
  }

  bool get isRecentlyActive {
    if (lastLogin == null) return false;
    return DateTime.now().difference(lastLogin!) < Duration(days: 7);
  }
}
