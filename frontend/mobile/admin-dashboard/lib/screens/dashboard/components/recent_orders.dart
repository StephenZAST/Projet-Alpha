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
                style: Theme.of(context).textTheme.subtitle1,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: AppColors.primary,
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
        DataCell(Text("\$${order.amount}")),
        DataCell(Text(order.status)),
        DataCell(Text("${order.date.toLocal()}".split(' ')[0])),
      ],
    );
  }
}
