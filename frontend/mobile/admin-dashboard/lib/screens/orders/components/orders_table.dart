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
    return Column(
      children: [
        // En-tête fixe
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 1, child: Text('ID', style: AppTextStyles.bodyBold)),
              Expanded(
                  flex: 2,
                  child: Text('Client', style: AppTextStyles.bodyBold)),
              Expanded(
                  flex: 2, child: Text('Date', style: AppTextStyles.bodyBold)),
              Expanded(
                  flex: 1,
                  child: Text('Montant', style: AppTextStyles.bodyBold)),
              Expanded(
                  flex: 2,
                  child: Text('Statut', style: AppTextStyles.bodyBold)),
              Expanded(
                  flex: 1,
                  child: Text('Actions', style: AppTextStyles.bodyBold)),
            ],
          ),
        ),
        // Corps de la table avec scroll
        Expanded(
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () => onOrderSelect(order.id),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: _buildIdCell(order)),
                        Expanded(
                            flex: 2, child: _buildClientCell(order, context)),
                        Expanded(
                            flex: 2, child: _buildDateCell(order, context)),
                        Expanded(
                            flex: 1, child: _buildAmountCell(order, context)),
                        Expanded(flex: 2, child: _buildStatusCell(order)),
                        Expanded(flex: 1, child: _buildActionsCell(order)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIdCell(Order order) {
    return Text(
      '#${order.id}',
      style: AppTextStyles.bodySmall.copyWith(
        color: order.isFlashOrder ? AppColors.warning : AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildClientCell(Order order, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (order.isFlashOrder)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Text(
              'FLASH',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Text(
          order.customerName ?? 'N/A',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        if (order.customerEmail != null)
          Text(
            order.customerEmail!,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textLight.withOpacity(0.7)
                  : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  Widget _buildDateCell(Order order, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
      style: AppTextStyles.bodySmall.copyWith(
        color: isDark ? AppColors.textLight : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildAmountCell(Order order, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'fcfa',
      decimalDigits: 0,
    );
    return Text(
      currencyFormat.format(order.totalAmount),
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w600,
        fontStyle: order.isFlashOrder && order.totalAmount == 0
            ? FontStyle.italic
            : FontStyle.normal,
        color: isDark ? AppColors.textLight : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStatusCell(Order order) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
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
