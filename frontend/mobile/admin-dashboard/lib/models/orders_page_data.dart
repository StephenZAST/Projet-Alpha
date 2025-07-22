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
      final List<Order> orders = [];
      if (json['data'] != null) {
        for (var item in json['data']) {
          try {
            orders.add(Order.fromJson(item));
          } catch (e) {
            print('Error parsing order in page: $e');
          }
        }
      }

      // Supporte les deux formats : pagination racine ou objet pagination
      final pagination = json['pagination'] ?? {};
      final total = json['total'] ?? pagination['total'] ?? 0;
      final currentPage = json['page'] ?? pagination['page'] ?? 1;
      final limit = json['limit'] ?? pagination['limit'] ?? 50;
      final totalPages = json['totalPages'] ?? pagination['totalPages'] ?? 1;

      return OrdersPageData(
        orders: orders,
        total: total,
        currentPage: currentPage,
        limit: limit,
        totalPages: totalPages,
      );
    } catch (e) {
      print('Error creating OrdersPageData: $e');
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
