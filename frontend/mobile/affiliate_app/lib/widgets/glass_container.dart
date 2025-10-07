import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants.dart';

/// 🌟 Glass Container - Alpha Affiliate App
///
/// Conteneur avec effet glassmorphism premium pour l'application affilié

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Alignment? alignment;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.alignment,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.boxShadow,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? AppRadius.borderRadiusLG,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppColors.glassBlurSigma,
            sigmaY: AppColors.glassBlurSigma,
          ),
          child: Container(
            padding: padding ?? AppSpacing.cardPadding,
            alignment: alignment,
            decoration: BoxDecoration(
              color: color ??
                  (isDark ? AppColors.cardBgDark : AppColors.cardBgLight),
              borderRadius: borderRadius ?? AppRadius.borderRadiusLG,
              border: border ??
                  Border.all(
                    color: isDark
                        ? Colors.white
                            .withOpacity(AppColors.glassBorderDarkOpacity)
                        : Colors.white
                            .withOpacity(AppColors.glassBorderLightOpacity),
                    width: 1,
                  ),
              boxShadow: boxShadow ?? AppShadows.glassShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 🎯 Status Badge - Badge de statut avec effet glass
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    Key? key,
    required this.text,
    required this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(AppColors.iconBoxOpacity),
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(
          color: color.withOpacity(AppColors.badgeBorderOpacity),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 📊 Stat Card - Carte de statistique avec effet glass
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
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(AppColors.iconBoxOpacity),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textTertiary(context),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🎈 Premium Button - Bouton premium avec effet glass uniforme
class PremiumButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final Color? color;
  final bool isLoading;
  final double? width;
  final double? height;

  const PremiumButton({
    Key? key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isOutlined = false,
    this.color,
    this.isLoading = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.isLoading ? null : widget.onPressed,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: widget.width,
              height: widget.height ?? 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      // Glassy, subtle fill so backdrop blur shows through
                      color: widget.isOutlined
                          ? buttonColor.withOpacity(0.10)
                          : buttonColor.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        // Slight colored border when outlined, otherwise soft white border
                        color: widget.isOutlined
                            ? buttonColor.withOpacity(0.36)
                            : Colors.white.withOpacity(0.06),
                        width: widget.isOutlined ? 1.4 : 1,
                      ),
                      boxShadow: [
                        // Soft ambient shadow to lift the button slightly
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.isLoading) ...[
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.isOutlined
                                        ? buttonColor
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ] else if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: widget.isOutlined
                                    ? buttonColor
                                    : Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                            ],
                            Flexible(
                              child: Text(
                                widget.text,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: widget.isOutlined
                                      ? buttonColor
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
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

/// 💳 Transaction Card - Carte de transaction avec effet glass
class TransactionCard extends StatelessWidget {
  final dynamic transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: GlassContainer(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTransactionColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTransactionIcon(),
                  color: _getTransactionColor(),
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
                          _getTransactionTitle(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getTransactionAmount(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _getTransactionColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _getTransactionDate(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTransactionColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTransactionStatus(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _getTransactionColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTransactionColor() {
    // Logique pour déterminer la couleur selon le type de transaction
    return AppColors.success; // Placeholder
  }

  IconData _getTransactionIcon() {
    // Logique pour déterminer l'icône selon le type de transaction
    return Icons.account_balance_wallet; // Placeholder
  }

  String _getTransactionTitle() {
    // Logique pour déterminer le titre selon le type de transaction
    return 'Commission'; // Placeholder
  }

  String _getTransactionAmount() {
    // Logique pour formater le montant
    return '+ 1 500 FCFA'; // Placeholder
  }

  String _getTransactionDate() {
    // Logique pour formater la date
    return 'Aujourd\'hui'; // Placeholder
  }

  String _getTransactionStatus() {
    // Logique pour déterminer le statut
    return 'Confirmé'; // Placeholder
  }
}

/// 💀 Skeleton Loader - Loader squelette pour les états de chargement
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
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.gray700 : AppColors.gray200)
                .withOpacity(_animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
