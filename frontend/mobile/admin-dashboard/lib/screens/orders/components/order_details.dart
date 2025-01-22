import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';
import '../../../models/enums.dart';

class OrderDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final order = controller.selectedOrder.value;
      if (order == null) {
        return Center(child: CircularProgressIndicator());
      }

      final status = order.status.toOrderStatus();
      final currencyFormat = NumberFormat.currency(
        locale: 'fr_FR',
        symbol: 'fcfa',
        decimalDigits: 0,
      );

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order.id}',
                  style: AppTextStyles.h2.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            _buildStatusSection(status, order, controller, isDark),
            Divider(height: AppSpacing.xl),
            _buildCustomerSection(order, isDark),
            if (order.deliveryAddress != null) ...[
              Divider(height: AppSpacing.xl),
              _buildDeliverySection(order, isDark),
            ],
            Divider(height: AppSpacing.xl),
            _buildItemsSection(order, currencyFormat, isDark),
            if (order.notes?.isNotEmpty == true) ...[
              Divider(height: AppSpacing.xl),
              _buildNotesSection(order, isDark),
            ],
            Divider(height: AppSpacing.xl),
            _buildTotalSection(order, currencyFormat, isDark),
          ],
        ),
      );
    });
  }

  Widget _buildStatusSection(
    OrderStatus status,
    Order order,
    OrdersController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.1),
                borderRadius: AppRadius.radiusSM,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.icon, size: 16, color: status.color),
                  SizedBox(width: 4),
                  Text(
                    status.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: status.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSection(Order order, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName ?? 'N/A',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (order.customerEmail != null) ...[
                  SizedBox(height: 4),
                  Text(
                    order.customerEmail!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (order.customerPhone != null) ...[
                  SizedBox(height: 4),
                  Text(
                    order.customerPhone!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySection(Order order, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse de livraison',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
              order.deliveryAddress!,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(
      Order order, NumberFormat currencyFormat, bool isDark) {
    if (order.items == null || order.items!.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: order.items!.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final item = order.items![index];
              return ListTile(
                title: Text(
                  item.name,
                  style: AppTextStyles.bodyMedium,
                ),
                subtitle: Text(
                  'Quantité: ${item.quantity}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Text(
                  currencyFormat.format(item.total),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(Order order, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
              order.notes!,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection(
      Order order, NumberFormat currencyFormat, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              currencyFormat.format(order.totalAmount),
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: order.isPaid ? AppColors.success : AppColors.error,
                borderRadius: AppRadius.radiusSM,
              ),
              child: Text(
                order.isPaid ? 'Payé' : 'Non payé',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
