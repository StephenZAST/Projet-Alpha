import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../models/order.dart';
import '../../../models/enums.dart';
import '../../../utils/safe_extensions.dart';

/// Table simple et robuste pour les commandes
/// Évite tous les problèmes de layout complexes
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

    if (orders.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : AppColors.white,
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(isDark),
          
          // Body - Liste simple sans problèmes de layout
          Container(
            height: 400, // Hauteur fixe pour éviter les problèmes
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderRow(orders[index], index, isDark);
              },
            ),
          ),
        ],
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
            ? AppColors.gray700.withOpacity(0.5)
            : AppColors.gray100.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          topRight: Radius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _headerText('ID', isDark)),
          Expanded(flex: 3, child: _headerText('Client', isDark)),
          Expanded(flex: 2, child: _headerText('Date', isDark)),
          Expanded(flex: 2, child: _headerText('Montant', isDark)),
          Expanded(flex: 2, child: _headerText('Statut', isDark)),
          Expanded(flex: 2, child: _headerText('Actions', isDark)),
        ],
      ),
    );
  }

  Widget _headerText(String text, bool isDark) {
    return Text(
      text,
      style: AppTextStyles.bodyBold.copyWith(
        color: isDark ? AppColors.textLight : AppColors.textPrimary,
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

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
        ),
      ),
      child: InkWell(
        onTap: () => onOrderSelect(order.id),
        child: Row(
          children: [
            // ID
            Expanded(
              flex: 2,
              child: _buildIdChip(order.id, order.isFlashOrder, isDark),
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

  Widget _buildIdChip(String orderId, bool isFlash, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isFlash 
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: isFlash 
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFlash) ...[
            Icon(
              Icons.flash_on,
              size: 12,
              color: AppColors.warning,
            ),
            SizedBox(width: 4),
          ],
          Text(
            '#${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
            style: AppTextStyles.bodySmall.copyWith(
              color: isFlash ? AppColors.warning : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
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