import 'package:admin/services/article_service_couple_service.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/order.dart';
import 'package:admin/models/article.dart';
import 'package:admin/models/service.dart';
import 'package:admin/models/service_type.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:get/get.dart';
import 'order_item_components.dart';
import 'dart:ui';

class OrderItemEditDialog extends StatefulWidget {
  final OrderItem? item;
  final List<Article> availableArticles;
  final List<Service> availableServices;
  
  const OrderItemEditDialog({
    Key? key,
    this.item,
    required this.availableArticles,
    required this.availableServices,
  }) : super(key: key);

  @override
  State<OrderItemEditDialog> createState() => _OrderItemEditDialogState();
}

class _OrderItemEditDialogState extends State<OrderItemEditDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // État du dialog
  List<Map<String, dynamic>> couples = [];
  Map<String, int> selectedArticles = {};
  ServiceType? selectedServiceType;
  Service? selectedService;
  Article? selectedArticle;
  bool isLoading = false;
  List<ServiceType> serviceTypes = [];
  List<Service> services = [];
  final api = Get.find<ApiService>();

  double? weight;
  int quantity = 1;
  bool isPremium = false;
  double? price;

  // Getters
  bool get showWeightField => selectedServiceType?.requiresWeight == true;
  bool get showPremiumSwitch => selectedServiceType?.supportsPremium == true;

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

  Future<void> _loadCouples() async {
    if (selectedServiceType == null) return;
    setState(() => isLoading = true);
    try {
      couples = await ArticleServiceCoupleService.getCouplesForServiceType(
        serviceTypeId: selectedServiceType!.id,
        serviceId: selectedService?.id,
      );
    } catch (e) {
      _showErrorSnackbar('Erreur lors du chargement des articles');
    }
    setState(() => isLoading = false);
  }

  Future<void> _onServiceTypeChanged(ServiceType? type) async {
    setState(() {
      selectedServiceType = type;
      selectedService = null;
      selectedArticle = null;
      services = [];
      weight = null;
      couples = [];
      selectedArticles.clear();
      price = null;
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
      selectedArticle = null;
      weight = null;
      couples = [];
      selectedArticles.clear();
      price = null;
    });
    
    if (service != null && selectedServiceType != null) {
      await _loadCouples();
    }
  }

  Future<void> _updatePrice() async {
    if (selectedServiceType == null || selectedService == null) {
      setState(() => price = null);
      return;
    }
    
    setState(() => isLoading = true);
    try {
      Map<String, dynamic> data = {
        'serviceTypeId': selectedServiceType!.id,
        'serviceId': selectedService!.id,
        'isPremium': isPremium,
      };
      
      if (selectedServiceType?.pricingType == 'FIXED') {
        if (selectedArticle == null || quantity < 1) {
          setState(() => price = null);
          return;
        }
        data['articleId'] = selectedArticle!.id;
        data['quantity'] = quantity;
      } else if (selectedServiceType?.pricingType == 'WEIGHT_BASED') {
        if (weight == null || weight! <= 0) {
          setState(() => price = null);
          return;
        }
        data['weight'] = weight;
      }
      
      final response = await api.post('/api/services/calculate-price', data: data);
      price = response.data['data']?['price']?.toDouble();
      
      if (price == 1 && isPremium) {
        _showErrorSnackbar('Prix premium non configuré pour cet article/service.');
      }
    } catch (e) {
      price = null;
      _showErrorSnackbar('Impossible de calculer le prix.');
    }
    setState(() => isLoading = false);
  }

  Future<void> _validateAndSubmit() async {
    if (isLoading) return;
    
    setState(() => isLoading = true);
    
    if (selectedServiceType == null) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Veuillez sélectionner un type de service.');
      return;
    }
    
    if (selectedService == null) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Veuillez sélectionner un service.');
      return;
    }

    List<Map<String, dynamic>> itemsPayload = [];

    if (selectedServiceType?.pricingType == 'FIXED') {
      final articlesToAdd = selectedArticles.entries.where((e) => e.value > 0).toList();
      if (articlesToAdd.isEmpty) {
        setState(() => isLoading = false);
        _showErrorSnackbar('Veuillez sélectionner au moins un article.');
        return;
      }
      
      for (var entry in articlesToAdd) {
        itemsPayload.add({
          'articleId': entry.key,
          'serviceId': selectedService!.id,
          'quantity': entry.value,
          'isPremium': isPremium,
        });
      }
    } else if (selectedServiceType?.pricingType == 'WEIGHT_BASED') {
      if (weight == null || weight! <= 0) {
        setState(() => isLoading = false);
        _showErrorSnackbar('Veuillez renseigner un poids valide (> 0).');
        return;
      }
      
      itemsPayload.add({
        'serviceId': selectedService!.id,
        'weight': weight,
        'isPremium': isPremium,
      });
    }

    if (itemsPayload.isEmpty) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Aucun item à ajouter.');
      return;
    }

    Navigator.of(context).pop(itemsPayload);
    setState(() => isLoading = false);
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
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 900,
                height: MediaQuery.of(context).size.height * 0.9,
                child: GlassContainer(
                  variant: GlassContainerVariant.neutral,
                  padding: EdgeInsets.zero,
                  borderRadius: AppRadius.xl,
                  child: Column(
                    children: [
                      _buildDialogHeader(isDark),
                      if (isLoading)
                        _buildLoadingState(isDark)
                      else
                        Expanded(
                          child: _buildDialogContent(isDark),
                        ),
                      _buildDialogActions(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.xl.topLeft,
          topRight: AppRadius.xl.topRight,
        ),
      ),
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
                      colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
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
                  widget.item == null ? 'Ajouter Articles' : 'Modifier Articles',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestion des articles et services',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          _ModernCloseButton(
            onPressed: () => Get.back(),
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
                  colors: [AppColors.success, AppColors.success.withOpacity(0.6)],
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
              'Chargement des données...',
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

  Widget _buildDialogContent(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section sélection service
          _buildServiceSelection(isDark),
          SizedBox(height: AppSpacing.lg),
          
          // Section contenu dynamique selon le type de service
          if (selectedServiceType != null) ...[
            _buildServiceContent(isDark),
            SizedBox(height: AppSpacing.lg),
          ],
          
          // Section options
          if (selectedServiceType != null)
            _buildOptionsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildServiceSelection(bool isDark) {
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
          
          _ModernDropdown<ServiceType>(
            label: 'Type de service',
            icon: Icons.category,
            value: selectedServiceType,
            items: serviceTypes,
            itemBuilder: (type) => type.name,
            onChanged: _onServiceTypeChanged,
            isDark: isDark,
          ),
          
          SizedBox(height: AppSpacing.md),
          
          _ModernDropdown<Service>(
            label: 'Service spécifique',
            icon: Icons.room_service,
            value: selectedService,
            items: services,
            itemBuilder: (service) => service.name,
            onChanged: _onServiceChanged,
            isDark: isDark,
            enabled: selectedServiceType != null,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceContent(bool isDark) {
    if (selectedServiceType?.pricingType == 'FIXED') {
      return _buildArticleCatalog(isDark);
    } else if (selectedServiceType?.pricingType == 'WEIGHT_BASED') {
      return _buildWeightBasedService(isDark);
    } else if (selectedServiceType?.pricingType == 'SUBSCRIPTION' ||
               selectedServiceType?.pricingType == 'CUSTOM') {
      return _buildSubscriptionService(isDark);
    }
    
    return SizedBox.shrink();
  }

  Widget _buildArticleCatalog(bool isDark) {
    if (couples.isEmpty) {
      return _buildEmptyArticles(isDark);
    }

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
          
          ..._buildArticlesByCategory(isDark),
          
          SizedBox(height: AppSpacing.lg),
          _buildTotalEstimation(isDark),
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
      
      widgets.add(_CategoryHeader(
        name: categoryName ?? _getCategoryName(catId),
        isDark: isDark,
      ));
      
      widgets.add(SizedBox(height: AppSpacing.md));
      
      for (var couple in couplesList) {
        widgets.add(_ArticleCard(
          couple: couple,
          quantity: selectedArticles[couple['article_id']] ?? 0,
          isPremium: isPremium,
          onQuantityChanged: (articleId, quantity) {
            setState(() {
              selectedArticles[articleId] = quantity;
            });
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
    double total = 0;
    
    for (var couple in couples) {
      final qty = selectedArticles[couple['article_id']] ?? 0;
      final basePrice = double.tryParse(couple['base_price'].toString()) ?? 0.0;
      final premiumPrice = double.tryParse(couple['premium_price'].toString()) ?? 0.0;
      final price = isPremium ? premiumPrice : basePrice;
      total += price * qty;
    }

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
            'Ce service est tarifé au poids. Aucun article spécifique à sélectionner.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
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
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Aucun article disponible',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Sélectionnez un service pour voir les articles disponibles',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(bool isDark) {
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
                Icons.tune,
                color: AppColors.warning,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Options du Service',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          
          if (showWeightField) ...[
            _ModernWeightField(
              value: weight,
              onChanged: (value) {
                setState(() => weight = value);
                _updatePrice();
              },
              isDark: isDark,
            ),
            SizedBox(height: AppSpacing.md),
          ],
          
          if (showPremiumSwitch) ...[
            _ModernPremiumSwitch(
              value: isPremium,
              onChanged: (value) {
                setState(() => isPremium = value);
                _updatePrice();
              },
              isDark: isDark,
            ),
            SizedBox(height: AppSpacing.md),
          ],
          
          if (price != null)
            _PriceDisplay(
              price: price!,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildDialogActions(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModernActionButton(
              icon: Icons.close,
              label: 'Annuler',
              onPressed: () => Get.back(),
              variant: _ItemActionVariant.secondary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ModernActionButton(
              icon: widget.item == null ? Icons.add : Icons.save,
              label: widget.item == null ? 'Ajouter' : 'Enregistrer',
              onPressed: _validateAndSubmit,
              variant: _ItemActionVariant.primary,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String catId) {
    return catId == 'Autres' ? 'Autres' : catId;
  }
}