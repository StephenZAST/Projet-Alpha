import 'dart:developer';
import 'package:prima/models/address.dart';
import 'package:prima/widgets/order_bottom_sheet.dart' as bottom_sheet;
import 'package:prima/models/service.dart' as service_model;
import 'package:prima/models/article.dart' as article_model;

class Order {
  final String id;
  final String serviceId;
  final String addressId;
  final String? affiliateCode;
  final String status;
  final bool isRecurring;
  final String recurrenceType;
  final DateTime? nextRecurrenceDate;
  final double totalAmount;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final service_model.Service? service;
  final Address? address;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.serviceId,
    required this.addressId,
    this.affiliateCode,
    required this.status,
    required this.isRecurring,
    required this.recurrenceType,
    this.nextRecurrenceDate,
    required this.totalAmount,
    this.collectionDate,
    this.deliveryDate,
    this.service,
    this.address,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      serviceId: json['service_id'],
      addressId: json['address_id'],
      affiliateCode: json['affiliateCode'],
      status: json['status'],
      isRecurring: json['isRecurring'] ?? false,
      recurrenceType: json['recurrenceType'] ?? 'NONE',
      nextRecurrenceDate: json['nextRecurrenceDate'] != null
          ? DateTime.parse(json['nextRecurrenceDate'])
          : null,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      collectionDate: json['collectionDate'] != null
          ? DateTime.parse(json['collectionDate'])
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      service: json['service'] != null
          ? service_model.Service.fromJson(json['service'])
          : null,
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'service': service?.toJson(),
      'address': address?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
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
  final article_model.Article? article;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.articleId,
    required this.serviceId,
    required this.quantity,
    required this.unitPrice,
    this.article,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      articleId: json['articleId'],
      serviceId: json['serviceId'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      article: json['article'] != null
          ? article_model.Article.fromJson(json['article'])
          : null,
    );
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
    };
  }
}
