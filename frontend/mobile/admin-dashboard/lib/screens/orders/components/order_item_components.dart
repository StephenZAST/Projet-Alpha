import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';

// Composants modernes pour OrderItemEditDialog
enum _ItemActionVariant { primary, secondary, info, warning, error }

class _ModernCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernCloseButton({required this.onPressed});

  @override
  _ModernCloseButtonState createState() => _ModernCloseButtonState();
}

class _ModernCloseButtonState extends State<_ModernCloseButton>
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.error.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.error.withOpacity(0.3)
                      : (isDark ? AppColors.gray600 : AppColors.gray400),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: _isHovered
                          ? AppColors.error
                          : (isDark ? AppColors.textLight : AppColors.textPrimary),
                      size: 20,
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

class _ModernDropdown<T> extends StatefulWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final ValueChanged<T?> onChanged;
  final bool isDark;
  final bool enabled;

  const _ModernDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    required this.isDark,
    this.enabled = true,
  });

  @override
  _ModernDropdownState<T> createState() => _ModernDropdownState<T>();
}

class _ModernDropdownState<T> extends State<_ModernDropdown<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: (widget.isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
            borderRadius: AppRadius.md,
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.5)
                  : (widget.isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused
                    ? AppColors.primary
                    : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
            items: widget.items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(widget.itemBuilder(item)),
              );
            }).toList(),
            onChanged: widget.enabled ? widget.onChanged : null,
            onTap: () => setState(() => _isFocused = true),
            dropdownColor: widget.isDark ? AppColors.gray800 : Colors.white,
          ),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String name;
  final bool isDark;

  const _CategoryHeader({
    required this.name,
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
          colors: [
            AppColors.accent.withOpacity(0.2),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: AppColors.accent,
            size: 18,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            name,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatefulWidget {
  final Map<String, dynamic> couple;
  final int quantity;
  final bool isPremium;
  final Function(String, int) onQuantityChanged;
  final bool isDark;

  const _ArticleCard({
    required this.couple,
    required this.quantity,
    required this.isPremium,
    required this.onQuantityChanged,
    required this.isDark,
  });

  @override
  _ArticleCardState createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard>
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
      end: 1.02,
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
    final articleId = widget.couple['article_id'];
    final articleName = widget.couple['article_name'] ?? '';
    final articleDescription = widget.couple['article_description'] ?? '';
    final basePrice = double.tryParse(widget.couple['base_price'].toString()) ?? 0.0;
    final premiumPrice = double.tryParse(widget.couple['premium_price'].toString()) ?? 0.0;
    final displayPrice = widget.isPremium ? premiumPrice : basePrice;
    final totalPrice = displayPrice * widget.quantity;

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
              variant: widget.quantity > 0
                  ? GlassContainerVariant.success
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.md,
              child: Row(
                children: [
                  // Icône article
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.quantity > 0
                            ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                            : [AppColors.gray500, AppColors.gray400],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.checkroom,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  
                  // Informations article
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          articleName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (articleDescription.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            articleDescription,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Text(
                              'Prix: ${displayPrice.toStringAsFixed(0)} FCFA',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.quantity > 0) ...[
                              SizedBox(width: AppSpacing.md),
                              Text(
                                'Total: ${totalPrice.toStringAsFixed(0)} FCFA',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Contrôles quantité
                  _QuantityControls(
                    quantity: widget.quantity,
                    onChanged: (newQuantity) {
                      widget.onQuantityChanged(articleId, newQuantity);
                    },
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

class _QuantityControls extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityControls({
    required this.quantity,
    required this.onChanged,
  });

  @override
  _QuantityControlsState createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls>
    with TickerProviderStateMixin {
  late AnimationController _minusController;
  late AnimationController _plusController;
  late Animation<double> _minusScale;
  late Animation<double> _plusScale;

  @override
  void initState() {
    super.initState();
    _minusController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _plusController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    
    _minusScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _minusController, curve: Curves.easeOutCubic),
    );
    _plusScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _plusController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _minusController.dispose();
    _plusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton moins
        GestureDetector(
          onTapDown: (_) => _minusController.forward(),
          onTapUp: (_) {
            _minusController.reverse();
            if (widget.quantity > 0) {
              widget.onChanged(widget.quantity - 1);
            }
          },
          onTapCancel: () => _minusController.reverse(),
          child: AnimatedBuilder(
            animation: _minusScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _minusScale.value,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
        
        // Affichage quantité
        Container(
          width: 60,
          child: Center(
            child: Text(
              '${widget.quantity}',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.quantity > 0 ? AppColors.success : AppColors.gray600,
              ),
            ),
          ),
        ),
        
        // Bouton plus
        GestureDetector(
          onTapDown: (_) => _plusController.forward(),
          onTapUp: (_) {
            _plusController.reverse();
            widget.onChanged(widget.quantity + 1);
          },
          onTapCancel: () => _plusController.reverse(),
          child: AnimatedBuilder(
            animation: _plusScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _plusScale.value,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ModernWeightField extends StatefulWidget {
  final double? value;
  final ValueChanged<double?> onChanged;
  final bool isDark;

  const _ModernWeightField({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  _ModernWeightFieldState createState() => _ModernWeightFieldState();
}

class _ModernWeightFieldState extends State<_ModernWeightField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(_ModernWeightField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Poids (kg)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: (widget.isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
            borderRadius: AppRadius.md,
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.5)
                  : (widget.isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
            ),
          ),
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            onChanged: (value) {
              widget.onChanged(double.tryParse(value));
            },
            onTap: () => setState(() => _isFocused = true),
            onEditingComplete: () => setState(() => _isFocused = false),
            decoration: InputDecoration(
              hintText: 'Ex: 2.5',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              prefixIcon: Icon(
                Icons.scale,
                color: _isFocused
                    ? AppColors.primary
                    : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                size: 20,
              ),
              suffixText: 'kg',
              suffixStyle: AppTextStyles.bodyMedium.copyWith(
                color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModernPremiumSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _ModernPremiumSwitch({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  _ModernPremiumSwitchState createState() => _ModernPremiumSwitchState();
}

class _ModernPremiumSwitchState extends State<_ModernPremiumSwitch>
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: widget.value
                    ? LinearGradient(
                        colors: [
                          AppColors.warning.withOpacity(0.2),
                          AppColors.warning.withOpacity(0.1),
                        ],
                      )
                    : null,
                color: !widget.value
                    ? (widget.isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5)
                    : null,
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: widget.value
                      ? AppColors.warning.withOpacity(0.5)
                      : (widget.isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: widget.value
                          ? LinearGradient(
                              colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                            )
                          : null,
                      color: !widget.value
                          ? (widget.isDark ? AppColors.gray600 : AppColors.gray400)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Premium',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Qualité supérieure et traitement prioritaire',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: widget.value,
                    onChanged: widget.onChanged,
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.warning.withOpacity(0.8),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
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

class _PriceDisplay extends StatelessWidget {
  final double price;
  final bool isDark;

  const _PriceDisplay({
    required this.price,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withOpacity(0.2),
            AppColors.info.withOpacity(0.1),
          ],
        ),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_money,
            color: AppColors.info,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Prix estimé: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${price.toStringAsFixed(0)} FCFA',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.info,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final _ItemActionVariant variant;
  final bool isLoading;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.variant,
    this.isLoading = false,
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
      end: 1.02,
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
      case _ItemActionVariant.primary:
        return AppColors.primary;
      case _ItemActionVariant.secondary:
        return AppColors.gray600;
      case _ItemActionVariant.info:
        return AppColors.info;
      case _ItemActionVariant.warning:
        return AppColors.warning;
      case _ItemActionVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      onEnter: (_) {
        if (isEnabled) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
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
              variant: widget.variant == _ItemActionVariant.primary
                  ? GlassContainerVariant.primary
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              borderRadius: AppRadius.lg,
              onTap: isEnabled ? widget.onPressed : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.variant == _ItemActionVariant.primary
                              ? Colors.white
                              : variantColor,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ] else ...[
                    Icon(
                      widget.icon,
                      color: widget.variant == _ItemActionVariant.primary
                          ? Colors.white
                          : variantColor,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.isLoading ? 'Traitement...' : widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _ItemActionVariant.primary
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