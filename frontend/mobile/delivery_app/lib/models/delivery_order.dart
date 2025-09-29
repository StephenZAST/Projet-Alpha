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
    try {
      // Gère les différents formats de date (peut être null)
      DateTime? parseDate(dynamic dateValue) {
        if (dateValue == null) return null;
        if (dateValue is String) {
          try {
            return DateTime.parse(dateValue);
          } catch (e) {
            debugPrint('❌ Erreur parsing date: $dateValue');
            return null;
          }
        }
        return null;
      }

      // Parse les dates obligatoires avec fallback
      DateTime parseRequiredDate(dynamic dateValue, String fieldName) {
        final parsed = parseDate(dateValue);
        if (parsed != null) return parsed;
        
        debugPrint('⚠️ Date manquante pour $fieldName, utilisation de DateTime.now()');
        return DateTime.now();
      }

      // Crée un client par défaut si manquant
      DeliveryCustomer createDefaultCustomer() {
        return DeliveryCustomer(
          id: 'unknown',
          firstName: 'Client',
          lastName: 'Inconnu',
        );
      }

      // Crée une adresse par défaut si manquante
      DeliveryAddress createDefaultAddress() {
        return DeliveryAddress(
          id: 'unknown',
          street: 'Adresse inconnue',
          city: 'Ville inconnue',
        );
      }

      // Fonction pour parser les montants (String, num ou null)
      double? parseAmount(dynamic value) {
        if (value == null) return null;
        if (value is num) return value.toDouble();
        if (value is String) {
          if (value.isEmpty) return null;
          final parsed = double.tryParse(value);
          return parsed;
        }
        return null;
      }

      // Parse le statut avec gestion d'erreur
      OrderStatus parseStatus(dynamic statusValue) {
        if (statusValue == null) return OrderStatus.PENDING;
        
        final statusString = statusValue.toString().toUpperCase();
        try {
          return OrderStatus.values.firstWhere(
            (e) => e.name.toUpperCase() == statusString,
          );
        } catch (e) {
          debugPrint('⚠️ Statut inconnu: $statusString, utilisation de PENDING');
          return OrderStatus.PENDING;
        }
      }

      return DeliveryOrder(
        id: json['id']?.toString() ?? 'unknown',
        status: parseStatus(json['status']),
        createdAt: parseRequiredDate(json['createdAt'], 'createdAt'),
        updatedAt: parseRequiredDate(json['updatedAt'], 'updatedAt'),
        totalAmount: parseAmount(json['totalAmount']),
        collectionDate: parseDate(json['collectionDate']),
        deliveryDate: parseDate(json['deliveryDate']),
        paymentMethod: json['paymentMethod']?.toString() ?? 'CASH',
        customer: json['user'] != null 
            ? DeliveryCustomer.fromJson(json['user'] as Map<String, dynamic>)
            : createDefaultCustomer(),
        address: json['address'] != null
            ? DeliveryAddress.fromJson(json['address'] as Map<String, dynamic>)
            : createDefaultAddress(),
        serviceTypeName: json['service_types']?['name']?.toString() ?? 
                        json['serviceType']?['name']?.toString() ?? 
                        'Service Standard',
        items: (json['order_items'] as List<dynamic>?)
            ?.map((item) {
              try {
                return DeliveryOrderItem.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                debugPrint('❌ Erreur parsing order_item: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<DeliveryOrderItem>()
            .toList() ?? [],
        isFlashOrder: json['order_metadata']?['is_flash_order'] as bool? ?? false,
        notes: (json['order_notes'] as List<dynamic>?)
            ?.map((note) {
              try {
                return DeliveryOrderNote.fromJson(note as Map<String, dynamic>);
              } catch (e) {
                debugPrint('❌ Erreur parsing order_note: $e');
                return null;
              }
            })
            .where((note) => note != null)
            .cast<DeliveryOrderNote>()
            .toList() ?? [],
        metadata: json['order_metadata']?['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      debugPrint('❌ Erreur parsing DeliveryOrder: $e');
      debugPrint('JSON reçu: $json');
      rethrow;
    }
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
      id: json['id']?.toString() ?? 'unknown',
      firstName: json['first_name']?.toString() ?? 'Client',
      lastName: json['last_name']?.toString() ?? 'Inconnu',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
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
    // Fonction pour parser les coordonnées GPS (String ou num)
    double? parseCoordinate(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    return DeliveryAddress(
      id: json['id']?.toString() ?? 'unknown',
      street: json['street']?.toString() ?? 'Adresse inconnue',
      city: json['city']?.toString() ?? 'Ville inconnue',
      postalCode: json['postal_code']?.toString(),
      name: json['name']?.toString(),
      latitude: parseCoordinate(json['gps_latitude']),
      longitude: parseCoordinate(json['gps_longitude']),
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
    // Fonction pour parser les prix (String ou num)
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? 0.0;
      }
      return 0.0;
    }

    // Fonction pour parser les poids (String ou num)
    double? parseWeight(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    // Fonction pour parser les quantités (int ou String)
    int parseQuantity(dynamic value) {
      if (value == null) return 1;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? 1;
      }
      return 1;
    }

    return DeliveryOrderItem(
      id: json['id']?.toString() ?? 'unknown',
      articleName: json['article']?['name']?.toString() ?? 'Article inconnu',
      categoryName: json['article']?['article_categories']?['name']?.toString(),
      quantity: parseQuantity(json['quantity']),
      unitPrice: parsePrice(json['unitPrice']),
      isPremium: json['isPremium'] as bool? ?? false,
      weight: parseWeight(json['weight']),
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
    // Parse la date avec gestion d'erreur
    DateTime parseCreatedAt(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          debugPrint('❌ Erreur parsing created_at pour note: $dateValue');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return DeliveryOrderNote(
      id: json['id']?.toString() ?? 'unknown',
      note: json['note']?.toString() ?? '',
      createdAt: parseCreatedAt(json['created_at']),
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
  final DeliveryPagination? pagination;
  
  DeliveryOrdersResponse({
    required this.orders,
    this.pagination,
  });
  
  factory DeliveryOrdersResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Gère les réponses avec ou sans pagination
      final List<dynamic> ordersData = json['data'] as List<dynamic>;
      
      // Parse chaque commande individuellement avec gestion d'erreur
      final orders = <DeliveryOrder>[];
      for (final orderJson in ordersData) {
        try {
          final order = DeliveryOrder.fromJson(orderJson as Map<String, dynamic>);
          orders.add(order);
        } catch (e) {
          debugPrint('❌ Erreur parsing commande individuelle: $e');
          debugPrint('JSON commande problématique: $orderJson');
          // Continue avec les autres commandes au lieu de tout faire planter
          continue;
        }
      }
      
      // Pagination optionnelle
      DeliveryPagination? pagination;
      if (json.containsKey('pagination') && json['pagination'] != null) {
        pagination = DeliveryPagination.fromJson(json['pagination'] as Map<String, dynamic>);
      } else {
        // Crée une pagination par défaut si pas fournie
        pagination = DeliveryPagination(
          page: 1,
          limit: orders.length,
          total: orders.length,
          totalPages: 1,
        );
      }
      
      return DeliveryOrdersResponse(
        orders: orders,
        pagination: pagination,
      );
    } catch (e) {
      debugPrint('❌ Erreur parsing DeliveryOrdersResponse: $e');
      debugPrint('JSON reçu: $json');
      rethrow;
    }
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
    // Fonction pour parser les entiers avec gestion d'erreur
    int parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? defaultValue;
      }
      return defaultValue;
    }

    return DeliveryPagination(
      page: parseInt(json['page'], 1),
      limit: parseInt(json['limit'], 20),
      total: parseInt(json['total'], 0),
      totalPages: parseInt(json['totalPages'], 1),
    );
  }
  
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}