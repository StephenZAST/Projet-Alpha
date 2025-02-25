import 'package:flutter/material.dart';
import 'package:admin/constants.dart';

enum AppButtonVariant { primary, secondary, success, error, info, warning }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isDisabled;
  final bool isLoading;
  final bool fullWidth;
  final EdgeInsets? padding;

  AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    String? variant, // Pour la compatibilité avec l'ancien code
    this.leadingIcon,
    this.trailingIcon,
    this.isDisabled = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
  })  : variant = _convertVariant(variant),
        super(key: key);

  static AppButtonVariant _convertVariant(String? variant) {
    switch (variant) {
      case 'primary':
        return AppButtonVariant.primary;
      case 'secondary':
        return AppButtonVariant.secondary;
      case 'success':
        return AppButtonVariant.success;
      case 'error':
        return AppButtonVariant.error;
      case 'info':
        return AppButtonVariant.info;
      default:
        return AppButtonVariant.primary;
    }
  }

  @override
  _AppButtonState createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  Color _getBackgroundColor(BuildContext context) {
    if (widget.isDisabled) return AppColors.gray300;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return Theme.of(context).canvasColor;
      case AppButtonVariant.success:
        return AppColors.success;
      case AppButtonVariant.error:
        return AppColors.error;
      case AppButtonVariant.info:
        return AppColors.info;
      case AppButtonVariant.warning:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (widget.isDisabled) return AppColors.gray500;

    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      default:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final textColor = _getTextColor(context);

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.isLoading)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            ),
          )
        else ...[
          if (widget.leadingIcon != null) ...[
            Icon(widget.leadingIcon, color: textColor, size: 20.0),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            widget.text,
            style: AppTextStyles.buttonMedium.copyWith(color: textColor),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(widget.trailingIcon, color: textColor, size: 20.0),
          ],
        ],
      ],
    );

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: _isPressed && !widget.isDisabled
            ? (widget.variant == AppButtonVariant.primary
                ? AppColors.primaryDark
                : backgroundColor)
            : backgroundColor,
        borderRadius: AppRadius.radiusMD,
        border: widget.variant == AppButtonVariant.secondary
            ? Border.all(color: AppColors.primary, width: 1.0)
            : null,
        boxShadow: _isPressed || widget.isDisabled
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: widget.padding ?? AppSpacing.paddingMD,
      child: buttonContent,
    );

    final gestureDetector = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isDisabled &&
            !widget.isLoading &&
            widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: button,
    );

    return widget.fullWidth
        ? SizedBox(width: double.infinity, child: gestureDetector)
        : gestureDetector;
  }
}
