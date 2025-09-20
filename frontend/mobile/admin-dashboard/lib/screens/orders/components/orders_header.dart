import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../routes/admin_routes.dart';
import '../../../widgets/shared/glass_container.dart';

class OrdersHeader extends StatefulWidget {
  @override
  _OrdersHeaderState createState() => _OrdersHeaderState();
}

class _OrdersHeaderState extends State<OrdersHeader>
    with TickerProviderStateMixin {
  final searchController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _titleController;
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

    _titleController = AnimationController(
      duration: Duration(milliseconds: 1200),
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
      begin: Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
    _titleController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GlassSectionContainer(
              title: 'Gestion des Commandes',
              subtitle: 'Suivi et administration des commandes',
              icon: Icons.receipt_long,
              iconColor: AppColors.primary,
              actions: [
                _ModernSearchBar(
                  controller: searchController,
                  onChanged: controller.searchOrders,
                ),
                SizedBox(width: AppSpacing.md),
                _ModernViewToggle(
                  currentView: controller.currentView,
                  onViewChanged: controller.setView,
                ),
                SizedBox(width: AppSpacing.md),
                _ModernActionButton(
                  label: "Flash",
                  icon: Icons.flash_on,
                  onPressed: () => AdminRoutes.goToFlashOrders(),
                  variant: _ActionButtonVariant.warning,
                ),
                SizedBox(width: AppSpacing.sm),
                _ModernActionButton(
                  label: "Nouvelle",
                  icon: Icons.add,
                  onPressed: () => Get.toNamed('/orders/create'),
                  variant: _ActionButtonVariant.primary,
                ),
              ],
              child: _buildQuickStats(controller, isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(OrdersController controller, bool isDark) {
    return Obx(() {
      final stats = controller.quickStats;

      return Row(
        children: [
          Expanded(
            child: _QuickStatCard(
              title: 'Total',
              value: stats['total']?.toString() ?? '0',
              icon: Icons.receipt,
              color: AppColors.primary,
              isDark: isDark,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _QuickStatCard(
              title: 'En cours',
              value: stats['processing']?.toString() ?? '0',
              icon: Icons.pending_actions,
              color: AppColors.warning,
              isDark: isDark,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _QuickStatCard(
              title: 'Livrées',
              value: stats['delivered']?.toString() ?? '0',
              icon: Icons.check_circle,
              color: AppColors.success,
              isDark: isDark,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _QuickStatCard(
              title: 'Flash',
              value: stats['flash']?.toString() ?? '0',
              icon: Icons.flash_on,
              color: AppColors.accent,
              isDark: isDark,
            ),
          ),
        ],
      );
    });
  }
}

// Composants modernes pour le header des commandes
enum _ActionButtonVariant { primary, warning, success, error }

class _ModernActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final _ActionButtonVariant variant;

  const _ModernActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.variant,
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
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
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

  Color _getVariantColor() {
    switch (widget.variant) {
      case _ActionButtonVariant.primary:
        return AppColors.primary;
      case _ActionButtonVariant.warning:
        return AppColors.warning;
      case _ActionButtonVariant.success:
        return AppColors.success;
      case _ActionButtonVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();

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
              variant: GlassContainerVariant.primary,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: variantColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: variantColor.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.icon,
                      color: variantColor,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: variantColor,
                      fontWeight: FontWeight.w600,
                    ),
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

class _ModernSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _ModernSearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  _ModernSearchBarState createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<_ModernSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 40.0,
      end: 250.0,
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

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return GlassContainer(
          variant: GlassContainerVariant.neutral,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          borderRadius: AppRadius.lg,
          width: _widthAnimation.value,
          height: 40,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _isExpanded = !_isExpanded);
                  if (_isExpanded) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                    widget.controller.clear();
                    widget.onChanged('');
                  }
                },
                child: Icon(
                  _isExpanded ? Icons.close : Icons.search,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  size: 20,
                ),
              ),
              if (_isExpanded) ...[
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ModernViewToggle extends StatelessWidget {
  final Rx<OrderView> currentView;
  final void Function(OrderView) onViewChanged;

  const _ModernViewToggle({
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(4),
        borderRadius: AppRadius.lg,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: OrderView.values.map((view) {
            final isSelected = currentView.value == view;
            return GestureDetector(
              onTap: () => onViewChanged(view),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _getViewIcon(view),
                  color: isSelected
                      ? AppColors.primary
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.gray400
                          : AppColors.gray600),
                  size: 20,
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  IconData _getViewIcon(OrderView view) {
    switch (view) {
      case OrderView.table:
        return Icons.table_chart;
      case OrderView.map:
        return Icons.map;
      case OrderView.cards:
        return Icons.view_module;
    }
  }
}

class _QuickStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  _QuickStatCardState createState() => _QuickStatCardState();
}

class _QuickStatCardState extends State<_QuickStatCard>
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
      end: 1.05,
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
            child: GlassContainer(
              variant: GlassContainerVariant.neutral,
              padding: EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 20,
                        ),
                      ),
                      Text(
                        widget.value,
                        style: AppTextStyles.h3.copyWith(
                          color: widget.isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          widget.isDark ? AppColors.gray400 : AppColors.gray600,
                      fontWeight: FontWeight.w500,
                    ),
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
