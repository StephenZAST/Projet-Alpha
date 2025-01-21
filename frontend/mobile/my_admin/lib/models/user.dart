enum UserRole { SUPER_ADMIN, ADMIN, DELIVER }

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

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.avatar,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'],
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == json['role'],
        orElse: () => UserRole.ADMIN,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
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
      };
}
