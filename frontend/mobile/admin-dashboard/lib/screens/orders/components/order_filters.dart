import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/enums.dart';
import 'dart:ui';

class OrderFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtres',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  controller.clearFilters();
                  controller.fetchOrders();
                },
                icon: Icon(Icons.refresh_outlined),
                label: Text('Réinitialiser'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Obx(() => Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilterChip(
                    label: Text('Tous'),
                    selected: controller.selectedStatus.value == null,
                    onSelected: (_) async {
                      await controller.filterByStatus(null);
                    },
                  ),
                  ...OrderStatus.values.map((status) {
                    final isSelected =
                        controller.selectedStatus.value == status;
                    return FilterChip(
                      label: Text(
                        status.toDisplayString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.textLight
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) async {
                        await controller
                            .filterByStatus(selected ? status : null);
                      },
                      selectedColor: status.color,
                      backgroundColor: status.color.withOpacity(0.1),
                      checkmarkColor: AppColors.textLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusSM,
                        side: BorderSide(
                          color: isSelected
                              ? status.color
                              : status.color.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              )),
          SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.radiusSM,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppRadius.radiusSM,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: controller.clearFilters,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.05),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_sweep_rounded,
                              color: AppColors.error.withOpacity(0.8),
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Effacer les filtres',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
