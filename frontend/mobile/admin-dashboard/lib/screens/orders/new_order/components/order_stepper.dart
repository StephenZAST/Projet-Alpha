import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import '../../../../widgets/shared/glass_container.dart';
import 'steps/client_selection_step.dart';
import 'steps/service_selection_step.dart';
import 'steps/order_summary_step.dart';
import 'steps/order_address_step.dart';
import 'steps/order_extra_fields_step.dart';
import '../../../../widgets/shared/glass_button.dart';
import '../../../../services/article_service_couple_service.dart';

class OrderStepper extends StatefulWidget {
  @override
  _OrderStepperState createState() => _OrderStepperState();
}

class _OrderStepperState extends State<OrderStepper>
    with TickerProviderStateMixin {
  final controller = Get.find<OrdersController>();
  late AnimationController _stepAnimationController;
  late Animation<double> _stepFadeAnimation;
  late Animation<Offset> _stepSlideAnimation;

  final steps = [
    {
      'title': 'Sélection du client',
      'subtitle': 'Choisissez ou créez un client',
      'icon': Icons.person_search,
      'color': AppColors.primary,
    },
    {
      'title': 'Service',
      'subtitle': 'Sélectionnez le service et les articles',
      'icon': Icons.design_services,
      'color': AppColors.accent,
    },
    {
      'title': 'Adresse',
      'subtitle': 'Définissez l\'adresse de livraison',
      'icon': Icons.location_on,
      'color': AppColors.info,
    },
    {
      'title': 'Informations complémentaires',
      'subtitle': 'Dates, notes et options avancées',
      'icon': Icons.settings,
      'color': AppColors.warning,
    },
    {
      'title': 'Récapitulatif',
      'subtitle': 'Vérifiez et validez la commande',
      'icon': Icons.receipt_long,
      'color': AppColors.success,
    },
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

    _stepAnimationController.forward();
  }

  @override
  void dispose() {
    _stepAnimationController.dispose();
    super.dispose();
  }

  void _animateStepChange() {
    _stepAnimationController.reset();
    _stepAnimationController.forward();
  }

  Widget _buildStep(int index) {
    switch (index) {
      case 0:
        return ClientSelectionStep();
      case 1:
        return ServiceSelectionStep();
      case 2:
        return OrderAddressStep();
      case 3:
        return OrderExtraFieldsStep();
      case 4:
        return OrderSummaryStep();
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
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
                    child: _buildStep(controller.currentStep.value),
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

  Widget _buildStepIndicator(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Obx(() {
        final currentStep = controller.currentStep.value;
        
        return Column(
          children: [
            // Progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gray700 : AppColors.gray200),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (currentStep + 1) / steps.length,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            
            // Step info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        steps[currentStep]['color'] as Color,
                        (steps[currentStep]['color'] as Color).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (steps[currentStep]['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    steps[currentStep]['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Étape ${currentStep + 1} sur ${steps.length}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        steps[currentStep]['title'] as String,
                        style: AppTextStyles.h3.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
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
                // Mini steps indicator
                Row(
                  children: List.generate(steps.length, (index) {
                    final isActive = index == currentStep;
                    final isCompleted = index < currentStep;
                    
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      width: isActive ? 12 : 8,
                      height: isActive ? 12 : 8,
                      decoration: BoxDecoration(
                        color: isCompleted || isActive
                            ? (steps[index]['color'] as Color)
                            : (isDark ? AppColors.gray600 : AppColors.gray300),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: (steps[index]['color'] as Color).withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 6,
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
            (isDark ? AppColors.gray800 : AppColors.gray50).withOpacity(0.8),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.gray700 : AppColors.gray200).withOpacity(0.5),
          ),
        ),
      ),
      child: Obx(() {
        final isLoading = controller.isLoading.value;
        final currentStep = controller.currentStep.value;
        final isLastStep = currentStep >= steps.length - 1;
        
        return Row(
          children: [
            // Bouton Retour
            Expanded(
              child: _ModernStepButton(
                label: currentStep == 0 ? 'Annuler' : 'Retour',
                icon: currentStep == 0 ? Icons.close : Icons.arrow_back,
                variant: _StepButtonVariant.secondary,
                onPressed: isLoading ? null : () {
                  if (currentStep > 0) {
                    controller.currentStep.value--;
                  } else {
                    Get.back();
                  }
                },
                isLoading: false,
              ),
            ),
            
            SizedBox(width: AppSpacing.md),
            
            // Bouton Suivant/Créer
            Expanded(
              flex: 2,
              child: _ModernStepButton(
                label: isLastStep 
                    ? (isLoading ? 'Création en cours...' : 'Créer la commande')
                    : 'Suivant',
                icon: isLastStep 
                    ? (isLoading ? null : Icons.check_circle)
                    : Icons.arrow_forward,
                variant: _StepButtonVariant.primary,
                onPressed: isLoading ? null : () async {
                  if (isLastStep) {
                    await _submitOrderWithLoader();
                  } else {
                    await _handleNextStep();
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

  Future<void> _handleNextStep() async {
    final currentStep = controller.currentStep.value;
    
    // Logique spécifique pour chaque étape
    if (currentStep == 2) {
      // Étape adresse - sélectionner une adresse par défaut si nécessaire
      if (controller.selectedAddressId.value == null &&
          controller.clientAddresses.isNotEmpty) {
        final defaultAddress = controller.clientAddresses.first;
        controller.selectAddress(defaultAddress.id);
        controller.setSelectedAddress(defaultAddress.id);
      }
    }
    
    if (currentStep == 2) {
      // Synchronisation avant le récapitulatif
      final items = controller.orderDraft.value.items;
      final serviceTypeId = controller.orderDraft.value.serviceTypeId;
      final serviceId = controller.orderDraft.value.serviceId;
      
      List<Map<String, dynamic>> couples = [];
      if (serviceTypeId != null && serviceId != null) {
        try {
          couples = await ArticleServiceCoupleService.getCouplesForServiceType(
            serviceTypeId: serviceTypeId,
            serviceId: serviceId,
          );
        } catch (e) {
          print('[OrderStepper] Erreur lors du rechargement des couples: $e');
        }
      }
      
      final selectedService = controller.lastSelectedService;
      final selectedServiceType = controller.lastSelectedServiceType;
      final isPremium = controller.lastIsPremium;
      final weight = controller.lastWeight;
      final showPremiumSwitch = controller.lastShowPremiumSwitch;
      final selectedArticles = <String, int>{};
      
      for (final item in items) {
        selectedArticles[item.articleId] = item.quantity;
      }
      
      controller.syncSelectedItemsFrom(
        selectedArticles: selectedArticles,
        couples: couples,
        isPremium: isPremium,
        selectedService: selectedService,
        selectedServiceType: selectedServiceType,
        weight: weight,
        showPremiumSwitch: showPremiumSwitch,
      );
    }
    
    controller.currentStep.value++;
  }

  Future<void> _submitOrderWithLoader() async {
    final orderData = controller.buildOrderPayload();
    print('[OrderStepper] Payload envoyé au backend: $orderData');
    if (orderData['addressId'] == null ||
        (orderData['addressId'] as String).isEmpty ||
        orderData['serviceId'] == null ||
        (orderData['serviceId'] as String).isEmpty ||
        orderData['items'] == null ||
        (orderData['items'] as List).isEmpty) {
      Get.snackbar('Erreur',
          'Veuillez remplir tous les champs obligatoires (service, adresse, articles).');
      return;
    }
    try {
      await controller.createOrder(orderData);
      controller.resetOrderStepper(); // Reset le contexte après succès
      Get.back(); // Ferme le stepper après succès
      Future.delayed(Duration(milliseconds: 100), () {
        controller.fetchOrders(); // Recharge la liste des commandes
      });
    } catch (_) {}
  }
}

// Composants modernes pour le stepper
enum _StepButtonVariant { primary, secondary }

class _ModernStepButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final _StepButtonVariant variant;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ModernStepButton({
    required this.label,
    this.icon,
    required this.variant,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  _ModernStepButtonState createState() => _ModernStepButtonState();
}

class _ModernStepButtonState extends State<_ModernStepButton>
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
              variant: widget.variant == _StepButtonVariant.primary
                  ? GlassContainerVariant.primary
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
                          widget.variant == _StepButtonVariant.primary
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.variant == _StepButtonVariant.primary
                          ? Colors.white
                          : (isDark ? AppColors.textLight : AppColors.textPrimary),
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _StepButtonVariant.primary
                          ? Colors.white
                          : (isDark ? AppColors.textLight : AppColors.textPrimary),
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