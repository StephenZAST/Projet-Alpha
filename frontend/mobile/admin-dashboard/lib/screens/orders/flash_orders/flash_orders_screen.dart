import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/flash_orders_controller.dart';
import '../../../constants.dart';
import 'components/flash_order_card.dart';

class FlashOrdersScreen extends StatelessWidget {
  final controller = Get.put(FlashOrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commandes Flash'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshDraftOrders,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          );
        }

        if (controller.draftOrders.isEmpty) {
          return Center(
            child: Text(
              'Aucune commande flash en attente',
              style: AppTextStyles.bodyMedium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDraftOrders,
          child: ListView.builder(
            padding: EdgeInsets.all(defaultPadding),
            itemCount: controller.draftOrders.length,
            itemBuilder: (context, index) {
              final order = controller.draftOrders[index];
              return FlashOrderCard(
                order: order,
                onTap: () => controller.openOrderDetails(order.id),
              );
            },
          ),
        );
      }),
    );
  }
}
