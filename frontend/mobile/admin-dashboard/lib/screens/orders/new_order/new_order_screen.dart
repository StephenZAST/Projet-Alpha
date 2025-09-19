import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../widgets/shared/glass_container.dart';
import 'components/order_stepper.dart';

class NewOrderScreen extends StatefulWidget {
  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen>
    with TickerProviderStateMixin {
  final OrdersController controller = Get.find<OrdersController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildModernAppBar(isDark),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: GlassContainer(
                        variant: GlassContainerVariant.neutral,
                        padding: EdgeInsets.zero,
                        borderRadius: AppRadius.xl,
                        child: OrderStepper(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernAppBar(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          _ModernBackButton(
            onPressed: () => _handleBack(),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvelle Commande',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Créez une commande étape par étape',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          _ModernResetButton(
            onPressed: () => _handleReset(),
          ),
        ],
      ),
    );
  }

  void _handleBack() {
    // Vérifier s'il y a des données non sauvegardées
    if (controller.hasUnsavedChanges()) {
      _showExitConfirmation();
    } else {
      Get.back();
    }
  }

  void _handleReset() {
    _showResetConfirmation();
  }

  void _showExitConfirmation() {
    Get.dialog(
      _ModernConfirmationDialog(
        title: 'Quitter la création ?',
        message: 'Vous avez des modifications non sauvegardées. Voulez-vous vraiment quitter ?',
        confirmText: 'Quitter',
        cancelText: 'Continuer',
        onConfirm: () {
          controller.resetOrderStepper();
          Get.back(); // Ferme le dialog
          Get.back(); // Ferme l'écran
        },
        variant: _ConfirmationVariant.warning,
      ),
    );
  }

  void _showResetConfirmation() {
    Get.dialog(
      _ModernConfirmationDialog(
        title: 'Réinitialiser la commande ?',
        message: 'Cette action effacera toutes les données saisies. Cette action est irréversible.',
        confirmText: 'Réinitialiser',
        cancelText: 'Annuler',
        onConfirm: () {
          controller.resetOrderStepper();
          Get.back(); // Ferme le dialog
          _showSuccessSnackbar('Commande réinitialisée', 'Le formulaire a été remis à zéro');
        },
        variant: _ConfirmationVariant.error,
      ),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.9),
      borderRadius: 16,
      margin: EdgeInsets.all(24),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }
}

// Composants modernes pour l'écran de création
class _ModernBackButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernBackButton({required this.onPressed});

  @override
  _ModernBackButtonState createState() => _ModernBackButtonState();
}

class _ModernBackButtonState extends State<_ModernBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isHovered
                    ? (isDark ? AppColors.gray700 : AppColors.gray100)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.gray600 : AppColors.gray300,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(24),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      size: 24,
                    ),
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

class _ModernResetButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernResetButton({required this.onPressed});

  @override
  _ModernResetButtonState createState() => _ModernResetButtonState();
}

class _ModernResetButtonState extends State<_ModernResetButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: GlassContainerVariant.error,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: AppColors.error,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Reset',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _ConfirmationVariant { warning, error, info }

class _ModernConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final _ConfirmationVariant variant;

  const _ModernConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.variant,
  });

  Color _getVariantColor() {
    switch (variant) {
      case _ConfirmationVariant.warning:
        return AppColors.warning;
      case _ConfirmationVariant.error:
        return AppColors.error;
      case _ConfirmationVariant.info:
        return AppColors.info;
    }
  }

  IconData _getVariantIcon() {
    switch (variant) {
      case _ConfirmationVariant.warning:
        return Icons.warning_amber;
      case _ConfirmationVariant.error:
        return Icons.error_outline;
      case _ConfirmationVariant.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variantColor = _getVariantColor();
    final variantIcon = _getVariantIcon();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        child: GlassContainer(
          variant: GlassContainerVariant.neutral,
          padding: EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: variantColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(
                  variantIcon,
                  color: variantColor,
                  size: 32,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      variant: GlassContainerVariant.neutral,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      borderRadius: AppRadius.lg,
                      onTap: () => Get.back(),
                      child: Center(
                        child: Text(
                          cancelText,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: isDark ? AppColors.textLight : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassContainer(
                      variant: variant == _ConfirmationVariant.error
                          ? GlassContainerVariant.error
                          : GlassContainerVariant.warning,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      borderRadius: AppRadius.lg,
                      onTap: onConfirm,
                      child: Center(
                        child: Text(
                          confirmText,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
