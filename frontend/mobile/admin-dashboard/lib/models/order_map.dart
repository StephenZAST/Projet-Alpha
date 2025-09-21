import 'package:admin/models/order.dart';
import 'package:admin/models/enums.dart';

/// Modèle pour les coordonnées GPS
class OrderCoordinates {
  final double latitude;
  final double longitude;

  OrderCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory OrderCoordinates.fromJson(Map<String, dynamic> json) {
    return OrderCoordinates(
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => 'OrderCoordinates(lat: $latitude, lng: $longitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderCoordinates &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Modèle pour les adresses simplifiées
class OrderMapAddress {
  final String? id;
  final String? name;
  final String street;
  final String city;
  final String? postalCode;

  OrderMapAddress({
    this.id,
    this.name,
    required this.street,
    required this.city,
    this.postalCode,
  });

  factory OrderMapAddress.fromJson(Map<String, dynamic> json) {
    return OrderMapAddress(
      id: json['id'],
      name: json['name'],
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'street': street,
      'city': city,
      'postalCode': postalCode,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (name != null && name!.isNotEmpty) {
      parts.add(name!);
    }
    parts.add(street);
    parts.add(city);
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    return parts.join(', ');
  }
}

/// Modèle pour les clients simplifiés
class OrderMapClient {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;

  OrderMapClient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
  });

  factory OrderMapClient.fromJson(Map<String, dynamic> json) {
    return OrderMapClient(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}

/// Modèle pour les types de service simplifiés
class OrderMapServiceType {
  final String id;
  final String name;
  final String? description;

  OrderMapServiceType({
    required this.id,
    required this.name,
    this.description,
  });

  factory OrderMapServiceType.fromJson(Map<String, dynamic> json) {
    return OrderMapServiceType(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

/// Modèle pour les articles simplifiés
class OrderMapArticle {
  final String id;
  final String name;
  final String? description;

  OrderMapArticle({
    required this.id,
    required this.name,
    this.description,
  });

  factory OrderMapArticle.fromJson(Map<String, dynamic> json) {
    return OrderMapArticle(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

/// Modèle pour les items de commande simplifiés
class OrderMapItem {
  final String id;
  final int quantity;
  final double unitPrice;
  final bool isPremium;
  final double? weight;
  final OrderMapArticle article;

  OrderMapItem({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.isPremium,
    this.weight,
    required this.article,
  });

  factory OrderMapItem.fromJson(Map<String, dynamic> json) {
    return OrderMapItem(
      id: json['id'],
      quantity: _parseInt(json['quantity']),
      unitPrice: _parseDouble(json['unitPrice']),
      isPremium: json['isPremium'] ?? false,
      weight: json['weight'] != null ? _parseDouble(json['weight']) : null,
      article: OrderMapArticle.fromJson(json['article'] ?? {}),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'isPremium': isPremium,
      'weight': weight,
      'article': article.toJson(),
    };
  }

  double get totalPrice => unitPrice * quantity;
}

/// Modèle principal pour une commande sur la carte
class OrderMapData {
  final String id;
  final String status;
  final double? totalAmount;
  final DateTime createdAt;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final String paymentMethod;
  final String? affiliateCode;
  final bool isFlashOrder;
  final OrderCoordinates coordinates;
  final OrderMapAddress address;
  final OrderMapClient client;
  final OrderMapServiceType serviceType;
  final int itemsCount;
  final double totalWeight;
  final List<OrderMapItem> items;

  OrderMapData({
    required this.id,
    required this.status,
    this.totalAmount,
    required this.createdAt,
    this.collectionDate,
    this.deliveryDate,
    required this.paymentMethod,
    this.affiliateCode,
    required this.isFlashOrder,
    required this.coordinates,
    required this.address,
    required this.client,
    required this.serviceType,
    required this.itemsCount,
    required this.totalWeight,
    required this.items,
  });

  factory OrderMapData.fromJson(Map<String, dynamic> json) {
    return OrderMapData(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      totalAmount: json['totalAmount'] != null ? _parseDouble(json['totalAmount']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      collectionDate: json['collectionDate'] != null 
          ? DateTime.parse(json['collectionDate']) 
          : null,
      deliveryDate: json['deliveryDate'] != null 
          ? DateTime.parse(json['deliveryDate']) 
          : null,
      paymentMethod: json['paymentMethod'] ?? '',
      affiliateCode: json['affiliateCode'],
      isFlashOrder: json['isFlashOrder'] ?? false,
      coordinates: OrderCoordinates.fromJson(json['coordinates'] ?? {}),
      address: OrderMapAddress.fromJson(json['address'] ?? {}),
      client: OrderMapClient.fromJson(json['client'] ?? {}),
      serviceType: OrderMapServiceType.fromJson(json['serviceType'] ?? {}),
      itemsCount: _parseInt(json['itemsCount']),
      totalWeight: _parseDouble(json['totalWeight']),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderMapItem.fromJson(item))
          .toList() ?? [],
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'collectionDate': collectionDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'affiliateCode': affiliateCode,
      'isFlashOrder': isFlashOrder,
      'coordinates': coordinates.toJson(),
      'address': address.toJson(),
      'client': client.toJson(),
      'serviceType': serviceType.toJson(),
      'itemsCount': itemsCount,
      'totalWeight': totalWeight,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Convertit vers le modèle Order standard si nécessaire
  Order toOrder() {
    return Order(
      id: id,
      userId: client.id,
      addressId: address.id ?? '',
      serviceId: serviceType.id, // Utiliser serviceId au lieu de serviceTypeId
      status: status,
      totalAmount: totalAmount ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name.toUpperCase() == paymentMethod.toUpperCase(),
        orElse: () => PaymentMethod.CASH,
      ),
      paymentStatus: PaymentStatus.PENDING, // Ajouter le paymentStatus requis
      createdAt: createdAt,
      collectionDate: collectionDate,
      deliveryDate: deliveryDate,
      affiliateCode: affiliateCode,
      isFlashOrder: isFlashOrder,
      // Les autres champs peuvent être null ou avoir des valeurs par défaut
      isRecurring: false,
      recurrenceType: null,
      nextRecurrenceDate: null,
      updatedAt: createdAt,
      note: null,
    );
  }

  /// Retourne la couleur associée au statut de la commande
  String get statusColor {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return '#FFA726'; // Orange
      case 'COLLECTING':
        return '#42A5F5'; // Bleu
      case 'COLLECTED':
        return '#66BB6A'; // Vert clair
      case 'PROCESSING':
        return '#AB47BC'; // Violet
      case 'READY':
        return '#26C6DA'; // Cyan
      case 'DELIVERING':
        return '#FF7043'; // Orange foncé
      case 'DELIVERED':
        return '#4CAF50'; // Vert
      case 'CANCELLED':
        return '#F44336'; // Rouge
      default:
        return '#9E9E9E'; // Gris
    }
  }

  /// Retourne l'icône associée au statut de la commande
  String get statusIcon {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'pending';
      case 'COLLECTING':
        return 'local_shipping';
      case 'COLLECTED':
        return 'inventory';
      case 'PROCESSING':
        return 'settings';
      case 'READY':
        return 'check_circle';
      case 'DELIVERING':
        return 'delivery_dining';
      case 'DELIVERED':
        return 'done_all';
      case 'CANCELLED':
        return 'cancel';
      default:
        return 'help';
    }
  }
}

/// Modèle pour les statistiques de la carte
class OrderMapStats {
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byPaymentMethod;
  final int flashOrders;
  final double totalAmount;

  OrderMapStats({
    required this.total,
    required this.byStatus,
    required this.byPaymentMethod,
    required this.flashOrders,
    required this.totalAmount,
  });

  factory OrderMapStats.fromJson(Map<String, dynamic> json) {
    return OrderMapStats(
      total: json['total'] ?? 0,
      byStatus: Map<String, int>.from(json['byStatus'] ?? {}),
      byPaymentMethod: Map<String, int>.from(json['byPaymentMethod'] ?? {}),
      flashOrders: json['flashOrders'] ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'byStatus': byStatus,
      'byPaymentMethod': byPaymentMethod,
      'flashOrders': flashOrders,
      'totalAmount': totalAmount,
    };
  }
}

/// Modèle pour la réponse de l'API de carte
class OrderMapResponse {
  final List<OrderMapData> orders;
  final OrderMapStats stats;
  final int count;

  OrderMapResponse({
    required this.orders,
    required this.stats,
    required this.count,
  });

  factory OrderMapResponse.fromJson(Map<String, dynamic> json) {
    return OrderMapResponse(
      orders: (json['orders'] as List<dynamic>?)
          ?.map((order) => OrderMapData.fromJson(order))
          .toList() ?? [],
      stats: OrderMapStats.fromJson(json['stats'] ?? {}),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
      'stats': stats.toJson(),
      'count': count,
    };
  }
}

/// Modèle pour les limites de la carte
class MapBounds {
  final double north;
  final double south;
  final double east;
  final double west;

  MapBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  factory MapBounds.fromJson(Map<String, dynamic> json) {
    return MapBounds(
      north: (json['north'] as num).toDouble(),
      south: (json['south'] as num).toDouble(),
      east: (json['east'] as num).toDouble(),
      west: (json['west'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'north': north,
      'south': south,
      'east': east,
      'west': west,
    };
  }

  @override
  String toString() => 'MapBounds(N: $north, S: $south, E: $east, W: $west)';
}

/// Modèle pour les statistiques par ville
class CityStats {
  final String city;
  final int count;
  final double totalAmount;
  final OrderCoordinates coordinates;

  CityStats({
    required this.city,
    required this.count,
    required this.totalAmount,
    required this.coordinates,
  });

  factory CityStats.fromJson(Map<String, dynamic> json) {
    return CityStats(
      city: json['city'] ?? '',
      count: json['count'] ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      coordinates: OrderCoordinates.fromJson(json['coordinates'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'count': count,
      'totalAmount': totalAmount,
      'coordinates': coordinates.toJson(),
    };
  }
}

/// Modèle pour les statistiques géographiques
class OrderGeoStats {
  final List<CityStats> byCity;
  final int totalCities;
  final int totalOrders;
  final double totalAmount;

  OrderGeoStats({
    required this.byCity,
    required this.totalCities,
    required this.totalOrders,
    required this.totalAmount,
  });

  factory OrderGeoStats.fromJson(Map<String, dynamic> json) {
    return OrderGeoStats(
      byCity: (json['byCity'] as List<dynamic>?)
          ?.map((city) => CityStats.fromJson(city))
          .toList() ?? [],
      totalCities: json['totalCities'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'byCity': byCity.map((city) => city.toJson()).toList(),
      'totalCities': totalCities,
      'totalOrders': totalOrders,
      'totalAmount': totalAmount,
    };
  }
}