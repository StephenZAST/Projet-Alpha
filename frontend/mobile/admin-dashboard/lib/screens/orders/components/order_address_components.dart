import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';

// Composants modernes pour OrderAddressDialog
enum _AddressActionVariant { primary, secondary, info, warning, error }

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

class _ModernTabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;
  final bool isDark;

  const _ModernTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
    required this.isDark,
  });

  @override
  _ModernTabButtonState createState() => _ModernTabButtonState();
}

class _ModernTabButtonState extends State<_ModernTabButton>
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
            child: GestureDetector(
              onTap: widget.onPressed,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        )
                      : null,
                  color: !widget.isSelected
                      ? (widget.isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5)
                      : null,
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.primary.withOpacity(0.5)
                        : (widget.isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? Colors.white
                          : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                      size: 18,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      widget.label,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: widget.isSelected
                            ? Colors.white
                            : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                          widget.variant == _AddressActionVariant.primary
                              ? Colors.white
                              : variantColor,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ] else ...[
                    Icon(
                      widget.icon,
                      color: widget.variant == _AddressActionVariant.primary
                          ? Colors.white
                          : variantColor,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.isLoading ? 'Enregistrement...' : widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _AddressActionVariant.primary
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

class _ModernAddressField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String value;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final String? hint;
  final bool isRequired;

  const _ModernAddressField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.isDark,
    this.hint,
    this.isRequired = false,
  });

  @override
  _ModernAddressFieldState createState() => _ModernAddressFieldState();
}

class _ModernAddressFieldState extends State<_ModernAddressField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_ModernAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
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
        Row(
          children: [
            Text(
              widget.label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.isRequired) ...[
              SizedBox(width: AppSpacing.xs),
              Text(
                '*',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: (widget.isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
            borderRadius: AppRadius.md,
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.5)
                  : widget.isRequired && widget.value.isEmpty
                      ? AppColors.error.withOpacity(0.5)
                      : (widget.isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
            ),
          ),
          child: TextFormField(
            controller: _controller,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            onChanged: widget.onChanged,
            onTap: () => setState(() => _isFocused = true),
            onEditingComplete: () => setState(() => _isFocused = false),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
              ),
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
          ),
        ),
      ],
    );
  }
}

class _GPSInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _GPSInfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}