import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';
import 'components/flash_order_card.dart';

class FlashOrdersScreen extends StatefulWidget {
  @override
  State<FlashOrdersScreen> createState() => _FlashOrdersScreenState();
}

class _FlashOrdersScreenState extends State<FlashOrdersScreen> {
  final controller = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    // Rafraîchir les données au montage
    controller.loadDraftOrders();
  }

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
      body: RefreshIndicator(
        onRefresh: controller.refreshDraftOrders,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.draftOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 48),
                  SizedBox(height: 16),
                  Text('Aucune commande flash en attente'),
                  SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: controller.loadDraftOrders,
                    icon: Icon(Icons.refresh),
                    label: Text('Actualiser'),
                  ),
                ],
              ),
            );
          }

          // Affichage des commandes flash
          return ListView.builder(
            itemCount: controller.draftOrders.length,
            itemBuilder: (context, index) {
              final order = controller.draftOrders[index];
              return FlashOrderCard(
                order: order,
                onTap: () {
                  // Naviguer vers l'écran de mise à jour
                  Get.toNamed('/orders/flash/${order.id}/update');
                  // Ou utiliser cette version si vous préférez
                  // controller.initFlashOrderUpdate(order.id);
                  // Get.toNamed('/orders/flash/update');
                },
              );
            },
          );
        }),
      ),
    );
  }
}
