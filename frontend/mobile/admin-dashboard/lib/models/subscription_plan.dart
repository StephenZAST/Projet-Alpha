import 'package:flutter/foundation.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int durationDays;
  final int maxOrdersPerMonth;
  final double? maxWeightPerOrder;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationDays,
    required this.maxOrdersPerMonth,
    this.maxWeightPerOrder,
    required this.isPremium,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationDays: json['duration_days'] ?? 0,
      maxOrdersPerMonth: json['max_orders_per_month'] ?? 0,
      maxWeightPerOrder: (json['max_weight_per_order'] as num?)?.toDouble(),
      isPremium: json['is_premium'] ?? false,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'duration_days': durationDays,
        'max_orders_per_month': maxOrdersPerMonth,
        'max_weight_per_order': maxWeightPerOrder,
        'is_premium': isPremium,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
