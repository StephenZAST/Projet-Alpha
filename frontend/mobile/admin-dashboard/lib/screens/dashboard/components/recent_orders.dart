import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/order.dart';
import '../../../models/enums.dart';

class RecentOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
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
                'Commandes récentes',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextButton.icon(
                icon: Icon(Icons.refresh),
                label: Text('Actualiser'),
                onPressed: controller.refreshDashboard,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (controller.recentOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Aucune commande récente',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.recentOrders.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final order = controller.recentOrders[index];
                return _OrderListItem(order: order);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final Order order;

  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status.toOrderStatus();
    final formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt);
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'fcfa',
      decimalDigits: 0,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.customerName ?? 'Client inconnu',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Commande #${order.id}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            currencyFormat.format(order.totalAmount),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.1),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status.icon,
                  size: 14,
                  color: status.color,
                ),
                SizedBox(width: 4),
                Text(
                  status.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        // TODO: Naviguer vers les détails de la commande
      },
    );
  }
}
