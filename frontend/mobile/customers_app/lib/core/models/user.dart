/// 👤 Modèle Utilisateur - Alpha Client App
///
/// Modèle de données utilisateur selon le backend Alpha Pressing
/// Référence: backend/src/models/types.ts - User interface
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? profile;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
  });

  /// 📝 Nom complet de l'utilisateur
  String get fullName => '$firstName $lastName';

  /// 📝 Initiales de l'utilisateur
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  /// 🏠 Adresse par défaut (pour commandes flash)
  Address? get defaultAddress => profile?.defaultAddress;

  /// 💳 Méthode de paiement par défaut
  PaymentMethod? get defaultPaymentMethod => profile?.defaultPaymentMethod;

  /// 🎯 Vérifier si l'utilisateur peut faire des commandes flash
  bool get canMakeFlashOrders => defaultAddress != null;

  /// 📊 Conversion depuis JSON (API Response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (role) => role.name.toLowerCase() == json['role'].toLowerCase(),
        orElse: () => UserRole.client,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role.name.toUpperCase(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profile': profile?.toJson(),
    };
  }

  /// 🔄 Copie avec modifications
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? profile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
    );
  }
}

/// 🎭 Rôles utilisateur
enum UserRole {
  client,
  admin,
  superAdmin,
  delivery,
  affiliate,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'Client';
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.superAdmin:
        return 'Super Administrateur';
      case UserRole.delivery:
        return 'Livreur';
      case UserRole.affiliate:
        return 'Affilié';
    }
  }
}

/// 👤 Profil utilisateur étendu
class UserProfile {
  final String? avatar;
  final DateTime? dateOfBirth;
  final String? gender;
  final Address? defaultAddress;
  final PaymentMethod? defaultPaymentMethod;
  final NotificationPreferences? notificationPreferences;
  final LoyaltyInfo? loyaltyInfo;

  UserProfile({
    this.avatar,
    this.dateOfBirth,
    this.gender,
    this.defaultAddress,
    this.defaultPaymentMethod,
    this.notificationPreferences,
    this.loyaltyInfo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      avatar: json['avatar'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      defaultAddress: json['defaultAddress'] != null
          ? Address.fromJson(json['defaultAddress'])
          : null,
      defaultPaymentMethod: json['defaultPaymentMethod'] != null
          ? PaymentMethod.fromJson(json['defaultPaymentMethod'])
          : null,
      notificationPreferences: json['notificationPreferences'] != null
          ? NotificationPreferences.fromJson(json['notificationPreferences'])
          : null,
      loyaltyInfo: json['loyaltyInfo'] != null
          ? LoyaltyInfo.fromJson(json['loyaltyInfo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'defaultAddress': defaultAddress?.toJson(),
      'defaultPaymentMethod': defaultPaymentMethod?.toJson(),
      'notificationPreferences': notificationPreferences?.toJson(),
      'loyaltyInfo': loyaltyInfo?.toJson(),
    };
  }
}

/// 🏠 Modèle d'adresse
class Address {
  final String id;
  final String street;
  final String city;
  final String postalCode;
  final String country;
  final String? apartment;
  final String? instructions;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  Address({
    required this.id,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
    this.apartment,
    this.instructions,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });

  /// 📍 Adresse formatée
  String get formattedAddress {
    String address = street;
    if (apartment != null && apartment!.isNotEmpty) {
      address += ', $apartment';
    }
    address += '\n$postalCode $city';
    return address;
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      street: json['street'],
      city: json['city'],
      postalCode: json['postalCode'],
      country: json['country'],
      apartment: json['apartment'],
      instructions: json['instructions'],
      isDefault: json['isDefault'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'apartment': apartment,
      'instructions': instructions,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// 💳 Méthode de paiement
class PaymentMethod {
  final String id;
  final PaymentType type;
  final String? cardLast4;
  final String? cardBrand;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    this.cardLast4,
    this.cardBrand,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: PaymentType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => PaymentType.card,
      ),
      cardLast4: json['cardLast4'],
      cardBrand: json['cardBrand'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'cardLast4': cardLast4,
      'cardBrand': cardBrand,
      'isDefault': isDefault,
    };
  }
}

enum PaymentType {
  card,
  paypal,
  applePay,
  googlePay,
}

/// 🔔 Préférences de notification
class NotificationPreferences {
  final bool orderUpdates;
  final bool promotions;
  final bool newsletter;
  final bool sms;
  final bool push;
  final bool loyaltyUpdates;

  NotificationPreferences({
    required this.orderUpdates,
    required this.promotions,
    required this.newsletter,
    required this.sms,
    required this.push,
    this.loyaltyUpdates = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      orderUpdates: json['orderUpdates'] ?? true,
      promotions: json['promotions'] ?? true,
      newsletter: json['newsletter'] ?? false,
      sms: json['sms'] ?? true,
      push: json['push'] ?? true,
      loyaltyUpdates: json['loyaltyUpdates'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderUpdates': orderUpdates,
      'promotions': promotions,
      'newsletter': newsletter,
      'sms': sms,
      'push': push,
      'loyaltyUpdates': loyaltyUpdates,
    };
  }

  /// 🔄 Copie avec modifications (utility for UI updates)
  NotificationPreferences copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? newsletter,
    bool? sms,
    bool? push,
    bool? loyaltyUpdates,
  }) {
    return NotificationPreferences(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      newsletter: newsletter ?? this.newsletter,
      sms: sms ?? this.sms,
      push: push ?? this.push,
      loyaltyUpdates: loyaltyUpdates ?? this.loyaltyUpdates,
    );
  }
}

/// 🎁 Informations de fidélité
class LoyaltyInfo {
  final int points;
  final String tier;
  final int pointsToNextTier;
  final double totalSpent;

  LoyaltyInfo({
    required this.points,
    required this.tier,
    required this.pointsToNextTier,
    required this.totalSpent,
  });

  factory LoyaltyInfo.fromJson(Map<String, dynamic> json) {
    return LoyaltyInfo(
      points: json['points'] ?? 0,
      tier: json['tier'] ?? 'Bronze',
      pointsToNextTier: json['pointsToNextTier'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'tier': tier,
      'pointsToNextTier': pointsToNextTier,
      'totalSpent': totalSpent,
    };
  }
}
