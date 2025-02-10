class AdminProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profileImage;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? preferences;

  AdminProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profileImage,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
    this.preferences,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      role: json['role'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'profileImage': profileImage,
        'role': role,
        'isActive': isActive,
        'preferences': preferences,
      };

  AdminProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    Map<String, dynamic>? preferences,
  }) {
    return AdminProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
      lastLogin: lastLogin,
      preferences: preferences ?? this.preferences,
    );
  }
}
