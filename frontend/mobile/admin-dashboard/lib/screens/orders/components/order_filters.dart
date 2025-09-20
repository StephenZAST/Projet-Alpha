import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/enums.dart';
import '../../../widgets/shared/glass_container.dart';

class OrderFilters extends StatefulWidget {
  @override
  _OrderFiltersState createState() => _OrderFiltersState();
}

class _OrderFiltersState extends State<OrderFilters>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _expandController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

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

    _expandController = AnimationController(
      duration: Duration(milliseconds: 400),
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
      begin: Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _expandController.dispose();
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
              title: 'Filtres Avancés',
              subtitle: 'Affinez votre recherche',
              icon: Icons.filter_list,
              iconColor: AppColors.accent,
              actions: [
                _ModernToggleButton(
                  icon: _isExpanded ? Icons.expand_less : Icons.expand_more,
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                    if (_isExpanded) {
                      _expandController.forward();
                    } else {
                      _expandController.reverse();
                    }
                  },
                  tooltip: _isExpanded ? 'Réduire' : 'Développer',
                ),
                SizedBox(width: AppSpacing.sm),
                _ModernClearButton(
                  onPressed: controller.clearFilters,
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickFilters(controller, isDark),
                  AnimatedBuilder(
                    animation: _expandAnimation,
                    builder: (context, child) {
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: _expandAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        SizedBox(height: AppSpacing.lg),
                        _buildAdvancedFilters(controller, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickFilters(OrdersController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres Rapides',
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Obx(() => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ModernFilterChip(
                  label: 'Tous',
                  isSelected: controller.selectedStatus.value == null,
                  onSelected: (_) => controller.filterByStatus(null),
                  color: AppColors.primary,
                  count: controller.orders.length,
                ),
                ...OrderStatus.values.map((status) {
                  final isSelected = controller.selectedStatus.value == status;
                  final count = controller.orders
                      .where((o) => o.status.toUpperCase() == status.name)
                      .length;

                  return _ModernFilterChip(
                    label: status.label,
                    isSelected: isSelected,
                    onSelected: (selected) {
                      controller.filterByStatus(selected ? status : null);
                    },
                    color: status.color,
                    count: count,
                    icon: status.icon,
                  );
                }).toList(),
              ],
            )),
        SizedBox(height: AppSpacing.md),
        _buildFlashOrderToggle(controller, isDark),
      ],
    );
  }

  Widget _buildFlashOrderToggle(OrdersController controller, bool isDark) {
    return Obx(() => GlassContainer(
          variant: GlassContainerVariant.neutral,
          padding: EdgeInsets.all(AppSpacing.md),
          borderRadius: AppRadius.md,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commandes Flash',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Afficher uniquement les commandes flash',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              _ModernSwitch(
                value: controller.isFlashOrderFilter.value,
                onChanged: controller.filterByFlashOrder,
              ),
            ],
          ),
        ));
  }

  Widget _buildAdvancedFilters(OrdersController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres Avancés',
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModernDatePicker(
                label: 'Date de début',
                controller: controller.startDateController,
                onTap: () => controller.pickStartDate(context),
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModernDatePicker(
                label: 'Date de fin',
                controller: controller.endDateController,
                onTap: () => controller.pickEndDate(context),
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModernAmountField(
                label: 'Montant min',
                value: controller.minAmount,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModernAmountField(
                label: 'Montant max',
                value: controller.maxAmount,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModernDropdown(
                label: 'Type de service',
                value: controller.selectedServiceType.value,
                items: [
                  {'value': null, 'label': 'Tous les types'},
                  ...controller.serviceTypes.map((type) => {
                        'value': type.id,
                        'label': type.name,
                      }),
                ],
                onChanged: (value) =>
                    controller.selectedServiceType.value = value,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModernDropdown(
                label: 'Mode de paiement',
                value: controller.selectedPaymentMethod.value,
                items: [
                  {'value': null, 'label': 'Tous les modes'},
                  ...controller.paymentMethods.map((method) => {
                        'value': method,
                        'label': method == 'CASH' ? 'Espèces' : 'Orange Money',
                      }),
                ],
                onChanged: (value) =>
                    controller.selectedPaymentMethod.value = value,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ModernFilterButton(
              label: 'Réinitialiser',
              icon: Icons.refresh,
              onPressed: controller.resetFilters,
              variant: _FilterButtonVariant.secondary,
            ),
            SizedBox(width: AppSpacing.md),
            _ModernFilterButton(
              label: 'Appliquer',
              icon: Icons.search,
              onPressed: controller.applyFilters,
              variant: _FilterButtonVariant.primary,
            ),
          ],
        ),
      ],
    );
  }
}

// Composants modernes pour les filtres
class _ModernToggleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _ModernToggleButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  _ModernToggleButtonState createState() => _ModernToggleButtonState();
}

class _ModernToggleButtonState extends State<_ModernToggleButton>
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

class _ModernClearButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernClearButton({required this.onPressed});

  @override
  _ModernClearButtonState createState() => _ModernClearButtonState();
}

class _ModernClearButtonState extends State<_ModernClearButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: GlassContainerVariant.error,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.clear_all,
                    color: AppColors.error,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Effacer',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.error,
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

class _ModernFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final Color color;
  final int count;
  final IconData? icon;

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.color,
    required this.count,
    this.icon,
  });

  @override
  _ModernFilterChipState createState() => _ModernFilterChipState();
}

class _ModernFilterChipState extends State<_ModernFilterChip>
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
            child: GestureDetector(
              onTap: () => widget.onSelected(!widget.isSelected),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? LinearGradient(
                          colors: [
                            widget.color,
                            widget.color.withOpacity(0.8),
                          ],
                        )
                      : null,
                  color:
                      widget.isSelected ? null : widget.color.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.color
                        : widget.color.withOpacity(0.3),
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: widget.isSelected || _isHovered
                      ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.isSelected ? Colors.white : widget.color,
                        size: 16,
                      ),
                      SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      widget.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: widget.isSelected ? Colors.white : widget.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.count > 0) ...[
                      SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.2)
                              : widget.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.count.toString(),
                          style: AppTextStyles.caption.copyWith(
                            color:
                                widget.isSelected ? Colors.white : widget.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModernSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const _ModernSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.warning,
      activeTrackColor: AppColors.warning.withOpacity(0.3),
      inactiveThumbColor: AppColors.gray400,
      inactiveTrackColor: AppColors.gray200,
    );
  }
}

class _ModernDatePicker extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final bool isDark;

  const _ModernDatePicker({
    required this.label,
    required this.controller,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gray700 : AppColors.gray100)
                    .withOpacity(0.5),
                borderRadius: AppRadius.radiusSM,
                border: Border.all(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    size: 16,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      controller.text.isEmpty
                          ? 'Sélectionner'
                          : controller.text,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: controller.text.isEmpty
                            ? (isDark ? AppColors.gray400 : AppColors.gray600)
                            : (isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernAmountField extends StatelessWidget {
  final String label;
  final RxString value;
  final bool isDark;

  const _ModernAmountField({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          TextField(
            onChanged: (val) => value.value = val,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              prefixIcon: Icon(
                Icons.attach_money,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                size: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, dynamic>> items;
  final Function(String?) onChanged;
  final bool isDark;

  const _ModernDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(
                  item['label'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

enum _FilterButtonVariant { primary, secondary }

class _ModernFilterButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final _FilterButtonVariant variant;

  const _ModernFilterButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.variant,
  });

  @override
  _ModernFilterButtonState createState() => _ModernFilterButtonState();
}

class _ModernFilterButtonState extends State<_ModernFilterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
      case _FilterButtonVariant.primary:
        return AppColors.primary;
      case _FilterButtonVariant.secondary:
        return AppColors.gray600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();

    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: widget.variant == _FilterButtonVariant.primary
                  ? GlassContainerVariant.primary
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.variant == _FilterButtonVariant.primary
                        ? Colors.white
                        : variantColor,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _FilterButtonVariant.primary
                          ? Colors.white
                          : variantColor,
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
