import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';
import '../../../constants.dart';
import '../../../widgets/date_range_picker.dart' as app_widgets;

class AdvancedFilters extends StatelessWidget {
  const AdvancedFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text('Filtres avancés', style: AppTextStyles.h4),
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildDateRangeAndStatus(controller, isDark),
                SizedBox(height: AppSpacing.md),
                _buildPhoneAndReset(controller, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeAndStatus(UsersController controller, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: app_widgets.DateRangePicker(
            startDate: controller.startDate.value,
            endDate: controller.endDate.value,
            onDateRangeSelected: controller.setDateRange,
            isDark: isDark,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatusDropdown(controller, isDark),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(UsersController controller, bool isDark) {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedStatus.value,
          decoration: InputDecoration(
            labelText: 'Statut',
            border: OutlineInputBorder(borderRadius: AppRadius.radiusSM),
            filled: true,
            fillColor: isDark ? AppColors.gray800 : AppColors.gray50,
          ),
          items: ['Tous', 'Actif', 'Inactif']
              .map((status) => DropdownMenuItem(
                    value: status == 'Tous' ? '' : status,
                    child: Text(status),
                  ))
              .toList(),
          onChanged: controller.setStatus,
        ));
  }

  Widget _buildPhoneAndReset(UsersController controller, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Téléphone',
              border: OutlineInputBorder(borderRadius: AppRadius.radiusSM),
              filled: true,
              fillColor: isDark ? AppColors.gray800 : AppColors.gray50,
              prefixIcon: Icon(Icons.phone),
            ),
            onChanged: controller.setPhoneFilter,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        ElevatedButton.icon(
          onPressed: controller.resetFilters,
          icon: Icon(Icons.refresh),
          label: Text('Réinitialiser'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}
