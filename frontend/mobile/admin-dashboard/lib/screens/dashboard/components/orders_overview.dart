import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/enums.dart';

class OrdersOverview extends StatefulWidget {
  @override
  State<OrdersOverview> createState() => _OrdersOverviewState();
}

class _OrdersOverviewState extends State<OrdersOverview> {
  final controller = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    controller.loadDraftOrders();
    controller.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aperçu des commandes',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              _OrderTypeCard(
                title: 'Commandes Flash',
                count: controller.draftOrders.length,
                icon: Icons.flash_on,
                color: AppColors.warning,
                isDark: isDark,
              ),
              SizedBox(height: AppSpacing.md),
              _OrderTypeCard(
                title: 'En attente',
                count: controller.getOrderCountByStatus(OrderStatus.PENDING),
                icon: Icons.schedule,
                color: AppColors.pending,
                isDark: isDark,
              ),
              SizedBox(height: AppSpacing.md),
              _OrderTypeCard(
                title: 'En traitement',
                count: controller.getOrderCountByStatus(OrderStatus.PROCESSING),
                icon: Icons.local_laundry_service,
                color: AppColors.processing,
                isDark: isDark,
              ),
              SizedBox(height: AppSpacing.md),
              _OrderTypeCard(
                title: 'Livrées',
                count: controller.getOrderCountByStatus(OrderStatus.DELIVERED),
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                isDark: isDark,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _OrderTypeCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _OrderTypeCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  count.toString(),
                  style: AppTextStyles.h3.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
