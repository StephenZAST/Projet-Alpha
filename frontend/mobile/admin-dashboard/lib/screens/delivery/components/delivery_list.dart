import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../models/delivery.dart';
import '../../../constants.dart';
import './delivery_list_item.dart';

class DeliveryList extends StatelessWidget {
  const DeliveryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();

    return Obx(() {
      if (controller.isLoading.value) {
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

      if (controller.deliveries.isEmpty) {
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
        itemCount: controller.deliveries.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final delivery = controller.deliveries[index];
          return DeliveryListItem(delivery: delivery);
        },
      );
    });
  }
}
