import 'dart:ui';
import 'package:flutter/material.dart';

enum GlassButtonVariant {
  primary,
  secondary,
  warning,
  success,
  error,
  info,
}

enum GlassButtonSize {
  small,
  medium,
  large,
}

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isFullWidth;
  final GlassButtonVariant variant;
  final GlassButtonSize size;
  final bool disabled;

  const GlassButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isFullWidth = false,
    this.variant = GlassButtonVariant.primary,
    this.size = GlassButtonSize.medium,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getColor(variant);
    final height = _getHeight(size);
    final borderRadius = BorderRadius.circular(12);
    final opacity = 0.1;
    final borderOpacity = 0.5;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: color.withOpacity(opacity),
                borderRadius: borderRadius,
                border: Border.all(
                  color: color.withOpacity(borderOpacity),
                  width: isOutlined ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: borderRadius,
                  onTap: disabled ? null : onPressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: color, size: 20),
                        SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: _getFontSize(size),
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

  Color _getColor(GlassButtonVariant variant) {
    switch (variant) {
      case GlassButtonVariant.primary:
        return Colors.blueAccent;
      case GlassButtonVariant.secondary:
        return Colors.grey;
      case GlassButtonVariant.warning:
        return Colors.orange;
      case GlassButtonVariant.success:
        return Colors.green;
      case GlassButtonVariant.error:
        return Colors.redAccent;
      case GlassButtonVariant.info:
        return Colors.cyan;
      default:
        return Colors.blueAccent;
    }
  }

  double _getHeight(GlassButtonSize size) {
    switch (size) {
      case GlassButtonSize.small:
        return 32;
      case GlassButtonSize.medium:
        return 40;
      case GlassButtonSize.large:
        return 48;
      default:
        return 40;
    }
  }

  double _getFontSize(GlassButtonSize size) {
    switch (size) {
      case GlassButtonSize.small:
        return 14;
      case GlassButtonSize.medium:
        return 16;
      case GlassButtonSize.large:
        return 18;
      default:
        return 16;
    }
  }
}
