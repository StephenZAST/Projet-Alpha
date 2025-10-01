/// 🏠 Modèle d'Adresse - Alpha Client App
///
/// Modèle de données pour les adresses utilisateur selon le backend Alpha Pressing
/// Référence: backend/src/controllers/address.controller.ts
class Address {
  final String id;
  final String userId;
  final String name;
  final String street;
  final String city;
  final String postalCode;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    this.gpsLatitude,
    this.gpsLongitude,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 📍 Adresse formatée pour affichage
  String get formattedAddress {
    return '$street\n$postalCode $city';
  }

  /// 📍 Adresse complète sur une ligne
  String get fullAddress {
    return '$name - $street, $postalCode $city';
  }

  /// 📍 Adresse courte pour les listes
  String get shortAddress {
    return '$name - $city';
  }

  /// 🗺️ Vérifier si l'adresse a des coordonnées GPS
  bool get hasGpsCoordinates {
    return gpsLatitude != null && gpsLongitude != null;
  }

  /// 📊 Conversion depuis JSON (API Response)
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? json['postalCode']?.toString() ?? '',
      gpsLatitude: json['gps_latitude']?.toDouble() ?? json['gpsLatitude']?.toDouble(),
      gpsLongitude: json['gps_longitude']?.toDouble() ?? json['gpsLongitude']?.toDouble(),
      isDefault: json['is_default'] ?? json['isDefault'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  /// 📤 Conversion vers JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'street': street,
      'city': city,
      'postal_code': postalCode,
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 📤 Conversion pour création (sans ID et dates)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'street': street,
      'city': city,
      'postal_code': postalCode,
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'is_default': isDefault,
    };
  }

  /// 📤 Conversion pour mise à jour (sans ID et dates de création)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'street': street,
      'city': city,
      'postal_code': postalCode,
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'is_default': isDefault,
    };
  }

  /// 🔄 Copie avec modifications
  Address copyWith({
    String? id,
    String? userId,
    String? name,
    String? street,
    String? city,
    String? postalCode,
    double? gpsLatitude,
    double? gpsLongitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      gpsLatitude: gpsLatitude ?? this.gpsLatitude,
      gpsLongitude: gpsLongitude ?? this.gpsLongitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Address(id: $id, name: $name, city: $city, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 📋 Résultat d'opération sur les adresses
class AddressResult {
  final bool isSuccess;
  final Address? address;
  final String? error;
  final String? message;

  AddressResult._({
    required this.isSuccess,
    this.address,
    this.error,
    this.message,
  });

  /// ✅ Résultat de succès
  factory AddressResult.success({
    Address? address,
    String? message,
  }) {
    return AddressResult._(
      isSuccess: true,
      address: address,
      message: message ?? 'Opération réussie',
    );
  }

  /// ❌ Résultat d'erreur
  factory AddressResult.error(String error) {
    return AddressResult._(
      isSuccess: false,
      error: error,
    );
  }

  /// 📥 Création depuis JSON API
  factory AddressResult.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      return AddressResult.success(
        address: Address.fromJson(json['data']),
        message: json['message'],
      );
    } else {
      return AddressResult.error(
        json['error'] ?? 'Erreur inconnue',
      );
    }
  }
}

/// 📋 Liste d'adresses avec métadonnées
class AddressList {
  final List<Address> addresses;
  final Address? defaultAddress;
  final int total;

  AddressList({
    required this.addresses,
    this.defaultAddress,
    required this.total,
  });

  /// 📊 Conversion depuis JSON API
  factory AddressList.fromJson(Map<String, dynamic> json) {
    final List<dynamic> addressesJson = json['data'] ?? [];
    final addresses = addressesJson
        .map((addressJson) => Address.fromJson(addressJson))
        .toList();

    // Trouver l'adresse par défaut
    final defaultAddress = addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => addresses.isNotEmpty ? addresses.first : null as Address,
    );

    return AddressList(
      addresses: addresses,
      defaultAddress: defaultAddress,
      total: addresses.length,
    );
  }

  /// 🔍 Rechercher une adresse par ID
  Address? findById(String id) {
    try {
      return addresses.firstWhere((address) => address.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 🏠 Obtenir les adresses non-par défaut
  List<Address> get nonDefaultAddresses {
    return addresses.where((address) => !address.isDefault).toList();
  }

  /// ✅ Vérifier si l'utilisateur a des adresses
  bool get hasAddresses => addresses.isNotEmpty;

  /// ✅ Vérifier si l'utilisateur a une adresse par défaut
  bool get hasDefaultAddress => defaultAddress != null;
}

/// 🎯 DTO pour création d'adresse
class CreateAddressRequest {
  final String name;
  final String street;
  final String city;
  final String postalCode;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final bool isDefault;

  CreateAddressRequest({
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    this.gpsLatitude,
    this.gpsLongitude,
    this.isDefault = false,
  });

  /// ✅ Validation des données
  bool get isValid {
    return name.trim().isNotEmpty &&
           street.trim().isNotEmpty &&
           city.trim().isNotEmpty &&
           postalCode.trim().isNotEmpty;
  }

  /// 📤 Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'street': street.trim(),
      'city': city.trim(),
      'postal_code': postalCode.trim(),
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'is_default': isDefault,
    };
  }
}

/// 🎯 DTO pour mise à jour d'adresse
class UpdateAddressRequest {
  final String? name;
  final String? street;
  final String? city;
  final String? postalCode;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final bool? isDefault;

  UpdateAddressRequest({
    this.name,
    this.street,
    this.city,
    this.postalCode,
    this.gpsLatitude,
    this.gpsLongitude,
    this.isDefault,
  });

  /// ✅ Vérifier si au moins un champ est modifié
  bool get hasChanges {
    return name != null ||
           street != null ||
           city != null ||
           postalCode != null ||
           gpsLatitude != null ||
           gpsLongitude != null ||
           isDefault != null;
  }

  /// 📤 Conversion vers JSON (seulement les champs modifiés)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (name != null) json['name'] = name!.trim();
    if (street != null) json['street'] = street!.trim();
    if (city != null) json['city'] = city!.trim();
    if (postalCode != null) json['postal_code'] = postalCode!.trim();
    if (gpsLatitude != null) json['gps_latitude'] = gpsLatitude;
    if (gpsLongitude != null) json['gps_longitude'] = gpsLongitude;
    if (isDefault != null) json['is_default'] = isDefault;
    
    return json;
  }
}