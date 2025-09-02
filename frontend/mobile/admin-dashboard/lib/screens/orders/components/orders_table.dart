import 'package:flutter/material.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
              borderRadius: BorderRadius.only(
                topLeft: AppRadius.radiusMD.topLeft,
                topRight: AppRadius.radiusMD.topRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 2, child: Text('ID', style: AppTextStyles.bodyBold)),
                Expanded(
                    flex: 3,
                    child: Text('Client', style: AppTextStyles.bodyBold)),
                Expanded(
                    flex: 3,
                    child: Text('Date', style: AppTextStyles.bodyBold)),
                Expanded(
                    flex: 3,
                    child: Text('Montant', style: AppTextStyles.bodyBold)),
                Expanded(
                    flex: 4,
                    child: Text('Statut', style: AppTextStyles.bodyBold)),
                Expanded(
                    flex: 3,
                    child: Text('Actions', style: AppTextStyles.bodyBold)),
              ],
            ),
          ),
          // Data rows
          if (orders.isEmpty)
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Text('Aucune commande trouvée',
                  style: AppTextStyles.bodyMedium),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return InkWell(
                    onTap: () => onOrderSelect(order.id),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? (isDark ? AppColors.gray900 : AppColors.gray50)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          _dataCell(order.id, flex: 2),
                          _dataCell(order.customerName ?? 'N/A', flex: 3),
                          _dataCell(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(order.createdAt),
                              flex: 3),
                          _dataCell(
                              NumberFormat.currency(
                                      locale: 'fr_FR',
                                      symbol: 'fcfa',
                                      decimalDigits: 0)
                                  .format(order.totalAmount),
                              flex: 3),
                          _statusCell(order, flex: 4),
                          Expanded(flex: 3, child: _buildActionsCell(order)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _dataCell(String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: AppTextStyles.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _statusCell(Order order, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(order.status).withOpacity(0.1),
          borderRadius: AppRadius.radiusSM,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (order.isFlashOrder)
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.flash_on,
                  size: 14,
                  color: AppColors.warning,
                ),
              ),
            Icon(
              _getStatusIcon(order.status),
              size: 14,
              color: _getStatusColor(order.status),
            ),
            SizedBox(width: 4),
            Text(
              _getStatusLabel(order.status),
              style: AppTextStyles.bodySmall.copyWith(
                color: _getStatusColor(order.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCell(Order order) {
    final orderStatus = order.status.toOrderStatus();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusUpdateButton(
          order: order,
          currentStatus: orderStatus,
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return AppColors.gray400;
      case 'PENDING':
        return AppColors.warning;
      case 'COLLECTING':
        return AppColors.info;
      case 'COLLECTED':
        return AppColors.accent;
      case 'PROCESSING':
        return AppColors.primary;
      case 'READY':
        return AppColors.violet;
      case 'DELIVERING':
        return AppColors.orange;
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.gray400;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return 'Brouillon';
      case 'PENDING':
        return 'En attente';
      case 'COLLECTING':
        return 'En collecte';
      case 'COLLECTED':
        return 'Collecté';
      case 'PROCESSING':
        return 'En traitement';
      case 'READY':
        return 'Prêt';
      case 'DELIVERING':
        return 'En livraison';
      case 'DELIVERED':
        return 'Livré';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return Icons.edit_note;
      case 'PENDING':
        return Icons.pending_actions;
      case 'COLLECTING':
        return Icons.directions_run;
      case 'COLLECTED':
        return Icons.check_circle_outline;
      case 'PROCESSING':
        return Icons.local_laundry_service;
      case 'READY':
        return Icons.thumb_up_outlined;
      case 'DELIVERING':
        return Icons.local_shipping_outlined;
      case 'DELIVERED':
        return Icons.task_alt;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

class _StatusUpdateButton extends StatelessWidget {
  final Order order;
  final OrderStatus currentStatus;
  final Function(String, OrderStatus) onStatusUpdate;

  const _StatusUpdateButton({
    required this.order,
    required this.currentStatus,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
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
        return OrderStatus.COLLECTING;
      case OrderStatus.DRAFT:
        return OrderStatus.PENDING;
      case OrderStatus.COLLECTING:
        return OrderStatus.COLLECTED;
      case OrderStatus.COLLECTED:
        return OrderStatus.PROCESSING;
      case OrderStatus.PROCESSING:
        return OrderStatus.READY;
      case OrderStatus.READY:
        return OrderStatus.DELIVERING;
      case OrderStatus.DELIVERING:
        return OrderStatus.DELIVERED;
      case OrderStatus.DELIVERED:
      case OrderStatus.CANCELLED:
        return null;
    }
  }
}
