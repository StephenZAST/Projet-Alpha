import 'package:admin/models/user.dart';

import 'article.dart';
import 'address.dart';
import 'service.dart';
import 'enums.dart';

class Order {
  final String id;
  final String userId;
  final String serviceId;
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
  final String? notes;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;

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
    required this.serviceId,
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
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      return Order(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        serviceId: json['service_id']?.toString() ?? '',
        addressId: json['address_id']?.toString() ?? '',
        affiliateCode: json['affiliateCode']?.toString(),
        status: json['status']?.toString() ?? 'PENDING',
        isRecurring: json['isRecurring'] ?? false,
        recurrenceType: json['recurrenceType']?.toString(),
        nextRecurrenceDate: json['nextRecurrenceDate'] != null
            ? DateTime.parse(json['nextRecurrenceDate'].toString())
            : null,
        totalAmount: json['totalAmount'] != null
            ? (json['totalAmount'] as num).toDouble()
            : 0.0,
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
            : null,
        notes: json['notes']?.toString(),
        paymentStatus:
            (json['paymentStatus']?.toString() ?? 'PENDING').toPaymentStatus(),
        paymentMethod:
            (json['paymentMethod']?.toString() ?? 'CASH').toPaymentMethod(),
        service:
            json['service'] != null ? Service.fromJson(json['service']) : null,
        address:
            json['address'] != null ? Address.fromJson(json['address']) : null,
        user: json['user'] != null ? User.fromJson(json['user']) : null,
      );
    } catch (e) {
      print('Error parsing Order JSON: $e');
      print('Problematic JSON: $json');
      return Order(
        id: json['id']?.toString() ?? 'error',
        userId: '',
        serviceId: '',
        addressId: '',
        status: 'ERROR',
        isRecurring: false,
        totalAmount: 0,
        createdAt: DateTime.now(),
        paymentStatus: PaymentStatus.PENDING,
        paymentMethod: PaymentMethod.CASH,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'service_id': serviceId,
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
