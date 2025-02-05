import 'package:admin/models/user.dart';

import 'article.dart';
import 'address.dart';
import 'service.dart';
import 'enums.dart';

class Order {
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
  final String? notes; // Notes spécifiques aux commandes flash
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final bool isFlashOrder; // Indicateur pour les commandes flash

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
    this.notes,
    required this.paymentStatus,
    required this.paymentMethod,
    this.service,
    this.address,
    this.user,
    this.isFlashOrder = false, // Par défaut, ce n'est pas une commande flash
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      print('[Order] Parsing JSON data');
      print('Raw data: $json');

      // Helper functions pour la conversion sécurisée
      String safeString(dynamic value, {String defaultValue = ''}) {
        if (value == null) return defaultValue;
        return value.toString();
      }

      double safeDouble(dynamic value, {double defaultValue = 0.0}) {
        if (value == null) return defaultValue;
        if (value is num) return value.toDouble();
        try {
          return double.parse(value.toString());
        } catch (_) {
          return defaultValue;
        }
      }

      PaymentMethod safePaymentMethod(dynamic value) {
        if (value == null) return PaymentMethod.CASH;
        try {
          return value.toString().toPaymentMethod();
        } catch (_) {
          return PaymentMethod.CASH;
        }
      }

      // Pour les commandes flash
      final isFlash = json['status']?.toString().toUpperCase() == 'DRAFT';
      if (isFlash) {
        return FlashOrder.fromJson(json);
      }

      return Order(
        id: safeString(json['id']),
        userId: safeString(json['userId']),
        serviceId: safeString(json['serviceId'] ?? json['service_id']),
        addressId: safeString(json['addressId'] ?? json['address_id']),
        affiliateCode: json['affiliateCode']?.toString(),
        status:
            safeString(json['status'], defaultValue: 'PENDING').toUpperCase(),
        isRecurring: json['isRecurring'] ?? false,
        recurrenceType: json['recurrenceType']?.toString(),
        nextRecurrenceDate: json['nextRecurrenceDate'] != null
            ? DateTime.parse(json['nextRecurrenceDate'].toString())
            : null,
        totalAmount: safeDouble(json['totalAmount']),
        collectionDate: json['collectionDate'] != null
            ? DateTime.parse(json['collectionDate'].toString())
            : null,
        deliveryDate: json['deliveryDate'] != null
            ? DateTime.parse(json['deliveryDate'].toString())
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : null,
        items: json['items'] != null
            ? (json['items'] as List)
                .map((item) => OrderItem.fromJson(item))
                .toList()
            : [],
        notes: json['notes']?.toString(),
        paymentStatus:
            (json['paymentStatus']?.toString() ?? 'PENDING').toPaymentStatus(),
        paymentMethod: safePaymentMethod(json['paymentMethod']),
        service:
            json['service'] != null ? Service.fromJson(json['service']) : null,
        address:
            json['address'] != null ? Address.fromJson(json['address']) : null,
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        isFlashOrder: isFlash,
      );
    } catch (e) {
      print('Error parsing order: $e');
      print('Problematic JSON: $json');
      rethrow;
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
      'notes': notes,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod.name,
      'service': service?.toJson(),
      'address': address?.toJson(),
      'isFlashOrder': isFlashOrder,
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
    String? notes,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    Service? service,
    Address? address,
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
      notes: notes ?? this.notes,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      service: service ?? this.service,
      address: address ?? this.address,
    );
  }
}

// Ajouter la classe FlashOrder
class FlashOrder extends Order {
  FlashOrder({
    required String id,
    required String userId,
    required String addressId,
    String? notes,
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
          notes: notes,
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
        notes: json['notes']?.toString(),
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
      'notes': notes,
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
