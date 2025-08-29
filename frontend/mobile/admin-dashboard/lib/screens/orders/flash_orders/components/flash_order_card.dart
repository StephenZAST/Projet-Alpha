import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../../../../models/order.dart';
import 'flash_order_detail_dialog.dart';

class FlashOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const FlashOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: AppRadius.radiusMD,
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => FlashOrderDetailDialog(order: order),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${order.id}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Text(
                      'FLASH',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              if (order.customerName != null) ...[
                Text(
                  order.customerName!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
              ],
              if (order.deliveryAddress != null) ...[
                Text(
                  order.deliveryAddress!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
              ],
              if (order.note != null && order.note!.isNotEmpty) ...[
                Text(
                  'Note: ${order.note}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
