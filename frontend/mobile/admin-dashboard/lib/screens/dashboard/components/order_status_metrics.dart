import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';
import '../../../responsive.dart';

class OrderStatusMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();

    return Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
            childAspectRatio: 1.3,
            crossAxisSpacing: defaultPadding,
            mainAxisSpacing: defaultPadding,
          ),
          itemCount: OrderStatus.values.length,
          itemBuilder: (context, index) {
            final status = OrderStatus.values[index];
            final count = controller.getOrderCountByStatus(status.toString());
            final percentage =
                controller.getOrderPercentageByStatus(status.toString());

            return StatusCard(
              status: status.toString(),
              count: count,
              percentage: percentage,
            );
          },
        ));
  }
}

class StatusCard extends StatelessWidget {
  final String status;
  final int count;
  final double percentage;

  const StatusCard({
    Key? key,
    required this.status,
    required this.count,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }
}
