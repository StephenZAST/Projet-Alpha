import 'order.dart';

class OrdersPageData {
  final List<Order> orders;
  final int total;
  final int currentPage;
  final int limit;
  final int totalPages;

  OrdersPageData({
    required this.orders,
    required this.total,
    required this.currentPage,
    required this.limit,
    required this.totalPages,
  });

  factory OrdersPageData.fromJson(Map<String, dynamic> json) {
    try {
      // Vérifier et convertir la liste des commandes
      final List<Order> ordersList = [];
      if (json['data'] != null && json['data'] is List) {
        for (var orderJson in json['data']) {
          try {
            ordersList.add(Order.fromJson(orderJson));
          } catch (e) {
            print('Error parsing order: $e');
            print('Problematic order JSON: $orderJson');
            // Continue avec la prochaine commande
            continue;
          }
        }
      }

      // Récupérer et valider les données de pagination
      final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

      return OrdersPageData(
        orders: ordersList,
        total: _parseIntSafely(pagination['total']) ?? 0,
        currentPage: _parseIntSafely(pagination['page']) ?? 1,
        limit: _parseIntSafely(pagination['limit']) ?? 10,
        totalPages: _parseIntSafely(pagination['totalPages']) ?? 1,
      );
    } catch (e) {
      print('Error parsing OrdersPageData: $e');
      print('Problematic JSON: $json');
      return OrdersPageData.empty();
    }
  }

  factory OrdersPageData.empty() {
    return OrdersPageData(
      orders: [],
      total: 0,
      currentPage: 1,
      limit: 10,
      totalPages: 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': orders.map((e) => e.toJson()).toList(),
        'pagination': {
          'total': total,
          'page': currentPage,
          'limit': limit,
          'totalPages': totalPages,
        },
      };

  // Méthode utilitaire pour parser les entiers de manière sécurisée
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is double) {
      return value.toInt();
    }
    return null;
  }
}
