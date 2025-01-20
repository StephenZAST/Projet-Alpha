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

    return GridView.builder(
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
        return OrderStatusCard(status: status);
      },
    );
  }
}

class OrderStatusCard extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusCard({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() {
                  final count = Get.find<OrdersController>()
                      .getOrderCountByStatus(status);
                  return Text(
                    '$count',
                    style: TextStyle(color: status.color),
                  );
                }),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: Get.find<OrdersController>()
                    .getOrderPercentageByStatus(status) /
                100,
            backgroundColor: status.color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(status.color),
          ),
        ],
      ),
    );
  }
}
