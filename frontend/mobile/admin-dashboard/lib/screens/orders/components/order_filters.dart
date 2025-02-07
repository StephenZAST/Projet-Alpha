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
                children: [
                  _buildFilterChip(
                    label: 'Tous',
                    count: controller.totalOrders.value,
                    isSelected: controller.selectedStatus.value == null,
                    onSelected: (_) => controller.filterByStatus(null),
                    color: AppColors.primary,
                  ),
                  ...OrderStatus.values.map((status) {
                    final count = controller.getOrderCountByStatus(status);
                    final isSelected =
                        controller.selectedStatus.value == status;
                    return _buildFilterChip(
                      label: status.label,
                      count: count,
                      isSelected: isSelected,
                      onSelected: (selected) {
                        controller.filterByStatus(selected ? status : null);
                      },
                      color: status.color,
                    );
                  }).toList(),
                ],
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

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required Function(bool) onSelected,
    required Color color,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          SizedBox(width: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textLight,
              borderRadius: AppRadius.radiusXS,
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: color,
      backgroundColor: color.withOpacity(0.1),
      checkmarkColor: AppColors.textLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSM,
        side: BorderSide(
          color: isSelected ? color : color.withOpacity(0.5),
          width: 1,
        ),
      ),
    );
  }
}
