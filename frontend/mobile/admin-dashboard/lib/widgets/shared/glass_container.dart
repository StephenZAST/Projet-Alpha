import 'package:flutter/material.dart';
import 'dart:ui';
import '../../constants.dart';

enum GlassContainerVariant {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  neutral
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final GlassContainerVariant variant;
  final double borderRadius;
  final bool hasBorder;
  final bool hasShadow;
  final double blurIntensity;
  final VoidCallback? onTap;

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.variant = GlassContainerVariant.neutral,
    this.borderRadius = 12.0,
    this.hasBorder = true,
    this.hasShadow = true,
    this.blurIntensity = AppColors.glassBlurSigma,
    this.onTap,
  }) : super(key: key);

  Color _getBaseColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (variant) {
      case GlassContainerVariant.primary:
        return AppColors.primary;
      case GlassContainerVariant.secondary:
        return AppColors.gray500;
      case GlassContainerVariant.success:
        return AppColors.success;
      case GlassContainerVariant.warning:
        return AppColors.warning;
      case GlassContainerVariant.error:
        return AppColors.error;
      case GlassContainerVariant.info:
        return AppColors.info;
      case GlassContainerVariant.neutral:
      default:
        return isDark ? AppColors.gray700 : AppColors.gray200;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = _getBaseColor(context);

    if (variant == GlassContainerVariant.neutral) {
      return isDark ? AppColors.cardBgDark : AppColors.cardBgLight;
    }

    return baseColor.withOpacity(0.1);
  }

  Color _getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = _getBaseColor(context);

    if (variant == GlassContainerVariant.neutral) {
      return isDark
          ? AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity)
          : AppColors.gray200.withOpacity(AppColors.glassBorderLightOpacity);
    }

    return baseColor.withOpacity(0.3);
  }

  List<BoxShadow> _getShadows(BuildContext context) {
    if (!hasShadow) return [];

    final baseColor = _getBaseColor(context);

    return [
      BoxShadow(
        color: baseColor.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: baseColor.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final borderColor = _getBorderColor(context);
    final shadows = _getShadows(context);

    // Match the Affiliate card pattern: ClipRRect -> BackdropFilter -> Container
    // with BoxDecoration (background, border, boxShadow). This makes
    // `GlassContainer` visually identical to the manual cards used in
    // `affiliate_stats_grid.dart` while still using centralized tokens.
    Widget container = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurIntensity,
          sigmaY: blurIntensity,
        ),
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding ?? EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: backgroundColor,
            border: hasBorder
                ? Border.all(
                    color: borderColor,
                    width: 1,
                  )
                : null,
            boxShadow: hasShadow ? shadows : [],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: container,
        ),
      );
    }

    return container;
  }
}

/// Version spécialisée pour les cartes de statistiques - Style cohérent avec affiliate_stats_grid
class GlassStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const GlassStatsCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.gray800.withOpacity(0.8)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isDark
                        ? AppColors.gray700.withOpacity(0.3)
                        : AppColors.gray200.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: AppRadius.radiusSM,
                            ),
                            child: Icon(
                              icon,
                              color: iconColor,
                              size: 24,
                            ),
                          ),
                          if (subtitle != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.1),
                                borderRadius: AppRadius.radiusXS,
                              ),
                              child: Text(
                                subtitle!,
                                style: AppTextStyles.caption.copyWith(
                                  color: iconColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        value,
                        style: AppTextStyles.h2.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
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

/// Version spécialisée pour les sections avec header
class GlassSectionContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;

  const GlassSectionContainer({
    Key? key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.headerBgDark : AppColors.headerBgLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? AppColors.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h4.copyWith(
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.gray300
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Version spécialisée pour les alertes/notifications
class GlassAlertContainer extends StatelessWidget {
  final String message;
  final GlassContainerVariant variant;
  final IconData? icon;
  final VoidCallback? onDismiss;
  final List<Widget>? actions;

  const GlassAlertContainer({
    Key? key,
    required this.message,
    this.variant = GlassContainerVariant.info,
    this.icon,
    this.onDismiss,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color getVariantColor() {
      switch (variant) {
        case GlassContainerVariant.success:
          return AppColors.success;
        case GlassContainerVariant.warning:
          return AppColors.warning;
        case GlassContainerVariant.error:
          return AppColors.error;
        case GlassContainerVariant.info:
        default:
          return AppColors.info;
      }
    }

    IconData getVariantIcon() {
      switch (variant) {
        case GlassContainerVariant.success:
          return Icons.check_circle_outline;
        case GlassContainerVariant.warning:
          return Icons.warning_outlined;
        case GlassContainerVariant.error:
          return Icons.error_outline;
        case GlassContainerVariant.info:
        default:
          return Icons.info_outline;
      }
    }

    final variantColor = getVariantColor();
    final variantIcon = icon ?? getVariantIcon();

    return GlassContainer(
      variant: variant,
      child: Row(
        children: [
          Icon(
            variantIcon,
            color: variantColor,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          if (actions != null) ...[
            SizedBox(width: AppSpacing.sm),
            ...actions!,
          ],
          if (onDismiss != null) ...[
            SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
