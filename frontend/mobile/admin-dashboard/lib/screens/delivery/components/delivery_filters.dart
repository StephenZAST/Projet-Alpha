import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../models/delivery.dart';
import '../../../constants.dart';

class DeliveryFilters extends StatelessWidget {
  const DeliveryFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtres', style: AppTextStyles.h4),
          SizedBox(height: AppSpacing.lg),
          _buildFilterControls(context, controller, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterControls(
    BuildContext context,
    DeliveryController controller,
    bool isDark,
  ) {
    return Column(
      children: [
        _buildStatusDropdown(controller, isDark),
        SizedBox(height: AppSpacing.md),
        _buildDatePicker(context, controller, isDark),
        SizedBox(height: AppSpacing.md),
        _buildTypeFilters(controller, isDark),
      ],
    );
  }

  // ...autres méthodes de build spécifiques...
}
