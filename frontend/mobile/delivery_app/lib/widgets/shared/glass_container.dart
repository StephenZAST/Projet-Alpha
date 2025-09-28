import 'dart:ui';
import 'package:flutter/material.dart';

import '../../constants.dart';

/// 🌟 Conteneur Glassmorphism - Alpha Delivery App
///
/// Widget réutilisable avec effet de verre moderne.
/// Optimisé pour mobile avec transparence et flou.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool enableShadow;

  const GlassContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.borderRadius,
    this.blur = AppColors.glassBlurSigma,
    this.opacity = 0.9,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.onTap,
    this.enableShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? AppRadius.radiusMD;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: _getBackgroundColor(isDark),
                borderRadius: effectiveBorderRadius,
                border: Border.all(
                  color: _getBorderColor(isDark),
                  width: borderWidth,
                ),
                boxShadow: enableShadow ? _getBoxShadow() : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Couleur de fond selon le thème
  Color _getBackgroundColor(bool isDark) {
    if (isDark) {
      return AppColors.cardBgDark.withOpacity(opacity);
    } else {
      return AppColors.cardBgLight.withOpacity(opacity);
    }
  }

  /// Couleur de bordure selon le thème
  Color _getBorderColor(bool isDark) {
    if (borderColor != null) return borderColor!;

    if (isDark) {
      return Colors.white.withOpacity(AppColors.glassBorderDarkOpacity);
    } else {
      return Colors.white.withOpacity(AppColors.glassBorderLightOpacity);
    }
  }

  /// Ombres du conteneur
  List<BoxShadow> _getBoxShadow() {
    if (boxShadow != null) return boxShadow!;
    return AppShadows.glassmorphism;
  }
}

/// 🎨 Variantes prédéfinies du GlassContainer

/// Conteneur glassmorphism pour les cards
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = const EdgeInsets.only(bottom: AppSpacing.sm),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onTap,
      padding: padding,
      margin: margin,
      borderRadius: AppRadius.radiusLG,
      child: child,
    );
  }
}

/// Conteneur glassmorphism pour les boutons
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      width: width,
      height: height ?? MobileDimensions.buttonHeight,
      padding: padding,
      onTap: onPressed,
      borderRadius: AppRadius.radiusMD,
      opacity: 0.8,
      borderColor: backgroundColor?.withOpacity(0.3) ??
          (isDark
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.2)),
      child: Center(child: child),
    );
  }
}

/// Conteneur glassmorphism pour les statistiques
class GlassStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const GlassStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? AppColors.primary;

    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: effectiveColor,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Conteneur glassmorphism pour les notifications/alertes
class GlassAlert extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;

  const GlassAlert({
    Key? key,
    required this.message,
    this.icon,
    this.color,
    this.onDismiss,
    this.margin = const EdgeInsets.all(AppSpacing.md),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? AppColors.info;

    return GlassContainer(
      margin: margin,
      borderColor: effectiveColor.withOpacity(0.3),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: effectiveColor,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}