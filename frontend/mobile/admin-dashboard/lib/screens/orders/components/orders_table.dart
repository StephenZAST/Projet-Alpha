import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../models/order.dart';
import '../../../models/enums.dart';
import '../../../widgets/shared/glass_container.dart';

class OrdersTable extends StatefulWidget {
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
  _OrdersTableState createState() => _OrdersTableState();
}

class _OrdersTableState extends State<OrdersTable>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GlassSectionContainer(
              title: 'Liste des Commandes',
              subtitle: '${widget.orders.length} commande(s) trouvée(s)',
              icon: Icons.table_chart,
              iconColor: AppColors.primary,
              actions: [
                _ModernTableAction(
                  icon: Icons.download,
                  onPressed: () => _exportData(),
                  tooltip: 'Exporter',
                ),
                SizedBox(width: AppSpacing.sm),
                _ModernTableAction(
                  icon: Icons.refresh,
                  onPressed: () => _refreshTable(),
                  tooltip: 'Actualiser',
                ),
              ],
              child: widget.orders.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildTable(isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gray700 : AppColors.gray200)
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune commande trouvée',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Essayez de modifier vos filtres ou créez une nouvelle commande',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(bool isDark) {
    return Column(
      children: [
        _buildTableHeader(isDark),
        SizedBox(height: AppSpacing.sm),
        Expanded(
          child: widget.orders.length <= 20
              ? ListView.separated(
                  // Pour les petites listes, utiliser ListView normal
                  itemCount: widget.orders.length,
                  separatorBuilder: (context, index) => Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          (isDark ? AppColors.gray700 : AppColors.gray200)
                              .withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(30 * (1 - value), 0),
                          child: Opacity(
                            opacity: value,
                            child: _ModernOrderRow(
                              order: widget.orders[index],
                              index: index,
                              onStatusUpdate: widget.onStatusUpdate,
                              onOrderSelect: widget.onOrderSelect,
                              isDark: isDark,
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : ListView.builder(
                  // Pour les grandes listes, utiliser ListView.builder optimisé
                  itemCount: widget.orders.length,
                  itemExtent: 80, // Hauteur fixe pour chaque élément
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: _ModernOrderRow(
                        order: widget.orders[index],
                        index: index,
                        onStatusUpdate: widget.onStatusUpdate,
                        onOrderSelect: widget.onOrderSelect,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Row(
        children: [
          _HeaderCell('ID', flex: 2, isDark: isDark),
          _HeaderCell('Client', flex: 3, isDark: isDark),
          _HeaderCell('Date', flex: 3, isDark: isDark),
          _HeaderCell('Montant', flex: 3, isDark: isDark),
          _HeaderCell('Statut', flex: 4, isDark: isDark),
          _HeaderCell('Actions', flex: 3, isDark: isDark),
        ],
      ),
    );
  }

  void _exportData() {
    // TODO: Implémenter l'export des données
    print('Export des données...');
  }

  void _refreshTable() {
    _animationController.reset();
    _animationController.forward();
  }
}

// Composants modernes pour le tableau
class _ModernTableAction extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _ModernTableAction({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  _ModernTableActionState createState() => _ModernTableActionState();
}

class _ModernTableActionState extends State<_ModernTableAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _isHovered
                    ? (isDark ? AppColors.gray700 : AppColors.gray100)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  widget.icon,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: widget.onPressed,
                tooltip: widget.tooltip,
                splashRadius: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String title;
  final int flex;
  final bool isDark;

  const _HeaderCell(this.title, {required this.flex, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ModernOrderRow extends StatefulWidget {
  final Order order;
  final int index;
  final Function(String, OrderStatus) onStatusUpdate;
  final Function(String) onOrderSelect;
  final bool isDark;

  const _ModernOrderRow({
    required this.order,
    required this.index,
    required this.onStatusUpdate,
    required this.onOrderSelect,
    required this.isDark,
  });

  @override
  _ModernOrderRowState createState() => _ModernOrderRowState();
}

class _ModernOrderRowState extends State<_ModernOrderRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: GlassContainerVariant.neutral,
              padding: EdgeInsets.all(AppSpacing.md),
              margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              onTap: () => widget.onOrderSelect(widget.order.id),
              child: Row(
                children: [
                  _DataCell(
                    child: _OrderIdChip(
                      orderId: widget.order.id,
                      isFlash: widget.order.isFlashOrder,
                      isDark: widget.isDark,
                    ),
                    flex: 2,
                  ),
                  _DataCell(
                    child: _CustomerInfo(
                      name: widget.order.customerName ?? 'N/A',
                      isDark: widget.isDark,
                    ),
                    flex: 3,
                  ),
                  _DataCell(
                    child: _DateInfo(
                      date: widget.order.createdAt,
                      isDark: widget.isDark,
                    ),
                    flex: 3,
                  ),
                  _DataCell(
                    child: _AmountChip(
                      amount: widget.order.totalAmount,
                      currencyFormat: currencyFormat,
                      isDark: widget.isDark,
                    ),
                    flex: 3,
                  ),
                  _DataCell(
                    child: _ModernStatusBadge(
                      status: widget.order.status.toOrderStatus(),
                      isDark: widget.isDark,
                    ),
                    flex: 4,
                  ),
                  _DataCell(
                    child: _ActionButtons(
                      order: widget.order,
                      onStatusUpdate: widget.onStatusUpdate,
                      onOrderSelect: widget.onOrderSelect,
                      isDark: widget.isDark,
                    ),
                    flex: 3,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final Widget child;
  final int flex;

  const _DataCell({required this.child, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: child);
  }
}

class _OrderIdChip extends StatelessWidget {
  final String orderId;
  final bool isFlash;
  final bool isDark;

  const _OrderIdChip({
    required this.orderId,
    required this.isFlash,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFlash
              ? [
                  AppColors.warning.withOpacity(0.2),
                  AppColors.warning.withOpacity(0.1),
                ]
              : [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.1),
                ],
        ),
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
              size: 14,
              color: AppColors.warning,
            ),
            SizedBox(width: AppSpacing.xs),
          ],
          Text(
            '#${orderId.substring(0, 8)}',
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
}

class _CustomerInfo extends StatelessWidget {
  final String name;
  final bool isDark;

  const _CustomerInfo({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.8),
                AppColors.accent,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
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
            name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DateInfo extends StatelessWidget {
  final DateTime date;
  final bool isDark;

  const _DateInfo({required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);

    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h';
    } else {
      timeAgo = '${difference.inMinutes}min';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 12,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
            SizedBox(width: 4),
            Text(
              'Il y a $timeAgo',
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  final double amount;
  final NumberFormat currencyFormat;
  final bool isDark;

  const _AmountChip({
    required this.amount,
    required this.currencyFormat,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.2),
            AppColors.success.withOpacity(0.1),
          ],
        ),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Text(
        currencyFormat.format(amount),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ModernStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool isDark;

  const _ModernStatusBadge({
    required this.status,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            status.color.withOpacity(0.2),
            status.color.withOpacity(0.1),
          ],
        ),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: status.color.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: status.color.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: status.color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Icon(
            status.icon,
            color: status.color,
            size: 16,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            status.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Order order;
  final Function(String, OrderStatus) onStatusUpdate;
  final Function(String) onOrderSelect;
  final bool isDark;

  const _ActionButtons({
    required this.order,
    required this.onStatusUpdate,
    required this.onOrderSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final orderStatus = order.status.toOrderStatus();
    final nextStatus = _getNextStatus(orderStatus);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (nextStatus != null)
          _ModernActionButton(
            icon: nextStatus.icon,
            color: nextStatus.color,
            onPressed: () => onStatusUpdate(order.id, nextStatus),
            tooltip: 'Passer à ${nextStatus.label}',
          ),
        SizedBox(width: AppSpacing.xs),
        _ModernActionButton(
          icon: Icons.visibility,
          color: AppColors.primary,
          onPressed: () => onOrderSelect(order.id),
          tooltip: 'Voir les détails',
        ),
      ],
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

class _ModernActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _ModernActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  _ModernActionButtonState createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<_ModernActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Toutes les méthodes helper sont maintenant intégrées dans les composants modernes ci-dessus
