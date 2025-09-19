import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import '../../../../../models/address.dart';

// Composants modernes pour OrderAddressStep
enum _AddressActionVariant { primary, secondary, info, warning, error }

class _ModernActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final _AddressActionVariant variant;
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
      case _AddressActionVariant.primary:
        return AppColors.primary;
      case _AddressActionVariant.secondary:
        return AppColors.gray600;
      case _AddressActionVariant.info:
        return AppColors.info;
      case _AddressActionVariant.warning:
        return AppColors.warning;
      case _AddressActionVariant.error:
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
              variant: widget.variant == _AddressActionVariant.primary
                  ? GlassContainerVariant.primary
                  : widget.variant == _AddressActionVariant.info
                      ? GlassContainerVariant.info
                      : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.md,
              onTap: isEnabled ? widget.onPressed : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.variant == _AddressActionVariant.primary ||
                                  widget.variant == _AddressActionVariant.info
                              ? Colors.white
                              : variantColor,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ] else ...[
                    Icon(
                      widget.icon,
                      color: widget.variant == _AddressActionVariant.primary ||
                              widget.variant == _AddressActionVariant.info
                          ? Colors.white
                          : variantColor,
                      size: 18,
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.isLoading ? 'Chargement...' : widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _AddressActionVariant.primary ||
                              widget.variant == _AddressActionVariant.info
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

class _AddressCard extends StatefulWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final bool isDark;

  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.isDark,
  });

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<_AddressCard>
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
              variant: widget.isSelected
                  ? GlassContainerVariant.success
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.md,
              child: Row(
                children: [
                  // Icône d'adresse
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isSelected
                            ? [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)]
                            : [AppColors.info, AppColors.info.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isSelected ? Colors.white : AppColors.info)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.address.isDefault ? Icons.home : Icons.location_on,
                        color: widget.isSelected ? AppColors.success : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  
                  // Informations adresse
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.address.label ?? 'Adresse',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: widget.isSelected
                                      ? Colors.white
                                      : (widget.isDark ? AppColors.textLight : AppColors.textPrimary),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (widget.address.isDefault)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : AppColors.success.withOpacity(0.2),
                                  borderRadius: AppRadius.sm,
                                  border: Border.all(
                                    color: widget.isSelected
                                        ? Colors.white.withOpacity(0.3)
                                        : AppColors.success.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Par défaut',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: widget.isSelected
                                        ? Colors.white
                                        : AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.address.fullAddress,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.isSelected
                                ? Colors.white.withOpacity(0.9)
                                : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.address.additionalInfo != null && 
                            widget.address.additionalInfo!.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: widget.isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  widget.address.additionalInfo!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: widget.isSelected
                                        ? Colors.white.withOpacity(0.8)
                                        : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Actions
                  Column(
                    children: [
                      _AddressActionButton(
                        icon: widget.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        onPressed: widget.onSelect,
                        color: widget.isSelected ? Colors.white : AppColors.success,
                        isSelected: widget.isSelected,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _AddressActionButton(
                        icon: Icons.edit,
                        onPressed: widget.onEdit,
                        color: widget.isSelected
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.info,
                        isSelected: widget.isSelected,
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

class _AddressActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final bool isSelected;

  const _AddressActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.isSelected = false,
  });

  @override
  _AddressActionButtonState createState() => _AddressActionButtonState();
}

class _AddressActionButtonState extends State<_AddressActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Colors.white.withOpacity(0.2)
                    : widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddressInfoCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final bool showActions;

  const _AddressInfoCard({
    required this.address,
    this.isSelected = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.1)
            : (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                address.isDefault ? Icons.home : Icons.location_on,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textLight : AppColors.textPrimary),
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  address.label ?? 'Adresse',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textLight : AppColors.textPrimary),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.success.withOpacity(0.2),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Text(
                    'Par défaut',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          
          Text(
            address.fullAddress,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected
                  ? Colors.white.withOpacity(0.9)
                  : (isDark ? AppColors.gray400 : AppColors.gray600),
            ),
          ),
          
          if (address.additionalInfo != null && address.additionalInfo!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : (isDark ? AppColors.gray400 : AppColors.gray600),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    address.additionalInfo!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : (isDark ? AppColors.gray400 : AppColors.gray600),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          if (address.latitude != null && address.longitude != null) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.gps_fixed,
                  size: 16,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.info,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'GPS: ${address.latitude!.toStringAsFixed(6)}, ${address.longitude!.toStringAsFixed(6)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.info,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}