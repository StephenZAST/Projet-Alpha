import 'package:admin/screens/orders/components/order_details.dart';
import 'package:admin/screens/orders/components/status_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../models/order.dart';

class OrdersTable extends StatelessWidget {
  final List<Order> orders;

  OrdersTable({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryBg,
      child: PaginatedDataTable(
        header: Text('All Orders'),
        columns: [
          DataColumn(label: Text('Order ID')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        source: OrdersDataSource(
          orders: orders,
          onViewDetails: (order) {
            showDialog(
              context: context,
              builder: (context) => OrderDetails(order: order),
            );
          },
          onUpdateStatus: (order) {
            showDialog(
              context: context,
              builder: (context) => StatusUpdateDialog(
                orderId: order.id,
                currentStatus: order.status.label,
              ),
            );
          },
        ),
        rowsPerPage: 10,
      ),
    );
  }
}

class OrdersDataSource extends DataTableSource {
  final List<Order> orders;
  final Function(Order) onViewDetails;
  final Function(Order) onUpdateStatus;

  OrdersDataSource({
    required this.orders,
    required this.onViewDetails,
    required this.onUpdateStatus,
  });

  @override
  DataRow getRow(int index) {
    final order = orders[index];
    return DataRow(
      cells: [
        DataCell(Text(order.id)),
        DataCell(Text(order.customerName)),
        DataCell(Text(DateFormat('dd/MM/yyyy').format(order.createdAt))),
        DataCell(Text('\$${order.totalAmount.toStringAsFixed(2)}')),
        DataCell(OrderStatusBadge(status: order.status)),
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.visibility, color: AppColors.primary),
              onPressed: () => onViewDetails(order),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.warning),
              onPressed: () => onUpdateStatus(order),
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => orders.length;
  @override
  int get selectedRowCount => 0;
}

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
