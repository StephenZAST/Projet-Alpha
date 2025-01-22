import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/enums.dart';

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
          Text(
            'Filtres',
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Obx(() => Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: OrderStatus.values.map((status) {
                  final isSelected = controller.selectedStatus.value == status;
                  return FilterChip(
                    label: Text(
                      status.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.textLight
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.filterByStatus(selected ? status : null);
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
              )),
          SizedBox(height: AppSpacing.md),
          TextField(
            onChanged: controller.searchOrders,
            decoration: InputDecoration(
              hintText: 'Rechercher une commande...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: controller.clearFilters,
                icon: Icon(Icons.clear),
                label: Text('Effacer les filtres'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
