import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';

class ServiceSelectionStep extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sélectionner un service', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.md),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.services.length,
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  return ListTile(
                    title: Text(service.name),
                    subtitle: Text(service.description ?? ''),
                    trailing: Radio<String>(
                      value: service.id,
                      groupValue: controller.selectedServiceId.value,
                      onChanged: (value) =>
                          controller.selectedServiceId.value = value,
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }
}
