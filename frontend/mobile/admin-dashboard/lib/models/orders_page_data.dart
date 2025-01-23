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
    final List<dynamic> ordersList = json['data'] as List;
    final pagination = json['pagination'] as Map<String, dynamic>;

    return OrdersPageData(
      orders: ordersList.map((e) => Order.fromJson(e)).toList(),
      total: pagination['total'] as int,
      currentPage: pagination['page'] as int,
      limit: pagination['limit'] as int,
      totalPages: pagination['totalPages'] as int,
    );
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
}
