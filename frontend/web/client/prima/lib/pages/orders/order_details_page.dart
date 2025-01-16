import 'package:flutter/material.dart';
import 'package:prima/models/order.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/order/order_timeline.dart';
import 'package:prima/widgets/order/order_items_section.dart';
import 'package:prima/widgets/order/order_delivery_section.dart';
import 'package:prima/widgets/order/order_payment_section.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Commande #${order.id.substring(0, 8)}',
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OrderTimeline(order: order),
            const SizedBox(height: 8),
            OrderItemsSection(order: order),
            const SizedBox(height: 8),
            OrderDeliverySection(order: order),
            const SizedBox(height: 8),
            OrderPaymentSection(order: order),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
