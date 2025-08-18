import 'package:admin/models/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';

class ServiceSelection extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service', style: AppTextStyles.h3),
            SizedBox(height: AppSpacing.md),
            Obx(() => DropdownButtonFormField<Service>(
                  value: controller.selectedService.value,
                  hint: Text('Sélectionner un service'),
                  isExpanded: true,
                  items: controller.services.map((service) {
                    return DropdownMenuItem(
                      value: service,
                      child: Text(service.name),
                    );
                  }).toList(),
                  onChanged: (service) {
                    controller.selectedService.value = service;
                    if (service != null) {
                      controller
                          .setSelectedService(service.id); // MAJ OrderDraft
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
