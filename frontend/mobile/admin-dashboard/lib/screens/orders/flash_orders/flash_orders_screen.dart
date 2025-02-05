import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';
import 'components/flash_order_card.dart';

class FlashOrdersScreen extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commandes Flash'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.loadDraftOrders(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.draftOrders.isEmpty) {
          return Center(
            child: Text('Aucune commande flash en attente'),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: controller.draftOrders.length,
          itemBuilder: (context, index) {
            final order = controller.draftOrders[index];
            return FlashOrderCard(
              order: order,
              onTap: () => Get.toNamed(
                '/orders/flash/${order.id}',
                arguments: order,
              ),
            );
          },
        );
      }),
    );
  }
}
