import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../models/order.dart';
import '../../../models/enums.dart';

class OrdersTable extends StatelessWidget {
  final List<Order> orders;
  final Function(String, OrderStatus) onStatusUpdate;
  final Function(String) onOrderSelect;

  const OrdersTable({
    Key? key,
    required this.orders,
    required this.onStatusUpdate,
    required this.onOrderSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'fcfa',
      decimalDigits: 0,
    );

    return DataTable2(
      columnSpacing: defaultPadding,
      minWidth: 600,
      columns: [
        DataColumn2(
          label: Text('ID'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Client'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Date'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Montant'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Statut'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.S,
        ),
      ],
      rows: orders.map((order) {
        final status = order.status.toOrderStatus();

        return DataRow(
          onSelectChanged: (_) => onOrderSelect(order.id),
          cells: [
            DataCell(Text(
              '#${order.id}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            )),
            DataCell(Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName ?? 'N/A',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (order.customerEmail != null)
                  Text(
                    order.customerEmail!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            )),
            DataCell(Text(
              DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
              style: AppTextStyles.bodySmall,
            )),
            DataCell(Text(
              currencyFormat.format(order.totalAmount),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            )),
            DataCell(Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.1),
                borderRadius: AppRadius.radiusSM,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status.icon,
                    size: 14,
                    color: status.color,
                  ),
                  SizedBox(width: 4),
                  Text(
                    status.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: status.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusUpdateButton(
                  order: order,
                  onStatusUpdate: onStatusUpdate,
                ),
                IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: () => onOrderSelect(order.id),
                  tooltip: 'Voir les détails',
                  iconSize: 20,
                  color: AppColors.primary,
                ),
              ],
            )),
          ],
        );
      }).toList(),
    );
  }
}

class _StatusUpdateButton extends StatelessWidget {
  final Order order;
  final Function(String, OrderStatus) onStatusUpdate;

  const _StatusUpdateButton({
    required this.order,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = order.status.toOrderStatus();
    final nextStatus = _getNextStatus(currentStatus);

    if (nextStatus == null) return SizedBox.shrink();

    return IconButton(
      icon: Icon(nextStatus.icon),
      onPressed: () => onStatusUpdate(order.id, nextStatus),
      tooltip: 'Passer à ${nextStatus.label}',
      iconSize: 20,
      color: nextStatus.color,
    );
  }

  OrderStatus? _getNextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.PENDING:
        return OrderStatus.PROCESSING;
      case OrderStatus.PROCESSING:
        return OrderStatus.READY;
      case OrderStatus.READY:
        return OrderStatus.DELIVERING;
      case OrderStatus.DELIVERING:
        return OrderStatus.DELIVERED;
      default:
        return null;
    }
  }
}
