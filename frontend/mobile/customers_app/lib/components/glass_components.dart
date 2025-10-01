import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants.dart';

/// 🔮 Conteneur Glass Premium - Alpha Client App
///
/// Composant de base pour tous les éléments glassmorphism
/// avec transparence, blur et élévations sophistiquées.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final double blur;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;
  final bool isInteractive;

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.blur = AppColors.glassBlur,
    this.boxShadow,
    this.border,
    this.onTap,
    this.isInteractive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use the theme-specific glass tokens defined in AppColors
    final defaultColor = isDark ? AppColors.darkGlass : AppColors.lightGlass;

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppRadius.cardRadius,
        border: border ??
            Border.all(
              color: AppColors.glassBorder,
              width: 1.0,
            ),
        boxShadow: boxShadow ?? AppShadows.glass,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppRadius.cardRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: color ?? defaultColor,
              borderRadius: borderRadius ?? AppRadius.cardRadius,
            ),
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null || isInteractive) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isInteractive ? 1.0 : 1.0,
          duration: AppAnimations.fast,
          curve: AppAnimations.buttonPress,
          child: container,
        ),
      );
    }

    return container;
  }
}

/// 🎯 Bouton Premium Alpha
///
/// Bouton sophistiqué avec glassmorphism et micro-interactions
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;

  const PremiumButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.isOutlined = false,
    this.padding,
  }) : super(key: key);

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // removed unused _isPressed; animations handle press visuals

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.buttonPress,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    if (widget.onPressed != null && !widget.isLoading) {
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = widget.backgroundColor ?? AppColors.primary;
    // Fallback to theme-specific on-primary color when no explicit textColor is provided
    final textColor = widget.textColor ??
        (isDark ? AppColors.darkTextOnPrimary : AppColors.lightTextOnPrimary);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? _handleTapDown : null,
            onTapUp: isEnabled ? _handleTapUp : null,
            onTapCancel: isEnabled ? _handleTapCancel : null,
            child: AnimatedOpacity(
              opacity: isEnabled ? 1.0 : 0.6,
              duration: AppAnimations.fast,
              child: Container(
                width: widget.width,
                height: widget.height ?? AppDimensions.buttonHeight,
                padding: widget.padding ?? AppSpacing.buttonPadding,
                decoration: BoxDecoration(
                  gradient: widget.isOutlined
                      ? null
                      : LinearGradient(
                          colors: [
                            backgroundColor,
                            backgroundColor.withOpacity(0.8)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  color: widget.isOutlined ? Colors.transparent : null,
                  borderRadius: AppRadius.buttonRadius,
                  border: widget.isOutlined
                      ? Border.all(
                          color: backgroundColor,
                          width: 2.0,
                        )
                      : null,
                  boxShadow: widget.isOutlined
                      ? null
                      : [
                          BoxShadow(
                            color: backgroundColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.isOutlined ? backgroundColor : textColor,
                        size: AppDimensions.iconSize,
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Make text flexible so it can shrink/ellipsis when space is constrained
                    Flexible(
                      child: Text(
                        widget.text,
                        style: AppTextStyles.buttonMedium.copyWith(
                          color:
                              widget.isOutlined ? backgroundColor : textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🏷️ Badge de Statut Premium
///
/// Badge sophistiqué pour les statuts de commandes
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool isLarge;

  const StatusBadge({
    Key? key,
    required this.text,
    required this.color,
    this.icon,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 12,
        vertical: isLarge ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isLarge ? 12 : 8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color,
              size: isLarge ? 18 : 14,
            ),
            SizedBox(width: isLarge ? 6 : 4),
          ],
          Flexible(
            child: Text(
              text,
              style: (isLarge
                      ? AppTextStyles.labelLarge
                      : AppTextStyles.labelMedium)
                  .copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// 💀 Skeleton Loading Premium
///
/// Composant de skeleton loading avec animation fluide
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppSkeletons.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? AppSkeletons.skeletonRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                AppSkeletons.baseColor,
                AppSkeletons.highlightColor,
                AppSkeletons.baseColor,
              ],
              transform: GradientRotation(_animation.value),
            ),
          ),
        );
      },
    );
  }
}

/// 📱 Card Premium avec Glassmorphism
///
/// Card sophistiquée pour les éléments principaux
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const PremiumCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: padding ?? AppSpacing.cardPadding,
      margin: margin,
      onTap: onTap,
      isInteractive: onTap != null,
      color: backgroundColor,
      boxShadow: boxShadow ?? AppShadows.medium,
      child: child,
    );
  }
}
