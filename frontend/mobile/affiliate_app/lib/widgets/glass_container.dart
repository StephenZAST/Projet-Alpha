import 'dart:ui';
import 'package:affiliate_app/models/affiliate_profile.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

/// 🌟 Conteneur Glass Premium - Alpha Affiliate App
///
/// Conteneur avec effet glassmorphism sophistiqué utilisant les tokens de design

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? color;
  final double? blur;
  final double? opacity;
  final List<BoxShadow>? boxShadow;
  final bool hasBorder;
  final bool hasGradient;

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.color,
    this.blur,
    this.opacity,
    this.boxShadow,
    this.hasBorder = true,
    this.hasGradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBlur = blur ?? AppColors.glassBlurSigma;
    
    // Utiliser les tokens de design centralisés
    final backgroundColor = color ?? 
        (isDark ? AppColors.cardBgDark : AppColors.cardBgLight);
    
    final borderColor = isDark 
        ? AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity)
        : AppColors.gray200.withOpacity(AppColors.glassBorderLightOpacity);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? AppRadius.borderRadiusLG,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              gradient: hasGradient ? AppColors.glassGradient : null,
              borderRadius: borderRadius ?? AppRadius.borderRadiusLG,
              border: hasBorder ? Border.all(
                color: borderColor,
                width: 1,
              ) : null,
              boxShadow: boxShadow ?? AppShadows.glassShadow,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: borderRadius ?? AppRadius.borderRadiusLG,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius ?? AppRadius.borderRadiusLG,
                splashColor: AppColors.primary.withOpacity(0.1),
                highlightColor: AppColors.primary.withOpacity(0.05),
                child: Container(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎯 Bouton Glass Premium - Modern Glassmorphism
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isOutlined;
  final bool isElevated;

  const PremiumButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.isOutlined = false,
    this.isElevated = false,
  }) : super(key: key);

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height ?? 52,
            child: ClipRRect(
              borderRadius: AppRadius.borderRadiusLG,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppColors.glassBlurSigma,
                  sigmaY: AppColors.glassBlurSigma,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    // Effet glass moderne sans gradient
                    color: widget.isOutlined
                        ? (isDark 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.15))
                        : buttonColor.withOpacity(widget.isElevated ? 0.9 : 0.85),
                    borderRadius: AppRadius.borderRadiusLG,
                    border: Border.all(
                      color: widget.isOutlined
                          ? buttonColor.withOpacity(0.4)
                          : Colors.white.withOpacity(0.2),
                      width: widget.isOutlined ? 1.5 : 1,
                    ),
                    boxShadow: [
                      // Ombre principale
                      BoxShadow(
                        color: buttonColor.withOpacity(widget.isOutlined ? 0.1 : 0.3),
                        blurRadius: widget.isElevated ? 20 : 12,
                        offset: Offset(0, widget.isElevated ? 8 : 4),
                        spreadRadius: 0,
                      ),
                      // Ombre ambiante
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                      // Glow effect au tap
                      if (_glowAnimation.value > 0)
                        BoxShadow(
                          color: buttonColor.withOpacity(0.4 * _glowAnimation.value),
                          blurRadius: 24,
                          offset: const Offset(0, 0),
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.isLoading ? null : widget.onPressed,
                      onTapDown: _handleTapDown,
                      onTapUp: _handleTapUp,
                      onTapCancel: _handleTapCancel,
                      borderRadius: AppRadius.borderRadiusLG,
                      splashColor: buttonColor.withOpacity(0.2),
                      highlightColor: buttonColor.withOpacity(0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
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
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.isOutlined ? buttonColor : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ] else if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: widget.isOutlined ? buttonColor : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                            ],
                            Flexible(
                              child: Text(
                                widget.text,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: widget.isOutlined ? buttonColor : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
          ),
        );
      },
    );
  }
}

/// 🏷️ Badge de Statut
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool isSmall;

  const StatusBadge({
    Key? key,
    required this.text,
    required this.color,
    this.icon,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
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
              size: isSmall ? 12 : 16,
            ),
            SizedBox(width: isSmall ? 4 : 6),
          ],
          Text(
            text,
            style: (isSmall ? AppTextStyles.overline : AppTextStyles.labelSmall)
                .copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 📊 Carte de Statistique
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(12), // Réduire le padding pour plus d'espace
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculer l'espace disponible pour le contenu
          final availableHeight = constraints.maxHeight - 24; // Padding vertical
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header avec icône et flèche
              SizedBox(
                height: 32, // Hauteur fixe pour l'header
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.textTertiary(context),
                        size: 14,
                      ),
                  ],
                ),
              ),
              
              // Contenu flexible
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Titre
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Valeur principale
                    Text(
                      value,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 18, // Réduire légèrement la taille
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Sous-titre (si présent)
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                        maxLines: 2, // Permettre 2 lignes pour le sous-titre
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 💰 Carte de Transaction
class TransactionCard extends StatelessWidget {
  final CommissionTransaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWithdrawal = transaction.isWithdrawal;
    final color = isWithdrawal ? AppColors.error : AppColors.success;
    final icon = isWithdrawal ? Icons.arrow_upward : Icons.arrow_downward;

    return GlassContainer(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      transaction.typeText,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${isWithdrawal ? '-' : '+'}${formatNumber(transaction.amount)} FCFA',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusBadge(
                      text: transaction.statusText,
                      color: _getStatusColor(transaction.status),
                      isSmall: true,
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.pending:
        return AppColors.warning;
      case WithdrawalStatus.approved:
        return AppColors.success;
      case WithdrawalStatus.rejected:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// 💀 Loader Skeleton
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

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
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
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
            color: AppColors.gray300.withOpacity(_animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
