import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../models/order.dart';
import '../../../models/enums.dart';
import '../../../utils/safe_extensions.dart';
import '../../../widgets/shared/glass_button.dart';

/// Table moderne pour les commandes avec effet glassmorphism et zébrage
class SimpleOrdersTable extends StatelessWidget {
  final List<Order> orders;
  final Function(String, OrderStatus) onStatusUpdate;
  final Function(String) onOrderSelect;

  const SimpleOrdersTable({
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
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusMD,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.gray800.withOpacity(0.8)
                  : Colors.white.withOpacity(0.9),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: isDark
                    ? AppColors.gray700.withOpacity(0.3)
                    : AppColors.gray200.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildHeader(isDark),
                if (orders.isEmpty)
                  _buildEmptyState(isDark)
                else
                  Container(
                    height: 400,
                    child: ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.gray700.withOpacity(0.3)
                            : AppColors.gray200.withOpacity(0.5),
                      ),
                      itemBuilder: (context, index) {
                        return _buildOrderRow(orders[index], index, isDark);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : AppColors.white,
        borderRadius: AppRadius.radiusMD,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune commande trouvée',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Les commandes apparaîtront ici',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray900.withOpacity(0.3)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          topRight: Radius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('ID', flex: 2, isDark: isDark),
          _buildHeaderCell('Client', flex: 3, isDark: isDark),
          _buildHeaderCell('Date', flex: 2, isDark: isDark),
          _buildHeaderCell('Montant', flex: 2, isDark: isDark),
          _buildHeaderCell('Statut', flex: 2, isDark: isDark),
          _buildHeaderCell('Actions', flex: 2, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {required int flex, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: AppTextStyles.bodyBold.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildOrderRow(Order order, int index, bool isDark) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    // Gestion sécurisée du nom client
    final customerName = _getCustomerName(order);
    final orderStatus = _getOrderStatus(order);

    return InkWell(
      onTap: () => onOrderSelect(order.id),
      child: Container(
        // Effet de zébrage
        color: index % 2 == 0
            ? (isDark ? AppColors.gray900 : AppColors.gray50)
            : Colors.transparent,
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // ID - Version simple avec pointillés
            Expanded(
              flex: 2,
              child: _buildIdCell(order.id, order.isFlashOrder, isDark),
            ),
            
            // Client
            Expanded(
              flex: 3,
              child: _buildCustomerInfo(customerName, isDark),
            ),
            
            // Date
            Expanded(
              flex: 2,
              child: _buildDateInfo(order.createdAt, isDark),
            ),
            
            // Montant
            Expanded(
              flex: 2,
              child: _buildAmountChip(order.totalAmount, currencyFormat, isDark),
            ),
            
            // Statut
            Expanded(
              flex: 2,
              child: _buildStatusBadge(orderStatus, isDark),
            ),
            
            // Actions
            Expanded(
              flex: 2,
              child: _buildActions(order, orderStatus, isDark),
            ),
          ],
        ),
      ),
    );
  }

  String _getCustomerName(Order order) {
    // Gestion sécurisée du nom client
    if (order.user != null) {
      final firstName = order.user!.firstName ?? '';
      final lastName = order.user!.lastName ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }
    return 'Client inconnu';
  }

  OrderStatus _getOrderStatus(Order order) {
    try {
      return order.status.toOrderStatus();
    } catch (e) {
      return OrderStatus.PENDING;
    }
  }

  Widget _buildIdCell(String orderId, bool isFlash, bool isDark) {
    // Affichage simple avec pointillés comme dans users_table
    final displayId = orderId.length > 8 ? orderId.substring(0, 8) + '...' : orderId;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isFlash) ...[
              Icon(
                Icons.flash_on,
                size: 14,
                color: AppColors.warning,
              ),
              SizedBox(width: 4),
            ],
            Text(
              '#$displayId',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        if (isFlash)
          Text(
            'Flash Order',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerInfo(String customerName, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            customerName,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(DateTime date, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          DateFormat('HH:mm').format(date),
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChip(double amount, NumberFormat format, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Text(
        format.format(amount),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: status.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            status.label,
            style: AppTextStyles.caption.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(Order order, OrderStatus status, bool isDark) {
    final nextStatus = _getNextStatus(status);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (nextStatus != null)
          _buildActionButton(
            icon: nextStatus.icon,
            color: nextStatus.color,
            onPressed: () => onStatusUpdate(order.id, nextStatus),
            tooltip: 'Passer à ${nextStatus.label}',
          ),
        SizedBox(width: 4),
        _buildActionButton(
          icon: Icons.visibility,
          color: AppColors.primary,
          onPressed: () => onOrderSelect(order.id),
          tooltip: 'Voir détails',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }

  OrderStatus? _getNextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.DRAFT:
        return OrderStatus.PENDING;
      case OrderStatus.PENDING:
        return OrderStatus.COLLECTING;
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