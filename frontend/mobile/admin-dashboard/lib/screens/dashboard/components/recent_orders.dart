import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/order.dart';
import '../../../models/enums.dart';
import '../../../routes/admin_routes.dart';
import '../../../widgets/shared/glass_container.dart';

class RecentOrders extends StatefulWidget {
  @override
  _RecentOrdersState createState() => _RecentOrdersState();
}

class _RecentOrdersState extends State<RecentOrders>
    with SingleTickerProviderStateMixin {
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

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
      duration: Duration(milliseconds: 600),
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
      begin: Offset(0.3, 0),
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
    final controller = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GlassSectionContainer(
              title: 'Commandes Récentes',
              subtitle: 'Activité en temps réel',
              icon: Icons.receipt_long,
              iconColor: AppColors.primary,
              actions: [
                _ModernActionButton(
                  icon: Icons.refresh,
                  onPressed: () {
                    controller.refreshDashboard();
                    _animationController.reset();
                    _animationController.forward();
                  },
                  tooltip: 'Actualiser',
                ),
                SizedBox(width: AppSpacing.sm),
                _ModernActionButton(
                  icon: Icons.open_in_new,
                  onPressed: () => Get.toNamed(AdminRoutes.orders),
                  tooltip: 'Voir toutes les commandes',
                ),
              ],
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingState(isDark);
                }

                if (controller.recentOrders.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return _buildOrdersList(controller.recentOrders, isDark);
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PulsingOrderIndicator(),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Chargement des commandes...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Récupération des données',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
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
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gray700 : AppColors.gray200)
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 48,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune commande récente',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Les nouvelles commandes apparaîtront ici',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, bool isDark) {
    return Container(
      constraints: BoxConstraints(maxHeight: 400),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: orders.length,
        separatorBuilder: (context, index) => Container(
          height: 1,
          margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                (isDark ? AppColors.gray700 : AppColors.gray200).withOpacity(0.5),
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
                offset: Offset(20 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: _ModernOrderListItem(
                    order: orders[index],
                    currencyFormat: currencyFormat,
                    isDark: isDark,
                    index: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Composants modernes pour les commandes récentes
class _ModernActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _ModernActionButton({
    required this.icon,
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

class _PulsingOrderIndicator extends StatefulWidget {
  @override
  _PulsingOrderIndicatorState createState() => _PulsingOrderIndicatorState();
}

class _PulsingOrderIndicatorState extends State<_PulsingOrderIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(_animation.value),
                AppColors.accent.withOpacity(_animation.value),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(_animation.value * 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}

class _ModernOrderListItem extends StatefulWidget {
  final Order order;
  final NumberFormat currencyFormat;
  final bool isDark;
  final int index;

  const _ModernOrderListItem({
    required this.order,
    required this.currencyFormat,
    required this.isDark,
    required this.index,
  });

  @override
  _ModernOrderListItemState createState() => _ModernOrderListItemState();
}

class _ModernOrderListItemState extends State<_ModernOrderListItem>
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
    final status = widget.order.status.toOrderStatus();
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(widget.order.createdAt);

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
              onTap: () => Get.toNamed('${AdminRoutes.orders}/${widget.order.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar du client
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              status.color.withOpacity(0.8),
                              status.color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: status.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (widget.order.customerName ?? 'C')[0].toUpperCase(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      
                      // Informations de la commande
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order.customerName ?? 'Client inconnu',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt,
                                  size: 14,
                                  color: widget.isDark 
                                      ? AppColors.gray400 
                                      : AppColors.gray600,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  '#${widget.order.id.substring(0, 8)}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: widget.isDark 
                                        ? AppColors.gray400 
                                        : AppColors.gray600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Badge de statut
                      _ModernStatusBadge(
                        status: status,
                        isDark: widget.isDark,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: AppSpacing.md),
                  
                  // Informations supplémentaires
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: widget.isDark 
                                ? AppColors.gray400 
                                : AppColors.gray600,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            formattedDate,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.isDark 
                                  ? AppColors.gray400 
                                  : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success.withOpacity(0.1),
                              AppColors.success.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: AppRadius.radiusSM,
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.currencyFormat.format(widget.order.totalAmount),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
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
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
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
        borderRadius: AppRadius.radiusSM,
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
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: status.color.withOpacity(0.5),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
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

// Ancien composant conservé pour compatibilité
class _OrderListItem extends StatelessWidget {
  final Order order;
  final NumberFormat currencyFormat;
  final bool isDark;

  const _OrderListItem({
    required this.order,
    required this.currencyFormat,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status.toOrderStatus();
    final formattedDate =
        DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed('${AdminRoutes.orders}/${order.id}'),
        borderRadius: AppRadius.radiusSM,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName ?? 'Client inconnu',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Commande #${order.id.substring(0, 8)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
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
                          size: 16,
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
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    currencyFormat.format(order.totalAmount),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
