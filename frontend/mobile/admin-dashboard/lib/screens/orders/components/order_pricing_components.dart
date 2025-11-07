import 'package:flutter/material.dart';
import '../../../constants.dart';

/// Énumération des variantes de bouton pricing
enum PricingButtonVariant { primary, secondary, success, error }

/// Ligne d'affichage d'un prix avec label et valeur
/// 
/// Composant réutilisable pour afficher les prix dans la section pricing.
/// Supporte les états highlight (prix manuel) et isDiscount (remises).
class PricingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool highlight;
  final bool isDiscount;

  const PricingRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.gray700,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDiscount
                ? AppColors.error
                : highlight
                    ? AppColors.primary
                    : (isDark ? AppColors.textLight : AppColors.textPrimary),
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// Bouton d'action pour les opérations de pricing
/// 
/// Bouton animé avec support des variantes (primary, secondary, success, error).
/// Affiche un spinner lors du chargement et désactive le bouton.
class PricingActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final PricingButtonVariant variant;

  const PricingActionButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.variant = PricingButtonVariant.primary,
  });

  @override
  PricingActionButtonState createState() => PricingActionButtonState();
}

class PricingActionButtonState extends State<PricingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
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
      case PricingButtonVariant.primary:
        return AppColors.primary;
      case PricingButtonVariant.secondary:
        return AppColors.gray600;
      case PricingButtonVariant.success:
        return AppColors.success;
      case PricingButtonVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();
    final isDisabled = widget.isLoading;

    return MouseRegion(
      onEnter: isDisabled ? null : (_) => _controller.forward(),
      onExit: isDisabled ? null : (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton.icon(
              onPressed: isDisabled ? null : widget.onPressed,
              icon: widget.isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          variantColor,
                        ),
                      ),
                    )
                  : Icon(widget.icon),
              label: Text(widget.label),
              style: ElevatedButton.styleFrom(
                backgroundColor: variantColor.withOpacity(0.15),
                foregroundColor: variantColor,
                disabledBackgroundColor:
                    AppColors.gray400.withOpacity(0.15),
                disabledForegroundColor: AppColors.gray400,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: variantColor.withOpacity(0.3),
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
