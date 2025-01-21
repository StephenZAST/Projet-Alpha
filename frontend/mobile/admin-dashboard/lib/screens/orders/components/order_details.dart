import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../models/order.dart';

class OrderDetails extends StatelessWidget {
  final Order order;

  const OrderDetails({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(defaultPadding),
        width: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Divider(),
            OrderInfoRow(label: 'Order ID', value: order.id),
            OrderInfoRow(
              label: 'Customer',
              value: order.user?.email ?? 'N/A',
            ),
            OrderInfoRow(
              label: 'Date',
              value: DateFormat('dd/MM/yyyy').format(order.createdAt),
            ),
            OrderInfoRow(
              label: 'Amount',
              value: '\$${order.totalAmount.toStringAsFixed(2)}',
            ),
            OrderInfoRow(
              label: 'Status',
              value: OrderStatusExtension(OrderStatus.values.firstWhere(
                (s) => s.toString().split('.').last == order.status,
                orElse: () => OrderStatus.PENDING,
              )).label,
            ),
            SizedBox(height: defaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const OrderInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
