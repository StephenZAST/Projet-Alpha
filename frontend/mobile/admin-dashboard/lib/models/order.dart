import 'package:admin/models/user.dart';
import 'package:intl/intl.dart';

import 'article.dart';
import 'address.dart';
import 'service.dart';
import 'enums.dart';

class Order {
  static PaymentMethod safePaymentMethod(dynamic value) {
    if (value == null) return PaymentMethod.CASH;
    final methodStr = value.toString().toUpperCase();
    try {
      return PaymentMethod.values.firstWhere(
        (method) => method.name == methodStr,
        orElse: () => PaymentMethod.CASH,
      );
    } catch (e) {
      return PaymentMethod.CASH;
    }
  }

  static double safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static bool safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  final String id;
  final String userId;
  final String? serviceId;
  // Optionnel pour les commandes flash en DRAFT
  final String addressId;
  final String? affiliateCode;
  final String status;
  final bool isRecurring;
  final String? recurrenceType;
  final DateTime? nextRecurrenceDate;
  final double totalAmount;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem>? items;
  // final String? notes; // Supprimé, on utilise uniquement note
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final bool isFlashOrder; // Indicateur pour les commandes flash
  final String? note; // Ajouter le champ note
  final OrderMetadata? metadata; // Ajouter le champ metadata
  final bool isSubscriptionOrder;

  // Relations
  final Service? service;
  final Address? address;
  final User? user;

  // Getters pour la compatibilité
  String? get customerName =>
      user != null ? '${user!.firstName} ${user!.lastName}' : null;
  String? get customerEmail => user?.email;
  String? get customerPhone => user?.phone;
  String? get deliveryAddress => address?.fullAddress;
  bool get isPaid => paymentStatus == PaymentStatus.PAID;

  // Ajout des nouveaux getters
  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

  int get itemCount => items?.length ?? 0;

  String get formattedTotal =>
      NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA')
          .format(totalAmount);

  Order({
    required this.id,
    required this.userId,
    this.serviceId,
    // Maintenant optionnel
    required this.addressId,
    this.affiliateCode,
    required this.status,
    required this.isRecurring,
    this.recurrenceType,
    this.nextRecurrenceDate,
    required this.totalAmount,
    this.collectionDate,
    this.deliveryDate,
    required this.createdAt,
    this.updatedAt,
    this.items,
    // this.notes,
    required this.paymentStatus,
    required this.paymentMethod,
    this.service,
    this.address,
    this.user,
    this.isFlashOrder = false, // Par défaut, ce n'est pas une commande flash
    this.note,
    this.metadata,
    this.isSubscriptionOrder = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      print('[Order] Parsing order from JSON: $json');
      final data =
          json.containsKey('order') && json['order'] is Map<String, dynamic>
              ? json['order'] as Map<String, dynamic>
              : json;
      final id = data['id']?.toString() ?? data['orderId']?.toString() ?? '';
      if (id.isEmpty) throw 'Order ID is required';
      return Order(
        id: id,
        userId: data['userId']?.toString() ?? data['user_id']?.toString() ?? '',
        serviceId:
            data['serviceId']?.toString() ?? data['service_id']?.toString(),
        addressId: data['addressId']?.toString() ??
            data['address_id']?.toString() ??
            '',
        affiliateCode: data['affiliateCode']?.toString(),
        status: (data['status'] as String?)?.toUpperCase() ?? 'PENDING',
        isRecurring: safeBool(data['isRecurring']),
        recurrenceType: data['recurrenceType']?.toString(),
        totalAmount: safeDouble(data['totalAmount']),
        nextRecurrenceDate: _parseDateTime(data['nextRecurrenceDate']),
        collectionDate: _parseDateTime(data['collectionDate']),
        deliveryDate: _parseDateTime(data['deliveryDate']),
        createdAt: _parseDateTime(data['createdAt'] ?? data['created_at']) ??
            DateTime.now(),
        updatedAt: _parseDateTime(data['updatedAt'] ?? data['updated_at']),
        items: _parseOrderItems(data['items']),
        // notes: data['notes']?.toString(),
        paymentStatus: _parsePaymentStatus(data['paymentStatus']),
        paymentMethod: _parsePaymentMethod(data['paymentMethod']),
        service: data['service'] != null
            ? Service.fromJson(Map<String, dynamic>.from(data['service']))
            : null,
        address: data['address'] != null
            ? Address.fromJson(Map<String, dynamic>.from(data['address']))
            : null,
        user: data['user'] != null
            ? User.fromJson(Map<String, dynamic>.from(data['user']))
            : null,
        isFlashOrder: safeBool(data['isFlashOrder']),
        note: data['note']?.toString() ??
            (data['order_notes'] is List && data['order_notes'].isNotEmpty
                ? data['order_notes'][0]['note']?.toString()
                : null),
        metadata: data['metadata'] != null
            ? OrderMetadata.fromJson(data['metadata'])
            : null,
        isSubscriptionOrder: Order.safeBool(data['isSubscriptionOrder']),
      );
    } catch (e, stackTrace) {
      print('[Order] Error creating Order from JSON: $e');
      print('[Order] Stack trace: $stackTrace');
      print('[Order] Problematic JSON: $json');
      rethrow;
    }
  }

  // Méthodes helper pour le parsing sécurisé

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('[Order] Error parsing datetime: $value');
        return null;
      }
    }
    return null;
  }

  static List<OrderItem>? _parseOrderItems(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;

    final items = <OrderItem>[];
    for (var item in value) {
      try {
        items.add(OrderItem.fromJson(item));
      } catch (e) {
        print('Error parsing OrderItem: $e');
        continue;
      }
    }
    return items;
  }

  static PaymentStatus _parsePaymentStatus(dynamic value) {
    if (value == null) return PaymentStatus.PENDING;
    final status = value.toString().toUpperCase();
    try {
      return PaymentStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => PaymentStatus.PENDING,
      );
    } catch (e) {
      return PaymentStatus.PENDING;
    }
  }

  static PaymentMethod _parsePaymentMethod(dynamic value) {
    if (value == null) return PaymentMethod.CASH;
    final method = value.toString().toUpperCase();
    try {
      return PaymentMethod.values.firstWhere(
        (m) => m.name == method,
        orElse: () => PaymentMethod.CASH,
      );
    } catch (e) {
      return PaymentMethod.CASH;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'service_id': serviceId ?? '',
      'address_id': addressId,
      'affiliateCode': affiliateCode,
      'status': status,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType,
      'nextRecurrenceDate': nextRecurrenceDate?.toIso8601String(),
      'totalAmount': totalAmount,
      'collectionDate': collectionDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'items': items?.map((item) => item.toJson()).toList(),
      // 'notes': notes,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod.name,
      'service': service?.toJson(),
      'address': address?.toJson(),
      'isFlashOrder': isFlashOrder,
      'note': note,
      'metadata': metadata?.toJson(),
      'isSubscriptionOrder': isSubscriptionOrder,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? addressId,
    String? affiliateCode,
    String? status,
    bool? isRecurring,
    String? recurrenceType,
    DateTime? nextRecurrenceDate,
    double? totalAmount,
    DateTime? collectionDate,
    DateTime? deliveryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    // String? notes,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    Service? service,
    Address? address,
    User? user,
    bool? isFlashOrder,
    String? note,
    OrderMetadata? metadata,
    bool? isSubscriptionOrder,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      addressId: addressId ?? this.addressId,
      affiliateCode: affiliateCode ?? this.affiliateCode,
      status: status ?? this.status,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      nextRecurrenceDate: nextRecurrenceDate ?? this.nextRecurrenceDate,
      totalAmount: totalAmount ?? this.totalAmount,
      collectionDate: collectionDate ?? this.collectionDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      // notes: notes ?? this.notes,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      service: service ?? this.service,
      address: address ?? this.address,
      user: user ?? this.user,
      isFlashOrder: isFlashOrder ?? this.isFlashOrder,
      note: note ?? this.note,
      metadata: metadata ?? this.metadata,
      isSubscriptionOrder: isSubscriptionOrder ?? this.isSubscriptionOrder,
    );
  }
}

// Ajouter la classe FlashOrder
class FlashOrder extends Order {
  FlashOrder({
    required String id,
    required String userId,
    required String addressId,
    String? note,
    String status = 'DRAFT', // Par défaut DRAFT pour les commandes flash
  }) : super(
          id: id,
          userId: userId,
          addressId: addressId,
          status: status,
          isRecurring: false, // Toujours false pour les commandes flash
          totalAmount: 0, // Montant initial à 0
          createdAt: DateTime.now(),
          paymentStatus: PaymentStatus.PENDING,
          paymentMethod: PaymentMethod.CASH,
          note: note,
          isFlashOrder: true,
        );

  // Factory pour créer depuis JSON
  factory FlashOrder.fromJson(Map<String, dynamic> json) {
    try {
      print('===== PARSING FLASH ORDER =====');
      print('Raw JSON: $json');

      return FlashOrder(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        addressId: json['address_id']?.toString() ?? '',
        note: json['note']?.toString(),
        status: json['status']?.toString().toUpperCase() ?? 'DRAFT',
      );
    } catch (e) {
      print('Error parsing FlashOrder: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'address_id': addressId,
      'status': status,
      'isFlashOrder': true,
    };
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String articleId;
  final String serviceId;
  final int quantity;
  final double unitPrice;
  final Article? article;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPremium;
  final double? weight;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.articleId,
    required this.serviceId,
    required this.quantity,
    required this.unitPrice,
    this.article,
    required this.createdAt,
    this.updatedAt,
    this.isPremium = false,
    this.weight,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {
      return OrderItem(
        id: json['id']?.toString() ?? '',
        orderId: json['orderId']?.toString() ?? '',
        articleId: json['articleId']?.toString() ?? '',
        serviceId: json['serviceId']?.toString() ?? '',
        quantity:
            json['quantity'] != null ? (json['quantity'] as num).toInt() : 1,
        unitPrice: json['unitPrice'] != null
            ? (json['unitPrice'] as num).toDouble()
            : 0.0,
        article:
            json['article'] != null ? Article.fromJson(json['article']) : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : null,
        isPremium: json['isPremium'] == true || json['isPremium'] == 1,
        weight:
            json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      );
    } catch (e) {
      print('Error parsing OrderItem JSON: $e');
      print('Problematic JSON: $json');
      return OrderItem(
        id: '',
        orderId: '',
        articleId: '',
        serviceId: '',
        quantity: 1,
        unitPrice: 0,
        createdAt: DateTime.now(),
        isPremium: false,
        weight: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'articleId': articleId,
      'serviceId': serviceId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'article': article?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPremium': isPremium,
      if (weight != null) 'weight': weight,
    };
  }

  String get name => article?.name ?? 'Article inconnu';
  double get total => unitPrice * quantity;
}

// Classe spécifique pour les commandes flash
class FlashOrderItem {
  final String articleId;
  final int quantity;
  final double unitPrice;
  final bool isPremium;

  FlashOrderItem({
    required this.articleId,
    required this.quantity,
    required this.unitPrice,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() => {
        'articleId': articleId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'isPremium': isPremium,
      };
}

// Ajouter la classe OrderMetadata
class OrderMetadata {
  final String? note;
  final Map<String, dynamic>? additionalData;

  OrderMetadata({
    this.note,
    this.additionalData,
  });

  factory OrderMetadata.fromJson(Map<String, dynamic> json) {
    return OrderMetadata(
      note: json['note']?.toString(),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'additionalData': additionalData,
    };
  }
}
