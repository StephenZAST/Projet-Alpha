import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../constants.dart';
import '../../../models/delivery.dart';
import '../../../models/enums.dart';

class DeliveryList extends StatelessWidget {
  const DeliveryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();

    return Obx(() {
      if (controller.isLoadingOrders.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      }

      if (controller.hasError.value) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
            ),
          ),
        );
      }

      if (controller.activeDeliveries.isEmpty) {
        return Center(
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
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        itemCount: controller.activeDeliveries.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final DeliveryOrder order = controller.activeDeliveries[index];
          return ListTile(
            title: Text(order.customerName),
            subtitle: Text(order.deliveryAddress),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(order.formattedAmount, style: AppTextStyles.bodySmall),
                SizedBox(height: 4),
                Text(order.status.toDisplayString(),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: order.status.deliveryColor)),
              ],
            ),
            onTap: () async {
              // open update status dialog
              // TODO: import and use UpdateStatusDialog when ready
            },
          );
        },
      );
    });
  }
}
