import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../constants.dart';

class DailyPerformanceCard extends StatelessWidget {
  const DailyPerformanceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppSpacing.lg),
            _buildProgressIndicators(controller, isDark),
            SizedBox(height: AppSpacing.lg),
            _buildStats(controller, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Performance du jour',
      style: AppTextStyles.h4,
    );
  }

  Widget _buildProgressIndicators(DeliveryController controller, bool isDark) {
    return Column(
      children: [
        // TODO: Implémenter les indicateurs de progression
        // Exemple:
        // LinearProgressIndicator(
        //   value: controller.completedDeliveries.value / controller.totalDeliveries.value,
        //   backgroundColor: AppColors.gray200,
        //   color: AppColors.success,
        // ),
      ],
    );
  }

  Widget _buildStats(DeliveryController controller, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // TODO: Implémenter les statistiques
        // Exemple:
        // Text('${controller.completedDeliveries.value} / ${controller.totalDeliveries.value} Livraisons complétées'),
      ],
    );
  }
  // ... rest of the implementation with the helper methods ...
}
