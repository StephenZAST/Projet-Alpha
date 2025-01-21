import 'package:flutter/material.dart';
import '../../../models/order.dart';
import '../../../constants.dart';
import 'package:intl/intl.dart';

class OrdersTable extends StatelessWidget {
  final List<Order> orders;
  final Function(String, String) onStatusUpdate;

  const OrdersTable({
    Key? key,
    required this.orders,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Actions')),
          ],
          rows: orders.map((order) {
            return DataRow(
              cells: [
                DataCell(Text(order.id.substring(0, 8))),
                DataCell(Text(order.user?.email ?? 'N/A')),
                DataCell(_buildStatusDropdown(order)),
                DataCell(Text('\$${order.totalAmount}')),
                DataCell(Text(DateFormat('dd/MM/yy').format(order.createdAt))),
                DataCell(_buildActions(context, order)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(Order order) {
    return DropdownButton<String>(
      value: order.status,
      items: OrderStatus.values.map((status) {
        return DropdownMenuItem(
          value: status.label, // Utiliser le label au lieu de toString()
          child: Text(status.label),
        );
      }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null) {
          onStatusUpdate(order.id, newStatus);
        }
      },
    );
  }

  Widget _buildActions(BuildContext context, Order order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.visibility),
          onPressed: () {
            // Navigation vers les détails de la commande
            Navigator.pushNamed(context, '/orders/${order.id}');
          },
        ),
        IconButton(
          icon: Icon(Icons.receipt),
          onPressed: () {
            // Générer la facture
          },
        ),
      ],
    );
  }
}
