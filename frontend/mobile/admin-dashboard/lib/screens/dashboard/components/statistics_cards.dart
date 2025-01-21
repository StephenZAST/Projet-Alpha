import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../constants.dart';

class StatisticsCards extends StatelessWidget {
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: defaultPadding,
      mainAxisSpacing: defaultPadding,
      children: [
        Obx(() => StatCard(
              title: 'Total Revenue',
              value: '\$${controller.totalRevenue.value.toStringAsFixed(2)}',
              icon: Icons.attach_money,
            )),
        Obx(() => StatCard(
              title: 'Total Orders',
              value: controller.totalOrders.value.toString(),
              icon: Icons.shopping_cart,
            )),
        Obx(() => StatCard(
              title: 'Total Customers',
              value: controller.totalCustomers.value.toString(),
              icon: Icons.people,
            )),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Icon(icon),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
