import 'package:flutter/material.dart';
import '../../constants.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  error,
  success,
  info,
  warning,
  violet,
  pink,
  teal,
  indigo,
  orange,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final EdgeInsets? padding;

  const AppButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Theme.of(context);

    Color getBackgroundColor() {
      switch (variant) {
        case AppButtonVariant.primary:
          return AppColors.primary;
        case AppButtonVariant.secondary:
          return isDark ? AppColors.gray800 : AppColors.gray50;
        case AppButtonVariant.outline:
          return Colors.transparent;
        case AppButtonVariant.error:
          return AppColors.error;
        case AppButtonVariant.success:
          return AppColors.success;
        case AppButtonVariant.info:
          return AppColors.info;
        case AppButtonVariant.warning:
          return AppColors.warning;
        case AppButtonVariant.violet:
          return AppColors.violet;
        case AppButtonVariant.pink:
          return AppColors.pink;
        case AppButtonVariant.teal:
          return AppColors.teal;
        case AppButtonVariant.indigo:
          return AppColors.indigo;
        case AppButtonVariant.orange:
          return AppColors.orange;
      }
    }

    Color getTextColor() {
      switch (variant) {
        case AppButtonVariant.primary:
        case AppButtonVariant.error:
        case AppButtonVariant.success:
        case AppButtonVariant.info:
        case AppButtonVariant.warning:
        case AppButtonVariant.violet:
        case AppButtonVariant.pink:
        case AppButtonVariant.teal:
        case AppButtonVariant.indigo:
        case AppButtonVariant.orange:
          return AppColors.textLight;
        case AppButtonVariant.secondary:
          return isDark ? AppColors.textLight : AppColors.textPrimary;
        case AppButtonVariant.outline:
          return isDark ? AppColors.textLight : AppColors.primary;
      }
    }

    BoxBorder? getBorder() {
      if (variant == AppButtonVariant.outline) {
        return Border.all(
          color: isDark ? AppColors.borderDark : AppColors.primary,
          width: 1,
        );
      }
      return null;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: getBackgroundColor(),
      foregroundColor: getTextColor(),
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
        side: getBorder()?.top ?? BorderSide.none,
      ),
    );

    Widget buildContent() {
      if (isLoading) {
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
            strokeWidth: 2,
          ),
        );
      }

      if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.buttonMedium.copyWith(
                color: getTextColor(),
              ),
            ),
          ],
        );
      }

      return Text(
        label,
        style: AppTextStyles.buttonMedium.copyWith(
          color: getTextColor(),
        ),
      );
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buildContent(),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
