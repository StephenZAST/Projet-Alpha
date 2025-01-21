import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/order.dart';
import '../../../controllers/dashboard_controller.dart';

class RecentOrders extends StatelessWidget {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Orders",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                icon: Icon(Icons.add),
                label: Text("View All"),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: defaultPadding),
          OrdersDataTable(),
        ],
      ),
    );
  }
}

class OrdersDataTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text("Order ID")),
              DataColumn(label: Text("Customer")),
              DataColumn(label: Text("Amount")),
              DataColumn(label: Text("Status")),
              DataColumn(label: Text("Date")),
            ],
            rows: controller.recentOrders
                .map((order) => orderDataRow(order))
                .toList(),
          ),
        ));
  }

  DataRow orderDataRow(Order order) {
    return DataRow(
      cells: [
        DataCell(Text(order.id.substring(0, 8))),
        DataCell(Text(order.user?.email ?? 'N/A')),
        DataCell(Text("\$${order.totalAmount.toStringAsFixed(2)}")),
        DataCell(Text(OrderStatusExtension(OrderStatus.values.firstWhere(
          (s) => s.toString().split('.').last == order.status,
          orElse: () => OrderStatus.PENDING,
        )).label)),
        DataCell(Text("${order.createdAt.toLocal()}".split(' ')[0])),
      ],
    );
  }
}
