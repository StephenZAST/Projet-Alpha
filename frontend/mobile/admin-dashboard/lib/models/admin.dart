class Admin {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final Map<String, dynamic>? preferences;

  Admin({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    required this.isActive,
    this.preferences,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return email;
  }

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isActive: json['isActive'] ?? true,
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'preferences': preferences,
    };
  }

  Admin copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    Map<String, dynamic>? preferences,
  }) {
    return Admin(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }
}

class AdminUpdateDTO {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final Map<String, dynamic>? preferences;

  AdminUpdateDTO({
    this.firstName,
    this.lastName,
    this.phone,
    this.preferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'preferences': preferences,
    }..removeWhere((key, value) => value == null);
  }
}
