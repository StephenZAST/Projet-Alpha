import 'package:flutter/material.dart';
import '../constants.dart';

/// 📦 Modèle Commande Livreur - Alpha Delivery App
/// 
/// Modèle optimisé mobile pour les commandes de livraison
/// avec toutes les informations nécessaires aux livreurs.
class DeliveryOrder {
  
  // ==========================================================================
  // 📦 PROPRIÉTÉS DE BASE
  // ==========================================================================
  
  final String id;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? totalAmount;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final String paymentMethod;
  
  // ==========================================================================
  // 👤 INFORMATIONS CLIENT
  // ==========================================================================
  
  final DeliveryCustomer customer;
  final DeliveryAddress address;
  
  // ==========================================================================
  // 🛍️ ARTICLES ET SERVICES
  // ==========================================================================
  
  final String serviceTypeName;
  final List<DeliveryOrderItem> items;
  final bool isFlashOrder;
  
  // ==========================================================================
  // 📝 NOTES ET MÉTADONNÉES
  // ==========================================================================
  
  final List<DeliveryOrderNote> notes;
  final Map<String, dynamic>? metadata;
  
  // ==========================================================================
  // 🏗️ CONSTRUCTEURS
  // ==========================================================================
  
  DeliveryOrder({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.totalAmount,
    this.collectionDate,
    this.deliveryDate,
    required this.paymentMethod,
    required this.customer,
    required this.address,
    required this.serviceTypeName,
    required this.items,
    this.isFlashOrder = false,
    this.notes = const [],
    this.metadata,
  });
  
  /// Crée une commande depuis JSON
  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as String,
      status: OrderStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['status'] as String).toUpperCase(),
        orElse: () => OrderStatus.PENDING,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      collectionDate: json['collectionDate'] != null 
          ? DateTime.parse(json['collectionDate'] as String)
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String? ?? 'CASH',
      customer: DeliveryCustomer.fromJson(json['user'] as Map<String, dynamic>),
      address: DeliveryAddress.fromJson(json['address'] as Map<String, dynamic>),
      serviceTypeName: json['service_types']?['name'] as String? ?? 'Service Standard',
      items: (json['order_items'] as List<dynamic>?)
          ?.map((item) => DeliveryOrderItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      isFlashOrder: json['order_metadata']?['is_flash_order'] as bool? ?? false,
      notes: (json['order_notes'] as List<dynamic>?)
          ?.map((note) => DeliveryOrderNote.fromJson(note as Map<String, dynamic>))
          .toList() ?? [],
      metadata: json['order_metadata']?['metadata'] as Map<String, dynamic>?,
    );
  }
  
  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalAmount': totalAmount,
      'collectionDate': collectionDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'customer': customer.toJson(),
      'address': address.toJson(),
      'serviceTypeName': serviceTypeName,
      'items': items.map((item) => item.toJson()).toList(),
      'isFlashOrder': isFlashOrder,
      'notes': notes.map((note) => note.toJson()).toList(),
      'metadata': metadata,
    };
  }
  
  // ==========================================================================
  // 🎯 GETTERS UTILITAIRES MOBILE
  // ==========================================================================
  
  /// ID court pour l'affichage mobile
  String get shortId => id.length > 8 ? id.substring(0, 8) : id;
  
  /// Nom complet du client
  String get customerName => customer.fullName;
  
  /// Adresse courte pour l'affichage mobile
  String get shortAddress => '${address.city}, ${address.street}';
  
  /// Adresse complète formatée
  String get fullAddress => address.fullAddress;
  
  /// Couleur du statut
  Color get statusColor => status.color;
  
  /// Icône du statut
  IconData get statusIcon => status.icon;
  
  /// Nom d'affichage du statut
  String get statusDisplayName => status.displayName;
  
  /// Montant formaté
  String get formattedAmount {
    if (totalAmount == null) return 'N/A';
    return '${totalAmount!.toStringAsFixed(0)} FCFA';
  }
  
  /// Nombre total d'articles
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  /// Résumé des articles pour l'affichage mobile
  String get itemsSummary {
    if (items.isEmpty) return 'Aucun article';
    if (items.length == 1) {
      return '${items.first.quantity}x ${items.first.articleName}';
    }
    return '$totalItems articles (${items.length} types)';
  }
  
  /// Vérifie si la commande a des coordonnées GPS
  bool get hasGpsCoordinates => address.hasCoordinates;
  
  /// Coordonnées GPS pour la navigation
  (double, double)? get gpsCoordinates => address.coordinates;
  
  /// Vérifie si la commande est urgente
  bool get isUrgent => isFlashOrder || _isUrgentByTime();
  
  /// Vérifie si la commande est en retard
  bool get isOverdue => _isOverdue();
  
  /// Temps écoulé depuis la création
  Duration get timeSinceCreation => DateTime.now().difference(createdAt);
  
  /// Temps formaté depuis la création
  String get timeSinceCreationFormatted => _formatDuration(timeSinceCreation);
  
  /// Prochaine action recommandée pour le livreur
  String get nextAction {
    switch (status) {
      case OrderStatus.PENDING:
        return 'Accepter la commande';
      case OrderStatus.COLLECTING:
        return 'Collecter chez le client';
      case OrderStatus.COLLECTED:
        return 'Attendre le traitement';
      case OrderStatus.PROCESSING:
        return 'Attendre la fin du traitement';
      case OrderStatus.READY:
        return 'Livrer au client';
      case OrderStatus.DELIVERING:
        return 'Confirmer la livraison';
      case OrderStatus.DELIVERED:
        return 'Commande terminée';
      case OrderStatus.CANCELLED:
        return 'Commande annulée';
      default:
        return 'Voir les détails';
    }
  }
  
  /// Vérifie si le livreur peut modifier le statut
  bool get canUpdateStatus {
    return [
      OrderStatus.PENDING,
      OrderStatus.COLLECTING,
      OrderStatus.READY,
      OrderStatus.DELIVERING,
    ].contains(status);
  }
  
  /// Statuts possibles pour la prochaine étape
  List<OrderStatus> get possibleNextStatuses {
    switch (status) {
      case OrderStatus.PENDING:
        return [OrderStatus.COLLECTING];
      case OrderStatus.COLLECTING:
        return [OrderStatus.COLLECTED];
      case OrderStatus.READY:
        return [OrderStatus.DELIVERING];
      case OrderStatus.DELIVERING:
        return [OrderStatus.DELIVERED];
      default:
        return [];
    }
  }
  
  // ==========================================================================
  // 🔧 MÉTHODES PRIVÉES
  // ==========================================================================
  
  /// Vérifie si la commande est urgente par le temps
  bool _isUrgentByTime() {
    if (collectionDate != null) {
      final timeUntilCollection = collectionDate!.difference(DateTime.now());
      return timeUntilCollection.inHours < 2;
    }
    if (deliveryDate != null) {
      final timeUntilDelivery = deliveryDate!.difference(DateTime.now());
      return timeUntilDelivery.inHours < 2;
    }
    return false;
  }
  
  /// Vérifie si la commande est en retard
  bool _isOverdue() {
    final now = DateTime.now();
    
    if (status == OrderStatus.COLLECTING && collectionDate != null) {
      return now.isAfter(collectionDate!);
    }
    
    if ([OrderStatus.READY, OrderStatus.DELIVERING].contains(status) && deliveryDate != null) {
      return now.isAfter(deliveryDate!);
    }
    
    return false;
  }
  
  /// Formate une durée pour l'affichage
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}j';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inMinutes}min';
    }
  }
  
  // ==========================================================================
  // 🔄 MÉTHODES DE COPIE
  // ==========================================================================
  
  /// Crée une copie avec des modifications
  DeliveryOrder copyWith({
    String? id,
    OrderStatus? status,
    DateTime? updatedAt,
    double? totalAmount,
    DateTime? collectionDate,
    DateTime? deliveryDate,
    List<DeliveryOrderNote>? notes,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalAmount: totalAmount ?? this.totalAmount,
      collectionDate: collectionDate ?? this.collectionDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      paymentMethod: paymentMethod,
      customer: customer,
      address: address,
      serviceTypeName: serviceTypeName,
      items: items,
      isFlashOrder: isFlashOrder,
      notes: notes ?? this.notes,
      metadata: metadata,
    );
  }
  
  @override
  String toString() {
    return 'DeliveryOrder(id: $shortId, status: $status, customer: $customerName)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryOrder && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// 👤 Client de la commande
class DeliveryCustomer {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  
  DeliveryCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
  });
  
  factory DeliveryCustomer.fromJson(Map<String, dynamic> json) {
    return DeliveryCustomer(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
    };
  }
  
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
}

/// 📍 Adresse de livraison
class DeliveryAddress {
  final String id;
  final String street;
  final String city;
  final String? postalCode;
  final String? name;
  final double? latitude;
  final double? longitude;
  
  DeliveryAddress({
    required this.id,
    required this.street,
    required this.city,
    this.postalCode,
    this.name,
    this.latitude,
    this.longitude,
  });
  
  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String?,
      name: json['name'] as String?,
      latitude: (json['gps_latitude'] as num?)?.toDouble(),
      longitude: (json['gps_longitude'] as num?)?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'postal_code': postalCode,
      'name': name,
      'gps_latitude': latitude,
      'gps_longitude': longitude,
    };
  }
  
  String get fullAddress {
    final parts = <String>[];
    if (name != null && name!.isNotEmpty) parts.add(name!);
    parts.add(street);
    parts.add(city);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }
  
  bool get hasCoordinates => latitude != null && longitude != null;
  
  (double, double)? get coordinates {
    if (hasCoordinates) {
      return (latitude!, longitude!);
    }
    return null;
  }
}

/// 🛍️ Article de la commande
class DeliveryOrderItem {
  final String id;
  final String articleName;
  final String? categoryName;
  final int quantity;
  final double unitPrice;
  final bool isPremium;
  final double? weight;
  
  DeliveryOrderItem({
    required this.id,
    required this.articleName,
    this.categoryName,
    required this.quantity,
    required this.unitPrice,
    this.isPremium = false,
    this.weight,
  });
  
  factory DeliveryOrderItem.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderItem(
      id: json['id'] as String,
      articleName: json['article']['name'] as String,
      categoryName: json['article']['article_categories']?['name'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      isPremium: json['isPremium'] as bool? ?? false,
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleName': articleName,
      'categoryName': categoryName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'isPremium': isPremium,
      'weight': weight,
    };
  }
  
  double get totalPrice => unitPrice * quantity;
  String get formattedUnitPrice => '${unitPrice.toStringAsFixed(0)} FCFA';
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} FCFA';
}

/// 📝 Note de commande
class DeliveryOrderNote {
  final String id;
  final String note;
  final DateTime createdAt;
  
  DeliveryOrderNote({
    required this.id,
    required this.note,
    required this.createdAt,
  });
  
  factory DeliveryOrderNote.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderNote(
      id: json['id'] as String,
      note: json['note'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// 📊 Réponse paginée de commandes
class DeliveryOrdersResponse {
  final List<DeliveryOrder> orders;
  final DeliveryPagination pagination;
  
  DeliveryOrdersResponse({
    required this.orders,
    required this.pagination,
  });
  
  factory DeliveryOrdersResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryOrdersResponse(
      orders: (json['data'] as List<dynamic>)
          .map((orderJson) => DeliveryOrder.fromJson(orderJson as Map<String, dynamic>))
          .toList(),
      pagination: DeliveryPagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

/// 📄 Pagination
class DeliveryPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  
  DeliveryPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
  
  factory DeliveryPagination.fromJson(Map<String, dynamic> json) {
    return DeliveryPagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
  
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}