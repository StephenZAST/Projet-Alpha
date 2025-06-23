import 'package:flutter/material.dart';
import 'dart:ui';
import '../../constants.dart';

enum GlassButtonVariant { primary, secondary, warning, success, error, info }

enum GlassButtonSize { small, medium, large }

class GlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final bool isLoading;
  final bool isOutlined;
  final bool fullWidth;
  final GlassButtonSize size;

  const GlassButton({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = GlassButtonVariant.primary,
    this.isLoading = false,
    this.isOutlined = false,
    this.fullWidth = false,
    this.size = GlassButtonSize.medium,
  }) : super(key: key);

  Color _getBaseColor() {
    switch (variant) {
      case GlassButtonVariant.primary:
        return AppColors.primary;
      case GlassButtonVariant.secondary:
        return AppColors.gray500;
      case GlassButtonVariant.warning:
        return AppColors.warning;
      case GlassButtonVariant.success:
        return AppColors.success;
      case GlassButtonVariant.error:
        return AppColors.error;
      case GlassButtonVariant.info:
        return AppColors.info;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case GlassButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case GlassButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case GlassButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  double _getFontSize() {
    switch (size) {
      case GlassButtonSize.small:
        return 12;
      case GlassButtonSize.medium:
        return 14;
      case GlassButtonSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _getBaseColor();
    final padding = _getPadding();
    final fontSize = _getFontSize();
    final isDisabled = onPressed == null || isLoading;
    final textColor = isDisabled ? AppColors.gray400 : baseColor;
    final borderColor =
        isDisabled ? AppColors.gray200 : baseColor.withOpacity(0.5);
    final gradient = !isOutlined && !isDisabled
        ? LinearGradient(
            colors: [
              baseColor.withOpacity(0.2),
              baseColor.withOpacity(0.3),
            ],
          )
        : null;
    final backgroundColor = isDisabled ? AppColors.gray100 : Colors.transparent;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: gradient,
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : onPressed,
                child: Padding(
                  padding: padding,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(baseColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else if (icon != null) ...[
                        Icon(icon, color: textColor, size: fontSize + 6),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        isLoading ? 'Chargement...' : label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
