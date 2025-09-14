class AdminProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String role;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.role,
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['firstName'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      role: json['role'] ?? 'ADMIN',
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AdminProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    String? role,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters pour les préférences communes
  bool get darkMode => preferences['darkMode'] ?? false;
  String get language => preferences['language'] ?? 'fr';
  bool get emailNotifications => preferences['emailNotifications'] ?? true;
  bool get pushNotifications => preferences['pushNotifications'] ?? true;
  String get timezone => preferences['timezone'] ?? 'Africa/Abidjan';

  @override
  String toString() {
    return 'AdminProfile(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminProfile &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.profileImageUrl == profileImageUrl &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        phoneNumber.hashCode ^
        profileImageUrl.hashCode ^
        role.hashCode;
  }
}