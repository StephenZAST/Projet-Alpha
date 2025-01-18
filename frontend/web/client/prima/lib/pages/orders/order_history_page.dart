import 'package:flutter/material.dart';
import 'package:prima/widgets/order/order_card.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/order_provider.dart';
import 'package:prima/widgets/refresh/custom_refresh_indicator.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des commandes'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          final completedOrders = provider.filteredOrders
              .where((order) =>
                  order.status == 'DELIVERED' || order.status == 'CANCELLED')
              .toList();

          return CustomRefreshIndicator(
            onRefresh: () => provider.refreshOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedOrders.length,
              itemBuilder: (context, index) {
                return OrderCard(
                  order: completedOrders[index],
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/order-details',
                    arguments: completedOrders[index],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
