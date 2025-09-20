import 'package:admin/services/article_service_couple_service.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';
import '../../../../../models/service.dart';
import '../../../../../models/service_type.dart';
import '../../../../../services/api_service.dart';
import 'service_selection_components.dart';
import 'dart:ui';

class ServiceSelectionStep extends StatefulWidget {
  @override
  State<ServiceSelectionStep> createState() => _ServiceSelectionStepState();
}

class _ServiceSelectionStepState extends State<ServiceSelectionStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final controller = Get.find<OrdersController>();
  final api = Get.find<ApiService>();

  List<ServiceType> serviceTypes = [];
  List<Service> services = [];
  List<Map<String, dynamic>> couples = [];

  ServiceType? selectedServiceType;
  Service? selectedService;
  bool isLoading = false;
  bool isPremium = false;
  double? weight;

  // Getters
  bool get showWeightField => selectedServiceType?.requiresWeight == true;
  bool get showPremiumSwitch => selectedServiceType?.supportsPremium == true;
  String? get pricingType => selectedServiceType?.pricingType;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadServiceTypes();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
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

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceTypes() async {
    setState(() => isLoading = true);
    try {
      final response = await api.get('/api/service-types');
      serviceTypes = (response.data['data'] as List)
          .map((json) => ServiceType.fromJson(json))
          .toList();
    } catch (e) {
      _showErrorSnackbar('Erreur lors du chargement des types de service');
    }
    setState(() => isLoading = false);
  }

  Future<void> _onServiceTypeChanged(ServiceType? type) async {
    setState(() {
      selectedServiceType = type;
      selectedService = null;
      couples = [];
      weight = null;
      isPremium = false;

      if (type != null) {
        controller.orderDraft.update((draft) {
          draft?.serviceTypeId = type.id;
        });
        controller.update();
      }
    });

    if (type != null) {
      setState(() => isLoading = true);
      try {
        final response = await api.get('/api/services/all');
        services = (response.data['data'] as List)
            .map((json) => Service.fromJson(json))
            .where((service) => service.serviceTypeId == type.id)
            .toList();
      } catch (e) {
        _showErrorSnackbar('Erreur lors du chargement des services');
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _onServiceChanged(Service? service) async {
    setState(() {
      selectedService = service;
      controller.selectedService.value = service;
      controller.selectedServiceId.value = service?.id;

      if (service != null) {
        controller.setSelectedService(service.id);
      }

      couples = [];
      weight = null;
      isPremium = false;
    });

    if (service != null && selectedServiceType != null) {
      setState(() => isLoading = true);
      try {
        couples = await ArticleServiceCoupleService.getCouplesForServiceType(
          serviceTypeId: selectedServiceType!.id,
          serviceId: selectedService!.id,
        );
      } catch (e) {
        _showErrorSnackbar('Erreur lors du chargement des articles');
      }
      setState(() => isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(isDark),
                  SizedBox(height: AppSpacing.xl),
                  if (isLoading)
                    _buildLoadingState(isDark)
                  else ...[
                    _buildServiceConfiguration(isDark),
                    SizedBox(height: AppSpacing.lg),
                    if (selectedServiceType != null)
                      Expanded(child: _buildServiceContent(isDark)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepHeader(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.accent.withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.room_service,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélection du Service',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Choisissez le type de service et les articles',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          if (selectedService != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Service configuré',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.accent.withOpacity(0.6)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Chargement des services...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceConfiguration(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Configuration du Service',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          ModernServiceTypeDropdown(
            value: selectedServiceType,
            items: serviceTypes,
            onChanged: _onServiceTypeChanged,
            isDark: isDark,
          ),
          SizedBox(height: AppSpacing.md),
          ModernServiceDropdown(
            value: selectedService,
            items: services,
            onChanged: _onServiceChanged,
            isDark: isDark,
            enabled: selectedServiceType != null,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceContent(bool isDark) {
    if (pricingType == 'FIXED' && couples.isNotEmpty) {
      return _buildArticleCatalog(isDark);
    } else if (pricingType == 'WEIGHT_BASED') {
      return _buildWeightBasedService(isDark);
    } else if (pricingType == 'SUBSCRIPTION' || pricingType == 'CUSTOM') {
      return _buildSubscriptionService(isDark);
    } else if (selectedService != null && couples.isEmpty) {
      return _buildEmptyArticles(isDark);
    }

    return _buildServiceTypeInfo(isDark);
  }

  Widget _buildArticleCatalog(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Catalogue d\'Articles',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Options premium
          if (showPremiumSwitch) ...[
            ModernPremiumSwitch(
              value: isPremium,
              onChanged: (value) => setState(() => isPremium = value),
              isDark: isDark,
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          Expanded(
            child: SingleChildScrollView(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildArticlesByCategory(isDark),
                      SizedBox(height: AppSpacing.lg),
                      _buildTotalEstimation(isDark),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildArticlesByCategory(bool isDark) {
    Map<String, List<Map<String, dynamic>>> couplesByCategory = {};

    for (var couple in couples) {
      final catId = couple['article_category_id'] ?? 'Autres';
      couplesByCategory.putIfAbsent(catId, () => []).add(couple);
    }

    List<Widget> widgets = [];

    couplesByCategory.forEach((catId, couplesList) {
      String? categoryName = couplesList.isNotEmpty
          ? couplesList.first['article_category_name']
          : null;

      widgets.add(CategoryHeader(
        name: categoryName ?? catId,
        isDark: isDark,
      ));

      widgets.add(SizedBox(height: AppSpacing.md));

      for (var couple in couplesList) {
        widgets.add(ArticleCard(
          couple: couple,
          quantity: controller.orderDraft.value.items
                  .firstWhereOrNull((i) => i.articleId == couple['article_id'])
                  ?.quantity ??
              0,
          isPremium: isPremium,
          onQuantityChanged: (articleId, quantity) {
            controller.updateDraftItemQuantity(
              articleId,
              quantity,
              isPremium: showPremiumSwitch && isPremium,
            );
          },
          isDark: isDark,
        ));
        widgets.add(SizedBox(height: AppSpacing.sm));
      }

      widgets.add(SizedBox(height: AppSpacing.md));
    });

    return widgets;
  }

  Widget _buildTotalEstimation(bool isDark) {
    final total = controller.estimatedTotalFromCouples(couples);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.02,
          child: GlassContainer(
            variant: GlassContainerVariant.success,
            padding: EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.lg,
            child: Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Estimé',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Prix total des articles sélectionnés',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(0)} FCFA',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightBasedService(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.info,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.scale,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Service au Poids',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Ce service est tarifé au poids. Veuillez indiquer le poids total.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ModernWeightField(
            value: weight,
            onChanged: (value) => setState(() => weight = value),
            isDark: isDark,
          ),
          if (showPremiumSwitch) ...[
            SizedBox(height: AppSpacing.lg),
            ModernPremiumSwitch(
              value: isPremium,
              onChanged: (value) => setState(() => isPremium = value),
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionService(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.warning,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.subscriptions,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Service d\'Abonnement',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Ce service est lié à un abonnement ou un tarif personnalisé.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyArticles(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun article disponible',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Ce service n\'a pas d\'articles configurés',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeInfo(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Sélectionnez un service',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Choisissez un service spécifique pour voir les options disponibles',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
