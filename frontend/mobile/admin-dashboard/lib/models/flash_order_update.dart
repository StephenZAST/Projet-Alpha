import 'package:admin/models/article.dart';
import 'package:admin/models/service.dart';

class FlashOrderUpdate {
  final String serviceId;
  final List<FlashOrderItem> items;
  final DateTime? collectionDate;
  final DateTime? deliveryDate;

  FlashOrderUpdate({
    required this.serviceId,
    required this.items,
    this.collectionDate,
    this.deliveryDate,
  });

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'items': items.map((item) => item.toJson()).toList(),
        'collectionDate': collectionDate?.toIso8601String(),
        'deliveryDate': deliveryDate?.toIso8601String(),
      };
}

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
