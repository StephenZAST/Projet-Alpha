import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/order.dart';

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
  final List<Order> demoOrders = [
    Order(
        id: "1",
        customerName: "John Doe",
        totalAmount: 150.0,
        status: OrderStatus.PENDING,
        createdAt: DateTime.now()),
    Order(
        id: "2",
        customerName: "Jane Smith",
        totalAmount: 250.0,
        status: OrderStatus.DELIVERED,
        createdAt: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text("Order ID")),
          DataColumn(label: Text("Customer Name")),
          DataColumn(label: Text("Amount")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Date")),
        ],
        rows: List.generate(
          demoOrders.length,
          (index) => orderDataRow(demoOrders[index]),
        ),
      ),
    );
  }

  DataRow orderDataRow(Order order) {
    return DataRow(
      cells: [
        DataCell(Text(order.id)),
        DataCell(Text(order.customerName)),
        DataCell(Text("\$${order.totalAmount}")),
        DataCell(Text(order.status.toString().split('.').last)),
        DataCell(Text("${order.createdAt.toLocal()}".split(' ')[0])),
      ],
    );
  }
}
