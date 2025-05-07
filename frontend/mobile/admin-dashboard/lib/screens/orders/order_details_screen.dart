import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/orders_controller.dart';
import '../../constants.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final OrdersController controller = Get.find<OrdersController>();

  OrderDetailsScreen({required this.orderId}) {
    controller.fetchOrderDetails(orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la commande'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.fetchOrderDetails(orderId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final order = controller.selectedOrder.value;
        if (order == null) {
          return Center(
            child: Text(
              'Commande non trouvée',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(order),
              SizedBox(height: AppSpacing.md),
              _buildCustomerInfo(order),
              SizedBox(height: AppSpacing.md),
              _buildOrderItems(order),
              SizedBox(height: AppSpacing.md),
              _buildTotalSection(order),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderHeader(dynamic order) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commande #${order.id}', style: AppTextStyles.h4),
            SizedBox(height: AppSpacing.sm),
            Text('Date: ${order.createdAt}', style: AppTextStyles.bodyMedium),
            Text('Statut: ${order.status}', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(dynamic order) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations Client', style: AppTextStyles.h4),
            SizedBox(height: AppSpacing.sm),
            Text('Nom: ${order.customerName}', style: AppTextStyles.bodyMedium),
            Text('Téléphone: ${order.customerPhone}',
                style: AppTextStyles.bodyMedium),
            Text('Adresse: ${order.customerAddress}',
                style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(dynamic order) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Articles', style: AppTextStyles.h4),
            SizedBox(height: AppSpacing.sm),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Quantité: ${item.quantity}'),
                  trailing: Text('${item.price} DH'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(dynamic order) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total', style: AppTextStyles.h4),
            SizedBox(height: AppSpacing.sm),
            Text('Sous-total: ${order.subtotal} DH',
                style: AppTextStyles.bodyMedium),
            Text('TVA: ${order.tax} DH', style: AppTextStyles.bodyMedium),
            Text('Total: ${order.total} DH', style: AppTextStyles.h4),
          ],
        ),
      ),
    );
  }
}
