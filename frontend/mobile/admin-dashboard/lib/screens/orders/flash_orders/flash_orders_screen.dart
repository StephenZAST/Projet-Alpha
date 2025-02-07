import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/flash_orders_controller.dart';
import 'components/flash_order_card.dart';

class FlashOrdersScreen extends GetView<FlashOrdersController> {
  const FlashOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes Flash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshOrders,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshOrders,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (controller.draftOrders.isEmpty) {
          return const Center(
            child: Text('Aucune commande flash en attente'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          child: ListView.builder(
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
          ),
        );
      }),
    );
  }
}
