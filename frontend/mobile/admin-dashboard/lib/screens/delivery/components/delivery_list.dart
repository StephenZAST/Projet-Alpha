import 'package:admin/screens/delivery/components/glass_list_item.dart';
import 'package:admin/screens/delivery/components/update_status_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../constants.dart';
import '../../../models/delivery.dart';
import '../../../models/enums.dart';
import '../../../widgets/shared/glass_container.dart';

class DeliveryList extends StatelessWidget {
  const DeliveryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoadingOrders.value) {
        return GlassContainer(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        );
      }

      if (controller.hasError.value) {
        return GlassContainer(
          child: Center(
            child: Text(
              controller.errorMessage.value,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        );
      }

      if (controller.activeDeliveries.isEmpty) {
        return GlassContainer(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 48,
                  color: AppColors.gray400,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Aucune livraison trouvée',
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: controller.activeDeliveries
            .map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildOrderItem(context, order, isDark),
                ))
            .toList(),
      );
    });
  }

  Widget _buildOrderItem(
      BuildContext context, DeliveryOrder order, bool isDark) {
    return GlassListItem(
      onTap: () => Get.dialog(UpdateStatusDialog(delivery: order)),
      leading: CircleAvatar(
        backgroundColor: order.status.deliveryColor.withOpacity(0.15),
        child: Icon(
          order.status.deliveryIcon,
          color: order.status.deliveryColor,
          size: 20,
        ),
      ),
      title: Text(order.customerName, style: AppTextStyles.bodyLarge),
      subtitle:
          Text(order.deliveryAddress, style: AppTextStyles.bodySmallSecondary),
      trailingWidgets: [
        Expanded(
          flex: 2,
          child: Center(child: _buildStatusBadge(order.status, isDark)),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              order.formattedAmount,
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(OrderStatus status, bool isDark) {
    final color = status.deliveryColor;
    final text = status.deliveryLabel;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}
