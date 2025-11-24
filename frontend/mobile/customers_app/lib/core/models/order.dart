import 'package:flutter/material.dart';
import '../../constants.dart';
import 'order_pricing.dart';

/// 📦 Modèle Commande - Alpha Client App
///
/// Modèle conforme aux spécifications backend avec tous les champs requis

class Order {
  final String id;
  final String userId;
  final String? shortId; // Nullable car peut ne pas être généré immédiatement
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? processingAt;
  final DateTime? readyAt;
  final DateTime? deliveringAt;
  final DateTime? deliveredAt;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final OrderStatus status;
  final List<OrderItem> items;
  final double subtotal;
  final double discountAmount;
  final double deliveryFee;
  final double taxAmount;
  final double totalAmount;
  final OrderAddress? pickupAddress;
  final OrderAddress? deliveryAddress;
  final bool isPaid;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? affiliateCode;
  final bool isRecurring;
  final RecurrenceType? recurrenceType;
  final DateTime? nextRecurrenceDate;
  final String? serviceId;
  final String? serviceTypeId;
  final String? addressId;
  final String? note;

  // ✅ NOUVEAU - Données de pricing détaillées (prix manuel ajusté par admin)
  final double? manualPrice;
  final double? originalPrice;
  final double? discountPercentage;
  final DateTime? paidAt;
  final String? pricingReason;
  final double? displayPrice;  // 🎯 Prix à afficher (alterne entre manualPrice et totalAmount)

  Order({
    required this.id,
    required this.userId,
    this.shortId,
    required this.createdAt,
    this.updatedAt,
    this.confirmedAt,
    this.processingAt,
    this.readyAt,
    this.deliveringAt,
    this.deliveredAt,
    this.collectionDate,
    this.deliveryDate,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.deliveryFee,
    required this.taxAmount,
    required this.totalAmount,
    this.pickupAddress,
    this.deliveryAddress,
    required this.isPaid,
    required this.paymentMethod,
    required this.paymentStatus,
    this.affiliateCode,
    required this.isRecurring,
    this.recurrenceType,
    this.nextRecurrenceDate,
    this.serviceId,
    this.serviceTypeId,
    this.addressId,
    this.note,
    // ✅ NOUVEAU - Pricing
    this.manualPrice,
    this.originalPrice,
    this.discountPercentage,
    this.paidAt,
    this.pricingReason,
    this.displayPrice,
  });

  /// Returns a copy of this Order with optional updated fields.
  Order copyWith({
    String? id,
    String? userId,
    String? shortId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? processingAt,
    DateTime? readyAt,
    DateTime? deliveringAt,
    DateTime? deliveredAt,
    DateTime? collectionDate,
    DateTime? deliveryDate,
    OrderStatus? status,
    List<OrderItem>? items,
    double? subtotal,
    double? discountAmount,
    double? deliveryFee,
    double? taxAmount,
    double? totalAmount,
    OrderAddress? pickupAddress,
    OrderAddress? deliveryAddress,
    bool? isPaid,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? affiliateCode,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    DateTime? nextRecurrenceDate,
    String? serviceId,
    String? serviceTypeId,
    String? addressId,
    String? note,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shortId: shortId ?? this.shortId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      processingAt: processingAt ?? this.processingAt,
      readyAt: readyAt ?? this.readyAt,
      deliveringAt: deliveringAt ?? this.deliveringAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      collectionDate: collectionDate ?? this.collectionDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      isPaid: isPaid ?? this.isPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      affiliateCode: affiliateCode ?? this.affiliateCode,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      nextRecurrenceDate: nextRecurrenceDate ?? this.nextRecurrenceDate,
      serviceId: serviceId ?? this.serviceId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      addressId: addressId ?? this.addressId,
      note: note ?? this.note,
    );
  }

  String get statusText => status.displayName;
  Color get statusColor => status.color;

  /// Whether the order can still be cancelled by the customer.
  /// By default an order is cancellable when it is not delivered or cancelled.
  bool get canBeCancelled =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  /// Getter pour l'ID court (8 premiers caractères)
  String get shortOrderId =>
      id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  factory Order.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('order') && json['order'] is Map
        ? Map<String, dynamic>.from(json['order'])
        : Map<String, dynamic>.from(json);

    OrderStatus parseStatus(String? value) {
      if (value == null) return OrderStatus.pending;
      final upper = value.toString().toUpperCase();
      switch (upper) {
        case 'DRAFT':
          return OrderStatus.draft;
        case 'PENDING':
          return OrderStatus.pending;
        case 'COLLECTING':
          return OrderStatus.collecting;
        case 'COLLECTED':
          return OrderStatus.collected;
        case 'PROCESSING':
          return OrderStatus.processing;
        case 'READY':
          return OrderStatus.ready;
        case 'DELIVERING':
          return OrderStatus.delivering;
        case 'DELIVERED':
          return OrderStatus.delivered;
        case 'CANCELLED':
          return OrderStatus.cancelled;
        default:
          return OrderStatus.pending;
      }
    }

    PaymentMethod parsePaymentMethod(dynamic v) {
      if (v == null) return PaymentMethod.cash;
      final upper = v.toString().toUpperCase();
      switch (upper) {
        case 'CASH':
          return PaymentMethod.cash;
        case 'ORANGE_MONEY':
          return PaymentMethod.orangeMoney;
        case 'CARD':
          return PaymentMethod.card;
        case 'MOBILE_MONEY':
          return PaymentMethod.mobileMoney;
        case 'BANK_TRANSFER':
          return PaymentMethod.bankTransfer;
        default:
          return PaymentMethod.cash;
      }
    }

    PaymentStatus parsePaymentStatus(dynamic v) {
      if (v == null) return PaymentStatus.pending;
      final upper = v.toString().toUpperCase();
      switch (upper) {
        case 'PENDING':
          return PaymentStatus.pending;
        case 'PAID':
          return PaymentStatus.paid;
        case 'FAILED':
          return PaymentStatus.failed;
        case 'REFUNDED':
          return PaymentStatus.refunded;
        default:
          return PaymentStatus.pending;
      }
    }

    RecurrenceType? parseRecurrenceType(dynamic v) {
      if (v == null) return null;
      final upper = v.toString().toUpperCase();
      switch (upper) {
        case 'NONE':
          return RecurrenceType.none;
        case 'WEEKLY':
          return RecurrenceType.weekly;
        case 'BIWEEKLY':
          return RecurrenceType.biweekly;
        case 'MONTHLY':
          return RecurrenceType.monthly;
        default:
          return null;
      }
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) {
        try {
          return double.parse(v);
        } catch (_) {
          return 0.0;
        }
      }
      return 0.0;
    }

    List<OrderItem> parseItems(dynamic v) {
      if (v == null) return [];
      if (v is List) {
        return v.map((e) {
          if (e is Map<String, dynamic>) return OrderItem.fromJson(e);
          if (e is Map) return OrderItem.fromJson(Map<String, dynamic>.from(e));
          return OrderItem.empty();
        }).toList();
      }
      return [];
    }

    // 🔍 DEBUG: Log des données brutes avant parsing
    print('[Order.fromJson] 📥 Raw data keys: ${data.keys.toList()}');
    print('[Order.fromJson] 💰 Raw manualPrice: ${data['manualPrice']}');
    print('[Order.fromJson] 💰 Raw originalPrice: ${data['originalPrice']}');
    print('[Order.fromJson] 💰 Raw discountPercentage: ${data['discountPercentage']}');
    print('[Order.fromJson] 💳 Raw isPaid: ${data['isPaid']}');
    print('[Order.fromJson] 📅 Raw paidAt: ${data['paidAt']}');

    final order = Order(
      id: data['id']?.toString() ?? '',
      userId: data['userId']?.toString() ?? data['user_id']?.toString() ?? '',
      shortId: data['shortId']?.toString() ?? data['short_id']?.toString(),
      createdAt:
          parseDate(data['createdAt'] ?? data['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(data['updatedAt'] ?? data['updated_at']),
      confirmedAt: parseDate(data['confirmedAt'] ?? data['confirmed_at']),
      processingAt: parseDate(data['processingAt'] ?? data['processing_at']),
      readyAt: parseDate(data['readyAt'] ?? data['ready_at']),
      deliveringAt: parseDate(data['deliveringAt'] ?? data['delivering_at']),
      deliveredAt: parseDate(data['deliveredAt'] ?? data['delivered_at']),
      collectionDate:
          parseDate(data['collectionDate'] ?? data['collection_date']),
      deliveryDate: parseDate(data['deliveryDate'] ?? data['delivery_date']),
      status: parseStatus(data['status']?.toString()),
      items: parseItems(data['items']),
      subtotal: parseDouble(data['subtotal'] ?? data['sub_total']),
      discountAmount: parseDouble(data['discountAmount'] ?? data['discount']),
      deliveryFee: parseDouble(data['deliveryFee'] ?? data['delivery_fee']),
      taxAmount: parseDouble(data['taxAmount'] ?? data['tax']),
      totalAmount: parseDouble(data['totalAmount'] ?? data['total']),
      pickupAddress: data['pickupAddress'] != null
          ? OrderAddress.fromJson(
              Map<String, dynamic>.from(data['pickupAddress']))
          : null,
      deliveryAddress: data['deliveryAddress'] != null
          ? OrderAddress.fromJson(
              Map<String, dynamic>.from(data['deliveryAddress']))
          : null,
      isPaid: data['isPaid'] ??
          data['paid'] ??
          (parsePaymentStatus(
                  data['paymentStatus'] ?? data['payment_status']) ==
              PaymentStatus.paid),
      paymentMethod:
          parsePaymentMethod(data['paymentMethod'] ?? data['payment_method']),
      paymentStatus:
          parsePaymentStatus(data['paymentStatus'] ?? data['payment_status']),
      affiliateCode: data['affiliateCode']?.toString() ??
          data['affiliate_code']?.toString(),
      isRecurring: data['isRecurring'] ?? data['is_recurring'] ?? false,
      recurrenceType: parseRecurrenceType(
          data['recurrenceType'] ?? data['recurrence_type']),
      nextRecurrenceDate:
          parseDate(data['nextRecurrenceDate'] ?? data['next_recurrence_date']),
      serviceId:
          data['serviceId']?.toString() ?? data['service_id']?.toString(),
      serviceTypeId: data['serviceTypeId']?.toString() ??
          data['service_type_id']?.toString(),
      addressId:
          data['addressId']?.toString() ?? data['address_id']?.toString(),
      note: data['note']?.toString(),
      // ✅ NOUVEAU - Parsing des champs de pricing (support snake_case et camelCase)
      manualPrice: data['manualPrice'] != null ? parseDouble(data['manualPrice']) : (data['manual_price'] != null ? parseDouble(data['manual_price']) : null),
      originalPrice: data['originalPrice'] != null ? parseDouble(data['originalPrice']) : (data['original_price'] != null ? parseDouble(data['original_price']) : null),
      discountPercentage: data['discountPercentage'] != null ? parseDouble(data['discountPercentage']) : (data['discount_percentage'] != null ? parseDouble(data['discount_percentage']) : null),
      paidAt: parseDate(data['paidAt'] ?? data['paid_at']),
      pricingReason: data['pricingReason'] ?? data['reason'],
      displayPrice: data['displayPrice'] != null ? parseDouble(data['displayPrice']) : null,
    );

    // 🔍 DEBUG: Log des données parsées APRÈS création
    print('[Order.fromJson] ✅ Order parsed successfully:');
    print('[Order.fromJson]   - ID: ${order.id}');
    print('[Order.fromJson]   - manualPrice: ${order.manualPrice}');
    print('[Order.fromJson]   - originalPrice: ${order.originalPrice}');
    print('[Order.fromJson]   - discountPercentage: ${order.discountPercentage}');
    print('[Order.fromJson]   - isPaid: ${order.isPaid}');
    print('[Order.fromJson]   - paidAt: ${order.paidAt}');
    print('[Order.fromJson]   - displayPrice: ${data['displayPrice']}');

    return order;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shortId': shortId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'processingAt': processingAt?.toIso8601String(),
      'readyAt': readyAt?.toIso8601String(),
      'deliveringAt': deliveringAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'collectionDate': collectionDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'status': status.name.toUpperCase(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'pickupAddress': pickupAddress?.toJson(),
      'deliveryAddress': deliveryAddress?.toJson(),
      'isPaid': isPaid,
      'paymentMethod': paymentMethod.name.toUpperCase(),
      'paymentStatus': paymentStatus.name.toUpperCase(),
      'affiliateCode': affiliateCode,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType?.name.toUpperCase(),
      'nextRecurrenceDate': nextRecurrenceDate?.toIso8601String(),
      'serviceId': serviceId,
      'serviceTypeId': serviceTypeId,
      'addressId': addressId,
      'note': note,
    };
  }

  @override
  String toString() =>
      'Order(id: $id, status: ${status.name}, total: $totalAmount)';
}

/// 🛍️ Article de Commande
class OrderItem {
  final String id;
  final String orderId;
  final String articleId;
  final String serviceId;
  final String articleName;
  final String serviceName;
  final String serviceTypeName;
  final int quantity;
  final double unitPrice;
  final bool isPremium;
  final double? weight;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.articleId,
    required this.serviceId,
    required this.articleName,
    required this.serviceName,
    required this.serviceTypeName,
    required this.quantity,
    required this.unitPrice,
    required this.isPremium,
    this.weight,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) {
        try {
          return double.parse(v);
        } catch (_) {
          return 0.0;
        }
      }
      return 0.0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) {
        try {
          return int.parse(v);
        } catch (_) {
          return 0;
        }
      }
      return 0;
    }

    // 🔍 DEBUG: Log du JSON brut
    print('[OrderItem.fromJson] 📦 Raw JSON: ${json.toString()}');
    
    // Extraire les informations de l'article imbriqué
    final article = json['article'] as Map<String, dynamic>?;
    final articleName = article?['name']?.toString() ?? 
                       json['articleName']?.toString() ?? 
                       json['name']?.toString() ?? 
                       'Article inconnu';
    
    print('[OrderItem.fromJson] 📋 Article name: $articleName');
    
    // ✅ Extraire les informations du service imbriqué
    final service = json['service'] as Map<String, dynamic>?;
    print('[OrderItem.fromJson] 🔍 Service object: ${service?.toString() ?? "NULL"}');
    
    final serviceName = service?['name']?.toString() ?? 
                       json['serviceName']?.toString() ?? 
                       json['service_name']?.toString() ?? 
                       'Service';
    
    print('[OrderItem.fromJson] 📋 Service name: $serviceName');
    
    // ✅ Extraire les informations du service type imbriqué
    final serviceType = service?['serviceType'] as Map<String, dynamic>?;
    print('[OrderItem.fromJson] 🔍 ServiceType object: ${serviceType?.toString() ?? "NULL"}');
    
    final serviceTypeName = serviceType?['name']?.toString() ?? 
                           json['serviceTypeName']?.toString() ?? 
                           json['service_type_name']?.toString() ?? 
                           '';
    
    print('[OrderItem.fromJson] 📋 ServiceType name: $serviceTypeName');
    
    // Déterminer si c'est premium en fonction du prix
    final unitPrice = parseDouble(json['unitPrice'] ?? json['price']);
    final basePrice = parseDouble(article?['basePrice']);
    final premiumPrice = parseDouble(article?['premiumPrice']);
    final isPremium = json['isPremium'] ?? 
                     json['is_premium'] ?? 
                     (unitPrice > 0 && premiumPrice > 0 && unitPrice >= premiumPrice);

    return OrderItem(
      id: json['id']?.toString() ?? '',
      orderId:
          json['orderId']?.toString() ?? json['order_id']?.toString() ?? '',
      articleId:
          json['articleId']?.toString() ?? json['article_id']?.toString() ?? article?['id']?.toString() ?? '',
      serviceId:
          json['serviceId']?.toString() ?? json['service_id']?.toString() ?? service?['id']?.toString() ?? '',
      articleName: articleName,
      serviceName: serviceName,  // ✅ Utilise le nom extrait
      serviceTypeName: serviceTypeName,  // �� Utilise le nom extrait
      quantity: parseInt(json['quantity'] ?? json['qty']),
      unitPrice: unitPrice,
      isPremium: isPremium,
      weight: parseDouble(json['weight']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'articleId': articleId,
      'serviceId': serviceId,
      'articleName': articleName,
      'serviceName': serviceName,
      'serviceTypeName': serviceTypeName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'isPremium': isPremium,
      'weight': weight,
    };
  }

  factory OrderItem.empty() => OrderItem(
        id: '',
        orderId: '',
        articleId: '',
        serviceId: '',
        articleName: '',
        serviceName: '',
        serviceTypeName: '',
        quantity: 0,
        unitPrice: 0.0,
        isPremium: false,
      );

  @override
  String toString() =>
      'OrderItem(id: $id, article: $articleName, qty: $quantity)';
}

/// 📍 Adresse de Commande
class OrderAddress {
  final String id;
  final String userId;
  final String name;
  final String street;
  final String city;
  final String postalCode;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final bool isDefault;
  final String? phone;

  OrderAddress({
    required this.id,
    required this.userId,
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    this.gpsLatitude,
    this.gpsLongitude,
    required this.isDefault,
    this.phone,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ??
          json['postal_code']?.toString() ??
          '',
      gpsLatitude:
          json['gpsLatitude']?.toDouble() ?? json['gps_latitude']?.toDouble(),
      gpsLongitude:
          json['gpsLongitude']?.toDouble() ?? json['gps_longitude']?.toDouble(),
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'gpsLatitude': gpsLatitude,
      'gpsLongitude': gpsLongitude,
      'isDefault': isDefault,
      'phone': phone,
    };
  }

  String get fullAddress => '$street, $city $postalCode';

  @override
  String toString() => 'OrderAddress(id: $id, name: $name, city: $city)';
}

/// 💳 Méthodes de Paiement (conforme au backend)
enum PaymentMethod {
  cash,
  orangeMoney,
  card,
  mobileMoney,
  bankTransfer,
}

/// 📊 Statuts de Paiement (conforme au backend)
enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

/// 🔄 Types de Récurrence (conforme au backend)
enum RecurrenceType {
  none,
  weekly,
  biweekly,
  monthly,
}

/// 📦 Statuts de Commande (conforme au backend)
enum OrderStatus {
  draft,
  pending,
  collecting,
  collected,
  processing,
  ready,
  delivering,
  delivered,
  cancelled,
}

// Extensions pour les enums
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Espèces';
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.card:
        return 'Carte bancaire';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.bankTransfer:
        return 'Virement bancaire';
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.cash:
        return AppColors.success;
      case PaymentMethod.orangeMoney:
        return AppColors.accent;
      case PaymentMethod.card:
        return AppColors.primary;
      case PaymentMethod.mobileMoney:
        return AppColors.secondary;
      case PaymentMethod.bankTransfer:
        return AppColors.info;
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.paid:
        return 'Payé';
      case PaymentStatus.failed:
        return 'Échoué';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.info;
    }
  }
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.draft:
        return 'Brouillon';
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.collecting:
        return 'Collecte en cours';
      case OrderStatus.collected:
        return 'Collectée';
      case OrderStatus.processing:
        return 'En traitement';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.delivering:
        return 'En livraison';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.draft:
        return AppColors.lightTextTertiary;
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.collecting:
        return AppColors.info;
      case OrderStatus.collected:
        return AppColors.primary;
      case OrderStatus.processing:
        return AppColors.accent;
      case OrderStatus.ready:
        return AppColors.secondary;
      case OrderStatus.delivering:
        return AppColors.info;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'Aucune';
      case RecurrenceType.weekly:
        return 'Hebdomadaire';
      case RecurrenceType.biweekly:
        return 'Bi-hebdomadaire';
      case RecurrenceType.monthly:
        return 'Mensuelle';
    }
  }
}

// Suppression de l'ancien enum
// enum OrderPaymentMethod { cash, card, mobileMoney, bankTransfer }
