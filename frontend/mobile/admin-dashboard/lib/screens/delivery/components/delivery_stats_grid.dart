import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../models/enums.dart';

class DeliveryStatsGrid extends StatelessWidget {
  const DeliveryStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final stats = controller.globalStats.value;
      if (controller.isLoadingStats.value || stats == null) {
        return Center(child: CircularProgressIndicator());
      }

      final statusEntries = stats.ordersByStatus.entries.toList();

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
        ),
        itemCount: statusEntries.length,
        itemBuilder: (context, index) {
          final entry = statusEntries[index];
          final status = OrderStatus.values.firstWhere(
            (e) => e.name == entry.key,
            orElse: () => OrderStatus.DRAFT,
          );
          return _buildCard(
            context,
            title: status.label,
            value: entry.value.toString(),
            icon: status.icon,
            color: status.color,
            isDark: isDark,
          );
        },
      );
    });
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
