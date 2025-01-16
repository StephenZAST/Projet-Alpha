import 'package:flutter/material.dart';
import 'package:prima/animations/page_transition.dart';
import 'package:prima/pages/orders/orders_page.dart';
import 'package:prima/pages/orders/order_details_page.dart';
import 'package:prima/models/order.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/orders':
        return CustomPageTransition(
          child: const OrdersPage(),
        );

      case '/order-details':
        final order = settings.arguments as Order;
        return CustomPageTransition(
          child: OrderDetailsPage(order: order),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non définie: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
