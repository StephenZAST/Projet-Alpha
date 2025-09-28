import 'dart:ui';

import '../constants.dart';

/// 👤 Modèle Utilisateur Livreur - Alpha Delivery App
/// 
/// Représente un utilisateur livreur avec toutes ses informations
/// et statistiques de performance.
class DeliveryUser {
  
  // ==========================================================================
  // 📦 PROPRIÉTÉS DE BASE
  // ==========================================================================
  
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // ==========================================================================
  // 📊 STATISTIQUES DE LIVRAISON
  // ==========================================================================
  
  final DeliveryStats? stats;
  final DeliveryProfile? profile;
  
  // ==========================================================================
  // 🏗️ CONSTRUCTEURS
  // ==========================================================================
  
  DeliveryUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
    this.profile,
  });
  
  /// Crée un utilisateur depuis JSON
  factory DeliveryUser.fromJson(Map<String, dynamic> json) {
    return DeliveryUser(
      id: json['id'] as String,
      email: json['email'] as String,
      // Support des formats backend : camelCase (API) et snake_case (DB)
      firstName: (json['firstName'] ?? json['first_name']) as String,
      lastName: (json['lastName'] ?? json['last_name']) as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      // Support des formats de date backend
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null 
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : (json['updatedAt'] != null 
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now()),
      stats: json['stats'] != null 
          ? DeliveryStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      profile: json['profile'] != null
          ? DeliveryProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }
  
  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'stats': stats?.toJson(),
      'profile': profile?.toJson(),
    };
  }
  
  // ==========================================================================
  // 🎯 GETTERS UTILITAIRES
  // ==========================================================================
  
  /// Nom complet du livreur
  String get fullName => '$firstName $lastName';
  
  /// Initiales du livreur
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }
  
  /// Vérifie si le livreur est actif
  bool get isActive => profile?.isActive ?? false;
  
  /// Vérifie si le livreur est disponible
  bool get isAvailable => profile?.isAvailable ?? false;
  
  /// Note moyenne du livreur
  double get averageRating => stats?.averageRating ?? 0.0;
  
  /// Nombre total de livraisons
  int get totalDeliveries => stats?.totalDeliveries ?? 0;
  
  /// Taux de réussite des livraisons
  double get successRate => stats?.successRate ?? 0.0;
  
  // ==========================================================================
  // 🔄 MÉTHODES DE COPIE
  // ==========================================================================
  
  /// Crée une copie avec des modifications
  DeliveryUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DeliveryStats? stats,
    DeliveryProfile? profile,
  }) {
    return DeliveryUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
      profile: profile ?? this.profile,
    );
  }
  
  @override
  String toString() {
    return 'DeliveryUser(id: $id, email: $email, fullName: $fullName)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryUser && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// 📊 Statistiques de Performance du Livreur
class DeliveryStats {
  
  // ==========================================================================
  // 📈 MÉTRIQUES DE PERFORMANCE
  // ==========================================================================
  
  final int totalDeliveries;
  final int completedDeliveries;
  final int cancelledDeliveries;
  final double averageRating;
  final double successRate;
  final Duration averageDeliveryTime;
  
  // ==========================================================================
  // 💰 MÉTRIQUES FINANCIÈRES
  // ==========================================================================
  
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final double dailyEarnings;
  
  // ==========================================================================
  // 📅 MÉTRIQUES TEMPORELLES
  // ==========================================================================
  
  final int deliveriesToday;
  final int deliveriesThisWeek;
  final int deliveriesThisMonth;
  
  // ==========================================================================
  // 🏗️ CONSTRUCTEURS
  // ==========================================================================
  
  DeliveryStats({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.cancelledDeliveries,
    required this.averageRating,
    required this.successRate,
    required this.averageDeliveryTime,
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.weeklyEarnings,
    required this.dailyEarnings,
    required this.deliveriesToday,
    required this.deliveriesThisWeek,
    required this.deliveriesThisMonth,
  });
  
  /// Crée des statistiques depuis JSON
  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      completedDeliveries: json['completed_deliveries'] as int? ?? 0,
      cancelledDeliveries: json['cancelled_deliveries'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      successRate: (json['success_rate'] as num?)?.toDouble() ?? 0.0,
      averageDeliveryTime: Duration(
        minutes: json['average_delivery_time_minutes'] as int? ?? 0,
      ),
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      monthlyEarnings: (json['monthly_earnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (json['weekly_earnings'] as num?)?.toDouble() ?? 0.0,
      dailyEarnings: (json['daily_earnings'] as num?)?.toDouble() ?? 0.0,
      deliveriesToday: json['deliveries_today'] as int? ?? 0,
      deliveriesThisWeek: json['deliveries_this_week'] as int? ?? 0,
      deliveriesThisMonth: json['deliveries_this_month'] as int? ?? 0,
    );
  }
  
  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {
      'total_deliveries': totalDeliveries,
      'completed_deliveries': completedDeliveries,
      'cancelled_deliveries': cancelledDeliveries,
      'average_rating': averageRating,
      'success_rate': successRate,
      'average_delivery_time_minutes': averageDeliveryTime.inMinutes,
      'total_earnings': totalEarnings,
      'monthly_earnings': monthlyEarnings,
      'weekly_earnings': weeklyEarnings,
      'daily_earnings': dailyEarnings,
      'deliveries_today': deliveriesToday,
      'deliveries_this_week': deliveriesThisWeek,
      'deliveries_this_month': deliveriesThisMonth,
    };
  }
  
  // ==========================================================================
  // 🎯 GETTERS UTILITAIRES
  // ==========================================================================
  
  /// Pourcentage de réussite formaté
  String get successRateFormatted => '${(successRate * 100).toStringAsFixed(1)}%';
  
  /// Note moyenne formatée
  String get averageRatingFormatted => averageRating.toStringAsFixed(1);
  
  /// Temps de livraison moyen formaté
  String get averageDeliveryTimeFormatted {
    final hours = averageDeliveryTime.inHours;
    final minutes = averageDeliveryTime.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }
  
  /// Gains du jour formatés
  String get dailyEarningsFormatted => '${dailyEarnings.toStringAsFixed(0)} FCFA';
  
  /// Gains de la semaine formatés
  String get weeklyEarningsFormatted => '${weeklyEarnings.toStringAsFixed(0)} FCFA';
  
  /// Gains du mois formatés
  String get monthlyEarningsFormatted => '${monthlyEarnings.toStringAsFixed(0)} FCFA';
}

/// 👤 Profil du Livreur
class DeliveryProfile {
  
  // ==========================================================================
  // 🎯 STATUT ET DISPONIBILITÉ
  // ==========================================================================
  
  final bool isActive;
  final bool isAvailable;
  final DateTime? lastActiveAt;
  final String? currentZone;
  
  // ==========================================================================
  // 📍 LOCALISATION
  // ==========================================================================
  
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationUpdate;
  
  // ==========================================================================
  // 🚗 INFORMATIONS DE TRANSPORT
  // ==========================================================================
  
  final String? vehicleType;
  final String? vehiclePlate;
  final String? licenseNumber;
  
  // ==========================================================================
  // 📞 INFORMATIONS DE CONTACT
  // ==========================================================================
  
  final String? emergencyContact;
  final String? emergencyPhone;
  
  // ==========================================================================
  // 🏗️ CONSTRUCTEURS
  // ==========================================================================
  
  DeliveryProfile({
    required this.isActive,
    required this.isAvailable,
    this.lastActiveAt,
    this.currentZone,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdate,
    this.vehicleType,
    this.vehiclePlate,
    this.licenseNumber,
    this.emergencyContact,
    this.emergencyPhone,
  });
  
  /// Crée un profil depuis JSON
  factory DeliveryProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryProfile(
      isActive: json['is_active'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? false,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      currentZone: json['current_zone'] as String?,
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
      lastLocationUpdate: json['last_location_update'] != null
          ? DateTime.parse(json['last_location_update'] as String)
          : null,
      vehicleType: json['vehicle_type'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      licenseNumber: json['license_number'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      emergencyPhone: json['emergency_phone'] as String?,
    );
  }
  
  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive,
      'is_available': isAvailable,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'current_zone': currentZone,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'last_location_update': lastLocationUpdate?.toIso8601String(),
      'vehicle_type': vehicleType,
      'vehicle_plate': vehiclePlate,
      'license_number': licenseNumber,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
    };
  }
  
  // ==========================================================================
  // 🎯 GETTERS UTILITAIRES
  // ==========================================================================
  
  /// Vérifie si la position est disponible
  bool get hasLocation => currentLatitude != null && currentLongitude != null;
  
  /// Obtient la position actuelle
  (double, double)? get currentPosition {
    if (hasLocation) {
      return (currentLatitude!, currentLongitude!);
    }
    return null;
  }
  
  /// Vérifie si la localisation est récente (moins de 10 minutes)
  bool get isLocationRecent {
    if (lastLocationUpdate == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(lastLocationUpdate!);
    return difference.inMinutes < 10;
  }
  
  /// Statut formaté du livreur
  String get statusText {
    if (!isActive) return 'Inactif';
    if (!isAvailable) return 'Occupé';
    return 'Disponible';
  }
  
  /// Couleur du statut
  Color get statusColor {
    if (!isActive) return AppColors.gray500;
    if (!isAvailable) return AppColors.warning;
    return AppColors.success;
  }
  
  // ==========================================================================
  // 🔄 MÉTHODES DE COPIE
  // ==========================================================================
  
  /// Crée une copie avec des modifications
  DeliveryProfile copyWith({
    bool? isActive,
    bool? isAvailable,
    DateTime? lastActiveAt,
    String? currentZone,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationUpdate,
    String? vehicleType,
    String? vehiclePlate,
    String? licenseNumber,
    String? emergencyContact,
    String? emergencyPhone,
  }) {
    return DeliveryProfile(
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      currentZone: currentZone ?? this.currentZone,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    );
  }
}