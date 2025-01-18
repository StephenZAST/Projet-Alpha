import 'package:prima/models/article.dart';
import 'package:prima/models/service.dart';

class Order {
  final String id;
  final Service service;
  final String serviceId;
  final String addressId;
  final DateTime collectionDate;
  final DateTime deliveryDate;
  final DateTime createdAt;
  final double totalAmount;
  final String status;
  final bool isRecurring;
  final String recurrenceType;
  final List<OrderItem>? items; // Changed from List<MapEntry<Article, int>>
  final List<MapEntry<Article, int>> articles;

  Order({
    required this.id,
    required this.service,
    required this.serviceId,
    required this.addressId,
    required this.collectionDate,
    required this.deliveryDate,
    required this.createdAt,
    required this.totalAmount,
    required this.status,
    required this.isRecurring,
    required this.recurrenceType,
    this.items, // Added items parameter
    required this.articles,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      service: Service.fromJson(json['service']),
      serviceId: json['service_id'],
      addressId: json['address_id'],
      collectionDate: DateTime.parse(json['collectionDate']),
      deliveryDate: DateTime.parse(json['deliveryDate']),
      createdAt: DateTime.parse(json['createdAt']),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'],
      isRecurring: json['isRecurring'] ?? false,
      recurrenceType: json['recurrenceType'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList(),
      articles: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service.toJson(),
      'serviceId': serviceId,
      'addressId': addressId,
      'collectionDate': collectionDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType,
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
  final Article? article;

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
      article:
          json['article'] != null ? Article.fromJson(json['article']) : null,
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
