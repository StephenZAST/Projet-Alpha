import 'package:flutter/material.dart';
import '../constants.dart';
import 'user.dart';
import 'order.dart';

// Modèle pour un livreur
class DeliveryUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DeliveryProfile? deliveryProfile;

  const DeliveryUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryProfile,
  });

  factory DeliveryUser.fromJson(Map<String, dynamic> json) {
    return DeliveryUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      phone: json['phone'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] as String? ?? 'CLIENT'),
        orElse: () => UserRole.CLIENT,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String? ??
          json['created_at'] as String? ??
          DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ??
          json['updated_at'] as String? ??
          DateTime.now().toIso8601String()),
      deliveryProfile: json['deliveryProfile'] != null
          ? DeliveryProfile.fromJson(json['deliveryProfile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deliveryProfile': deliveryProfile?.toJson(),
    };
  }

  String get fullName => '$firstName $lastName';
  bool get isActive => deliveryProfile?.isActive ?? false;
  String get statusLabel => isActive ? 'Actif' : 'Inactif';
  Color get statusColor => isActive ? AppColors.success : AppColors.error;
}

// Profil spécifique au livreur (extension future)
class DeliveryProfile {
  final String id;
  final String userId;
  final bool isActive;
  final String? zone;
  final String? vehicleType;
  final String? licenseNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryProfile({
    required this.id,
    required this.userId,
    required this.isActive,
    this.zone,
    this.vehicleType,
    this.licenseNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryProfile(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      zone: json['zone'] as String?,
      vehicleType: json['vehicleType'] as String? ?? json['vehicle_type'] as String?,
      licenseNumber: json['licenseNumber'] as String? ?? json['license_number'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ??
          json['created_at'] as String? ??
          DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ??
          json['updated_at'] as String? ??
          DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'isActive': isActive,
      'zone': zone,
      'vehicleType': vehicleType,
      'licenseNumber': licenseNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Statistiques de livraison pour un livreur
class DeliveryStats {
  final int totalDeliveries;
  final int completedDeliveries;
  final int cancelledDeliveries;
  final int pendingDeliveries;
  final double completionRate;
  final double averageDeliveryTime; // en minutes
  final int deliveriesToday;
  final int deliveriesThisWeek;
  final int deliveriesThisMonth;

  const DeliveryStats({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.cancelledDeliveries,
    required this.pendingDeliveries,
    required this.completionRate,
    required this.averageDeliveryTime,
    required this.deliveriesToday,
    required this.deliveriesThisWeek,
    required this.deliveriesThisMonth,
  });

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      totalDeliveries: json['totalDeliveries'] as int? ?? json['total_deliveries'] as int? ?? 0,
      completedDeliveries: json['completedDeliveries'] as int? ?? json['completed_deliveries'] as int? ?? 0,
      cancelledDeliveries: json['cancelledDeliveries'] as int? ?? json['cancelled_deliveries'] as int? ?? 0,
      pendingDeliveries: json['pendingDeliveries'] as int? ?? json['pending_deliveries'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 
                     (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      averageDeliveryTime: (json['averageDeliveryTime'] as num?)?.toDouble() ?? 
                          (json['average_delivery_time'] as num?)?.toDouble() ?? 0.0,
      deliveriesToday: json['deliveriesToday'] as int? ?? json['deliveries_today'] as int? ?? 0,
      deliveriesThisWeek: json['deliveriesThisWeek'] as int? ?? json['deliveries_this_week'] as int? ?? 0,
      deliveriesThisMonth: json['deliveriesThisMonth'] as int? ?? json['deliveries_this_month'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDeliveries': totalDeliveries,
      'completedDeliveries': completedDeliveries,
      'cancelledDeliveries': cancelledDeliveries,
      'pendingDeliveries': pendingDeliveries,
      'completionRate': completionRate,
      'averageDeliveryTime': averageDeliveryTime,
      'deliveriesToday': deliveriesToday,
      'deliveriesThisWeek': deliveriesThisWeek,
      'deliveriesThisMonth': deliveriesThisMonth,
    };
  }

  String get formattedCompletionRate => '${completionRate.toStringAsFixed(1)}%';
  String get formattedAverageTime => '${averageDeliveryTime.toStringAsFixed(0)} min';
}

// Commande du point de vue livraison
class DeliveryOrder {
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final Address? address;
  final List<OrderItem>? items;
  final String? note;

  const DeliveryOrder({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    this.collectionDate,
    this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.address,
    this.items,
    this.note,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'PENDING'),
        orElse: () => OrderStatus.PENDING,
      ),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 
                   (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      collectionDate: json['collectionDate'] != null || json['collection_date'] != null
          ? DateTime.parse((json['collectionDate'] as String?) ??
              (json['collection_date'] as String?) ??
              DateTime.now().toIso8601String())
          : null,
      deliveryDate: json['deliveryDate'] != null || json['delivery_date'] != null
          ? DateTime.parse((json['deliveryDate'] as String?) ??
              (json['delivery_date'] as String?) ??
              DateTime.now().toIso8601String())
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String? ??
          json['created_at'] as String? ??
          DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ??
          json['updated_at'] as String? ??
          DateTime.now().toIso8601String()),
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      items: json['items'] != null
          ? (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status.name,
      'totalAmount': totalAmount,
      'collectionDate': collectionDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'address': address?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
      'note': note,
    };
  }

  String get formattedAmount => '${totalAmount.toStringAsFixed(0)} FCFA';
  String get customerName => user?.fullName ?? 'Client inconnu';
  String get customerPhone => user?.phone ?? 'N/A';
  String get deliveryAddress => address?.fullAddress ?? 'Adresse non définie';
  
  bool get canCollect => status == OrderStatus.PENDING;
  bool get canProcess => status == OrderStatus.COLLECTED;
  bool get canDeliver => status == OrderStatus.READY;
  bool get isCompleted => status == OrderStatus.DELIVERED;
  bool get isCancelled => status == OrderStatus.CANCELLED;
}

// Statistiques globales de livraison
class GlobalDeliveryStats {
  final int totalDeliverers;
  final int activeDeliverers;
  final int totalOrdersToday;
  final int completedOrdersToday;
  final int pendingOrders;
  final double averageDeliveryTime;
  final Map<String, int> ordersByStatus;
  final Map<String, int> deliverersByZone;

  const GlobalDeliveryStats({
    required this.totalDeliverers,
    required this.activeDeliverers,
    required this.totalOrdersToday,
    required this.completedOrdersToday,
    required this.pendingOrders,
    required this.averageDeliveryTime,
    required this.ordersByStatus,
    required this.deliverersByZone,
  });

  factory GlobalDeliveryStats.fromJson(Map<String, dynamic> json) {
    return GlobalDeliveryStats(
      totalDeliverers: json['totalDeliverers'] as int? ?? json['total_deliverers'] as int? ?? 0,
      activeDeliverers: json['activeDeliverers'] as int? ?? json['active_deliverers'] as int? ?? 0,
      totalOrdersToday: json['totalOrdersToday'] as int? ?? json['total_orders_today'] as int? ?? 0,
      completedOrdersToday: json['completedOrdersToday'] as int? ?? json['completed_orders_today'] as int? ?? 0,
      pendingOrders: json['pendingOrders'] as int? ?? json['pending_orders'] as int? ?? 0,
      averageDeliveryTime: (json['averageDeliveryTime'] as num?)?.toDouble() ?? 
                          (json['average_delivery_time'] as num?)?.toDouble() ?? 0.0,
      ordersByStatus: Map<String, int>.from(json['ordersByStatus'] as Map? ??
          json['orders_by_status'] as Map? ??
          {}),
      deliverersByZone: Map<String, int>.from(json['deliverersByZone'] as Map? ??
          json['deliverers_by_zone'] as Map? ??
          {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDeliverers': totalDeliverers,
      'activeDeliverers': activeDeliverers,
      'totalOrdersToday': totalOrdersToday,
      'completedOrdersToday': completedOrdersToday,
      'pendingOrders': pendingOrders,
      'averageDeliveryTime': averageDeliveryTime,
      'ordersByStatus': ordersByStatus,
      'deliverersByZone': deliverersByZone,
    };
  }

  double get completionRate {
    if (totalOrdersToday == 0) return 0.0;
    return (completedOrdersToday / totalOrdersToday) * 100;
  }

  String get formattedCompletionRate => '${completionRate.toStringAsFixed(1)}%';
  String get formattedAverageTime => '${averageDeliveryTime.toStringAsFixed(0)} min';
}

// Extensions pour les couleurs et icônes des statuts
extension OrderStatusExtension on OrderStatus {
  Color get deliveryColor {
    switch (this) {
      case OrderStatus.PENDING:
        return AppColors.warning;
      case OrderStatus.COLLECTING:
        return AppColors.info;
      case OrderStatus.COLLECTED:
        return AppColors.primary;
      case OrderStatus.PROCESSING:
        return AppColors.violet;
      case OrderStatus.READY:
        return AppColors.success;
      case OrderStatus.DELIVERING:
        return AppColors.orange;
      case OrderStatus.DELIVERED:
        return AppColors.success;
      case OrderStatus.CANCELLED:
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  IconData get deliveryIcon {
    switch (this) {
      case OrderStatus.PENDING:
        return Icons.hourglass_empty;
      case OrderStatus.COLLECTING:
        return Icons.directions_walk;
      case OrderStatus.COLLECTED:
        return Icons.inventory;
      case OrderStatus.PROCESSING:
        return Icons.settings;
      case OrderStatus.READY:
        return Icons.check_circle;
      case OrderStatus.DELIVERING:
        return Icons.local_shipping;
      case OrderStatus.DELIVERED:
        return Icons.done_all;
      case OrderStatus.CANCELLED:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String get deliveryLabel {
    switch (this) {
      case OrderStatus.PENDING:
        return 'En attente';
      case OrderStatus.COLLECTING:
        return 'Collecte en cours';
      case OrderStatus.COLLECTED:
        return 'Collecté';
      case OrderStatus.PROCESSING:
        return 'En traitement';
      case OrderStatus.READY:
        return 'Prêt';
      case OrderStatus.DELIVERING:
        return 'En livraison';
      case OrderStatus.DELIVERED:
        return 'Livré';
      case OrderStatus.CANCELLED:
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }
}