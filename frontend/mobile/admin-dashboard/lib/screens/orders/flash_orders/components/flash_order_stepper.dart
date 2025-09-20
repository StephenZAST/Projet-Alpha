import 'package:admin/screens/orders/flash_orders/components/flash_steps/flash_client_step.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../../controllers/flash_order_stepper_controller.dart';
import '../../../../constants.dart';
import '../../../../widgets/shared/glass_container.dart';
import 'flash_steps/flash_service_step.dart';
import 'flash_steps/flash_address_step.dart';
import 'flash_steps/flash_extra_fields_step.dart';
import 'flash_steps/flash_summary_step.dart';

class FlashOrderStepper extends StatefulWidget {
  @override
  _FlashOrderStepperState createState() => _FlashOrderStepperState();
}

class _FlashOrderStepperState extends State<FlashOrderStepper>
    with TickerProviderStateMixin {
  final FlashOrderStepperController controller =
      Get.find<FlashOrderStepperController>();
  late AnimationController _stepAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _stepFadeAnimation;
  late Animation<Offset> _stepSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  final steps = [
    {
      'title': 'Vérification Client',
      'subtitle': 'Confirmez les informations client',
      'icon': Icons.person_search,
      'color': AppColors.primary,
    },
    {
      'title': 'Sélection Service',
      'subtitle': 'Choisissez le service et les articles',
      'icon': Icons.design_services,
      'color': AppColors.accent,
    },
    {
      'title': 'Adresse de Livraison',
      'subtitle': 'Définissez l\'adresse de livraison',
      'icon': Icons.location_on,
      'color': AppColors.info,
    },
    {
      'title': 'Informations Complémentaires',
      'subtitle': 'Dates, notes et options',
      'icon': Icons.settings,
      'color': AppColors.warning,
    },
    {
      'title': 'Validation Conversion',
      'subtitle': 'Vérifiez et convertissez',
      'icon': Icons.transform,
      'color': AppColors.success,
    },
  ];

  List<Widget> get stepWidgets => [
        FlashClientStep(controller: controller),
        FlashServiceStep(controller: controller),
        FlashAddressStep(controller: controller),
        FlashExtraFieldsStep(controller: controller),
        FlashSummaryStep(controller: controller),
      ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _stepAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _stepFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeOut,
    ));

    _stepSlideAnimation = Tween<Offset>(
      begin: Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    ));

    _headerAnimationController.forward();
    _stepAnimationController.forward();
  }

  @override
  void dispose() {
    _stepAnimationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _animateStepChange() {
    _stepAnimationController.reset();
    _stepAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildConversionHeader(isDark),
        _buildStepIndicator(isDark),
        Expanded(
          child: Obx(() {
            // Animer le changement d'étape
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _animateStepChange();
            });

            return AnimatedBuilder(
              animation: _stepAnimationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _stepFadeAnimation,
                  child: SlideTransition(
                    position: _stepSlideAnimation,
                    child: stepWidgets[controller.currentStep.value],
                  ),
                );
              },
            );
          }),
        ),
        _buildModernStepperControls(isDark),
      ],
    );
  }

  Widget _buildConversionHeader(bool isDark) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerFadeAnimation,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.warning.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning,
                        AppColors.warning.withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.flash_on,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion Flash Order',
                        style: AppTextStyles.h2.copyWith(
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Transformez cette commande flash en commande complète',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                _ModernCloseButton(
                  onPressed: () => _handleClose(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Obx(() {
        final currentStep = controller.currentStep.value;

        return Column(
          children: [
            // Progress bar avec gradient flash
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gray700 : AppColors.gray200),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (currentStep + 1) / steps.length,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.warning, AppColors.success],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withOpacity(0.4),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Step info avec design flash
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        steps[currentStep]['color'] as Color,
                        (steps[currentStep]['color'] as Color).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: (steps[currentStep]['color'] as Color)
                            .withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    steps[currentStep]['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.warning.withOpacity(0.2),
                                  AppColors.warning.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: AppRadius.radiusSM,
                            ),
                            child: Text(
                              'Étape ${currentStep + 1}/${steps.length}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        steps[currentStep]['title'] as String,
                        style: AppTextStyles.h3.copyWith(
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        steps[currentStep]['subtitle'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mini steps indicator avec style flash
                Row(
                  children: List.generate(steps.length, (index) {
                    final isActive = index == currentStep;
                    final isCompleted = index < currentStep;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 16 : 12,
                      height: isActive ? 16 : 12,
                      decoration: BoxDecoration(
                        gradient: isCompleted || isActive
                            ? LinearGradient(
                                colors: [
                                  steps[index]['color'] as Color,
                                  (steps[index]['color'] as Color)
                                      .withOpacity(0.8),
                                ],
                              )
                            : null,
                        color: !isCompleted && !isActive
                            ? (isDark ? AppColors.gray600 : AppColors.gray300)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: (steps[index]['color'] as Color)
                                      .withOpacity(0.5),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 8,
                            )
                          : isActive
                              ? Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: 10,
                                )
                              : null,
                    );
                  }),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildModernStepperControls(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            (isDark ? AppColors.gray800 : AppColors.gray50).withOpacity(0.9),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.gray700 : AppColors.gray200)
                .withOpacity(0.5),
          ),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Obx(() {
        final isLoading = controller.isLoading.value;
        final currentStep = controller.currentStep.value;
        final isLastStep = currentStep >= steps.length - 1;

        return Row(
          children: [
            // Bouton Retour/Annuler
            Expanded(
              child: _ModernFlashStepButton(
                label: currentStep == 0 ? 'Annuler' : 'Retour',
                icon: currentStep == 0 ? Icons.close : Icons.arrow_back,
                variant: _FlashStepButtonVariant.secondary,
                onPressed: isLoading
                    ? null
                    : () {
                        if (currentStep > 0) {
                          controller.previousStep();
                        } else {
                          Get.back();
                        }
                      },
                isLoading: false,
              ),
            ),

            SizedBox(width: AppSpacing.md),

            // Bouton Suivant/Convertir
            Expanded(
              flex: 2,
              child: _ModernFlashStepButton(
                label: isLastStep
                    ? (isLoading
                        ? 'Conversion en cours...'
                        : 'Convertir en Commande')
                    : 'Suivant',
                icon: isLastStep
                    ? (isLoading ? null : Icons.transform)
                    : Icons.arrow_forward,
                variant: _FlashStepButtonVariant.primary,
                onPressed: isLoading
                    ? null
                    : () async {
                        if (isLastStep) {
                          await controller.submitConversion();
                        } else {
                          controller.nextStep();
                        }
                      },
                isLoading: isLoading,
              ),
            ),
          ],
        );
      }),
    );
  }

  void _handleClose() {
    // Vérifier s'il y a des modifications non sauvegardées
    showDialog(
      context: context,
      builder: (_) => _ModernConfirmationDialog(
        title: 'Annuler la conversion ?',
        message:
            'Êtes-vous sûr de vouloir annuler la conversion de cette commande flash ?',
        confirmText: 'Annuler',
        cancelText: 'Continuer',
        onConfirm: () {
          Get.back(); // Ferme le dialog de confirmation
          Get.back(); // Ferme le stepper
        },
        variant: _FlashConfirmationVariant.warning,
      ),
    );
  }
}

// Composants modernes pour le Flash Order Stepper
enum _FlashStepButtonVariant { primary, secondary }

enum _FlashConfirmationVariant { warning, error, info }

class _ModernCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernCloseButton({required this.onPressed});

  @override
  _ModernCloseButtonState createState() => _ModernCloseButtonState();
}

class _ModernCloseButtonState extends State<_ModernCloseButton>
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.error.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.error.withOpacity(0.3)
                      : (isDark ? AppColors.gray600 : AppColors.gray400),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(22),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: _isHovered
                          ? AppColors.error
                          : (isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary),
                      size: 22,
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

class _ModernFlashStepButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final _FlashStepButtonVariant variant;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ModernFlashStepButton({
    required this.label,
    this.icon,
    required this.variant,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  _ModernFlashStepButtonState createState() => _ModernFlashStepButtonState();
}

class _ModernFlashStepButtonState extends State<_ModernFlashStepButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
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
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      onEnter: (_) {
        if (isEnabled) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
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
              variant: widget.variant == _FlashStepButtonVariant.primary
                  ? GlassContainerVariant.warning
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              borderRadius: AppRadius.lg,
              onTap: isEnabled ? widget.onPressed : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.variant == _FlashStepButtonVariant.primary
                              ? Colors.white
                              : AppColors.warning,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.variant == _FlashStepButtonVariant.primary
                          ? Colors.white
                          : (isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary),
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _FlashStepButtonVariant.primary
                          ? Colors.white
                          : (isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary),
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

class _ModernConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final _FlashConfirmationVariant variant;

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
      case _FlashConfirmationVariant.warning:
        return AppColors.warning;
      case _FlashConfirmationVariant.error:
        return AppColors.error;
      case _FlashConfirmationVariant.info:
        return AppColors.info;
    }
  }

  IconData _getVariantIcon() {
    switch (variant) {
      case _FlashConfirmationVariant.warning:
        return Icons.warning_amber;
      case _FlashConfirmationVariant.error:
        return Icons.error_outline;
      case _FlashConfirmationVariant.info:
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
                  gradient: LinearGradient(
                    colors: [
                      variantColor.withOpacity(0.2),
                      variantColor.withOpacity(0.1),
                    ],
                  ),
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
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassContainer(
                      variant: variant == _FlashConfirmationVariant.error
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
