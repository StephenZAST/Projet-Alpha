import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../constants.dart';

class DeliveryFilters extends StatelessWidget {
  const DeliveryFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.sm, bottom: AppSpacing.md),
            child: Text('Filtres', style: AppTextStyles.h4),
          ),
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
    return Obx(() => Row(
          children: [
            Expanded(child: _buildSearchField(controller, isDark)),
            SizedBox(width: AppSpacing.md),
            _buildActiveOnlyToggle(controller, isDark),
          ],
        ));
  }

  Widget _buildSearchField(DeliveryController controller, bool isDark) {
    return TextField(
      onChanged: controller.updateSearch,
      decoration: InputDecoration(
        hintText: 'Rechercher un livreur...',
        prefixIcon: Icon(Icons.search, color: AppColors.gray400),
        filled: true,
        fillColor: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
    );
  }

  Widget _buildActiveOnlyToggle(DeliveryController controller, bool isDark) {
    return Column(
      children: [
        Switch(
          value: controller.showActiveOnly.value,
          onChanged: (value) => controller.toggleActiveOnly(),
          activeColor: AppColors.primary,
        ),
        Text(
          'Actifs seulement',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.gray700,
          ),
        )
      ],
    );
  }
}
