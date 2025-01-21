import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';

class OrderFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filter Orders",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: defaultPadding),
          Wrap(
            spacing: defaultPadding,
            runSpacing: defaultPadding / 2,
            children: [
              _buildFilterChip(
                label: 'All',
                selected: controller.selectedStatus.value == null,
                onSelected: (_) => controller.filterByStatus(null),
              ),
              ...OrderStatus.values.map((status) => _buildFilterChip(
                    label: status.toString(),
                    selected:
                        controller.selectedStatus.value == status.toString(),
                    onSelected: (_) =>
                        controller.filterByStatus(status.toString()),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}
