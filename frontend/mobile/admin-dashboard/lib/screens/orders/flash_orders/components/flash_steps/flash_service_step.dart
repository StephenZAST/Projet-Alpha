import 'package:admin/constants.dart';
import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:admin/models/service_type.dart';
import 'package:admin/models/service.dart';
import 'package:admin/services/service_type_service.dart';
import 'package:admin/services/service_service.dart';
import 'package:admin/services/article_service_couple_service.dart';
import 'package:admin/widgets/shared/glass_container.dart';

class FlashServiceStep extends StatefulWidget {
  final FlashOrderStepperController controller;
  const FlashServiceStep({Key? key, required this.controller})
      : super(key: key);

  @override
  State<FlashServiceStep> createState() => _FlashServiceStepState();
}

class _FlashServiceStepState extends State<FlashServiceStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<ServiceType> serviceTypes = [];
  List<Service> services = [];
  List<Map<String, dynamic>> couples = [];
  ServiceType? selectedServiceType;
  Service? selectedService;
  bool isLoading = false;
  bool isPremium = false;
  double? weight;

  void _onQuantityChanged(String articleId, int value,
      {bool? isPremium, String? serviceId}) {
    widget.controller.updateDraftItemQuantity(
      articleId,
      value,
      isPremium: isPremium ?? this.isPremium,
      serviceId: serviceId,
    );
    widget.controller.syncSelectedItemsFrom(couples: couples);
    setState(() {});
  }

  /// Met à jour le statut premium de tous les items existants dans le draft
  void _updateAllItemsPremiumStatus(bool newPremiumStatus) {
    print(
        '[FlashServiceStep] Updating all items premium status to: $newPremiumStatus');

    // Récupérer tous les items actuels du draft
    final currentItems = widget.controller.draft.value.items;

    // Mettre à jour chaque item avec le nouveau statut premium
    for (final item in currentItems) {
      if (item.quantity > 0) {
        widget.controller.updateDraftItemQuantity(
          item.articleId,
          item.quantity,
          isPremium: newPremiumStatus,
          serviceId: item.serviceId,
        );
      }
    }

    // Synchroniser avec les couples pour mettre à jour les prix
    widget.controller.syncSelectedItemsFrom(couples: couples);

    print(
        '[FlashServiceStep] Updated ${currentItems.length} items with premium status: $newPremiumStatus');
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchServiceTypes();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
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

  Future<void> _fetchServiceTypes() async {
    setState(() => isLoading = true);
    try {
      serviceTypes = await ServiceTypeService.getAllServiceTypes();
    } catch (e) {
      print(
          '[FlashServiceStep] Erreur lors du chargement des types de service: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> _onServiceTypeChanged(ServiceType? type) async {
    setState(() {
      selectedServiceType = type;
      selectedService = null;
      couples = [];
      isPremium = false;
      weight = null;
    });
    widget.controller.setDraftField('serviceTypeId', type?.id);
    if (type != null) {
      setState(() => isLoading = true);
      services = await ServiceService.getAllServices();
      services = services.where((s) => s.serviceTypeId == type.id).toList();
      setState(() => isLoading = false);
    }
  }

  Future<void> _onServiceChanged(Service? service) async {
    setState(() {
      selectedService = service;
      couples = [];
      isPremium = false;
      weight = null;
    });
    widget.controller.setDraftField('serviceId', service?.id);
    if (service != null && selectedServiceType != null) {
      setState(() => isLoading = true);
      couples = await ArticleServiceCoupleService.getCouplesForServiceType(
        serviceTypeId: selectedServiceType!.id,
        serviceId: service.id,
      );
      setState(() => isLoading = false);
    }
  }

  bool get showWeightField => selectedServiceType?.requiresWeight == true;
  bool get showPremiumSwitch => selectedServiceType?.supportsPremium == true;
  String? get pricingType => selectedServiceType?.pricingType;

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
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildServiceContent(isDark),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.design_services,
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
                'Sélection Service',
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Choisissez le service et les articles',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
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
    );
  }

  Widget _buildServiceContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sélection du type de service
        _buildServiceTypeSelection(isDark),
        SizedBox(height: AppSpacing.lg),

        // Sélection du service
        if (selectedServiceType != null) ...[
          _buildServiceSelection(isDark),
          SizedBox(height: AppSpacing.lg),
        ],

        // Options premium et poids
        if (selectedServiceType != null) ...[
          _buildServiceOptions(isDark),
          SizedBox(height: AppSpacing.lg),
        ],

        // Catalogue d'articles
        if (selectedServiceType != null &&
            pricingType == 'FIXED' &&
            couples.isNotEmpty) ...[
          _buildArticlesCatalog(isDark),
        ],
      ],
    );
  }

  Widget _buildServiceTypeSelection(bool isDark) {
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
                Icons.category,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Type de Service',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _ModernDropdown<ServiceType>(
            value: selectedServiceType,
            hint: 'Sélectionner le type de service',
            items: serviceTypes
                .map((type) => _DropdownItem(
                      value: type,
                      label: type.name,
                      subtitle: type.description,
                    ))
                .toList(),
            onChanged: _onServiceTypeChanged,
            isDark: isDark,
          ),
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
                Icons.room_service,
                color: AppColors.info,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Service Spécifique',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _ModernDropdown<Service>(
            value: selectedService,
            hint: 'Sélectionner le service',
            items: services
                .map((service) => _DropdownItem(
                      value: service,
                      label: service.name,
                      subtitle: service.description,
                    ))
                .toList(),
            onChanged: _onServiceChanged,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOptions(bool isDark) {
    return Column(
      children: [
        // Option Premium
        if (showPremiumSwitch) ...[
          GlassContainer(
            variant: GlassContainerVariant.warning,
            padding: EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.lg,
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Premium',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Qualité supérieure et traitement prioritaire',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                _ModernSwitch(
                  value: isPremium,
                  onChanged: (val) {
                    setState(() {
                      isPremium = val;
                      // Mettre à jour tous les items existants avec le nouveau statut premium
                      _updateAllItemsPremiumStatus(val);
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
        ],

        // Champ poids
        if (showWeightField) ...[
          GlassContainer(
            variant: GlassContainerVariant.neutral,
            padding: EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.scale,
                      color: AppColors.info,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Poids du Linge',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                _ModernTextField(
                  initialValue: weight?.toString() ?? '',
                  hint: 'Entrez le poids en kg',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    setState(() {
                      weight = double.tryParse(val);
                    });
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildArticlesCatalog(bool isDark) {
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
                Icons.shopping_bag,
                color: AppColors.success,
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
          SizedBox(height: AppSpacing.md),
          ..._buildModernArticleCatalog(isDark),
        ],
      ),
    );
  }

  List<Widget> _buildModernArticleCatalog(bool isDark) {
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

      // Header de catégorie
      widgets.add(
        Container(
          margin: EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withOpacity(0.2),
                AppColors.success.withOpacity(0.1),
              ],
            ),
            borderRadius: AppRadius.radiusSM,
          ),
          child: Text(
            categoryName ?? catId,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // Articles de la catégorie
      for (var couple in couplesList) {
        widgets.add(_buildArticleCard(couple, isDark));
      }
    });

    // Total estimation
    widgets.add(_buildTotalEstimation(isDark));

    return widgets;
  }

  Widget _buildArticleCard(Map<String, dynamic> couple, bool isDark) {
    final articleId = couple['article_id'];
    final articleName = couple['article_name'] ?? '';
    final articleDescription = couple['article_description'] ?? '';
    final basePrice = double.tryParse(couple['base_price'].toString()) ?? 0.0;
    final premiumPrice =
        double.tryParse(couple['premium_price'].toString()) ?? 0.0;
    final displayPrice =
        showPremiumSwitch && isPremium ? premiumPrice : basePrice;

    final currentQty = widget.controller.draft.value.items
            .firstWhereOrNull((i) => i.articleId == articleId)
            ?.quantity ??
        0;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassContainer(
        variant: currentQty > 0
            ? GlassContainerVariant.success
            : GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.md,
        child: Row(
          children: [
            // Icône article
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentQty > 0
                      ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                      : [AppColors.gray500, AppColors.gray400],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.checkroom,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // Informations article
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    articleName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (articleDescription.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      articleDescription,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      Text(
                        '${displayPrice.toStringAsFixed(0)} FCFA',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (showPremiumSwitch && isPremium) ...[
                        SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: AppRadius.radiusXS,
                          ),
                          child: Text(
                            'PREMIUM',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Contrôles quantité
            _QuantityControls(
              quantity: currentQty,
              onDecrease: () {
                final newQty = (currentQty - 1).clamp(0, 999);
                _onQuantityChanged(
                  articleId,
                  newQty,
                  isPremium: showPremiumSwitch ? isPremium : null,
                  serviceId: couple['service_id'],
                );
              },
              onIncrease: () {
                final newQty = (currentQty + 1).clamp(0, 999);
                _onQuantityChanged(
                  articleId,
                  newQty,
                  isPremium: showPremiumSwitch ? isPremium : null,
                  serviceId: couple['service_id'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalEstimation(bool isDark) {
    int sum = 0;
    for (var item in widget.controller.draft.value.items) {
      final couple =
          couples.firstWhereOrNull((c) => c['article_id'] == item.articleId);
      if (couple != null) {
        final basePrice =
            double.tryParse(couple['base_price'].toString()) ?? 0.0;
        final premiumPrice =
            double.tryParse(couple['premium_price'].toString()) ?? 0.0;
        final displayPrice =
            showPremiumSwitch && isPremium ? premiumPrice : basePrice;
        sum += item.quantity * displayPrice.toInt();
      }
    }

    return Container(
      margin: EdgeInsets.only(top: AppSpacing.lg),
      child: GlassContainer(
        variant: GlassContainerVariant.warning,
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
                    'Estimation Totale',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Prix estimé pour cette sélection',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${sum.toStringAsFixed(0)} FCFA',
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Composants modernes pour l'étape de service
class _DropdownItem<T> {
  final T value;
  final String label;
  final String? subtitle;

  _DropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
  });
}

class _ModernDropdown<T> extends StatefulWidget {
  final T? value;
  final String hint;
  final List<_DropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isDark;

  const _ModernDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  _ModernDropdownState<T> createState() => _ModernDropdownState<T>();
}

class _ModernDropdownState<T> extends State<_ModernDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.gray700 : AppColors.gray100)
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: (widget.isDark ? AppColors.gray600 : AppColors.gray300)
              .withOpacity(0.5),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: widget.value,
          hint: Text(
            widget.hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
          isExpanded: true,
          items: widget.items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: widget.isDark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: widget.isDark
                            ? AppColors.gray400
                            : AppColors.gray600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

class _ModernSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ModernSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  _ModernSwitchState createState() => _ModernSwitchState();
}

class _ModernSwitchState extends State<_ModernSwitch>
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Switch(
              value: widget.value,
              onChanged: widget.onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.success.withOpacity(0.8),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }
}

class _ModernTextField extends StatelessWidget {
  final String initialValue;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _ModernTextField({
    required this.initialValue,
    required this.hint,
    required this.keyboardType,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color:
              (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}

class _QuantityControls extends StatefulWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityControls({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  _QuantityControlsState createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls>
    with TickerProviderStateMixin {
  late AnimationController _decreaseController;
  late AnimationController _increaseController;
  late Animation<double> _decreaseScale;
  late Animation<double> _increaseScale;

  @override
  void initState() {
    super.initState();
    _decreaseController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _increaseController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _decreaseScale =
        Tween<double>(begin: 1.0, end: 0.9).animate(_decreaseController);
    _increaseScale =
        Tween<double>(begin: 1.0, end: 0.9).animate(_increaseController);
  }

  @override
  void dispose() {
    _decreaseController.dispose();
    _increaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton diminuer
        AnimatedBuilder(
          animation: _decreaseScale,
          builder: (context, child) {
            return Transform.scale(
              scale: _decreaseScale.value,
              child: GestureDetector(
                onTapDown: (_) => _decreaseController.forward(),
                onTapUp: (_) {
                  _decreaseController.reverse();
                  widget.onDecrease();
                },
                onTapCancel: () => _decreaseController.reverse(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.quantity > 0
                          ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                          : [AppColors.gray400, AppColors.gray300],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            );
          },
        ),

        // Affichage quantité
        Container(
          width: 40,
          child: Center(
            child: Text(
              '${widget.quantity}',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    widget.quantity > 0 ? AppColors.success : AppColors.gray500,
              ),
            ),
          ),
        ),

        // Bouton augmenter
        AnimatedBuilder(
          animation: _increaseScale,
          builder: (context, child) {
            return Transform.scale(
              scale: _increaseScale.value,
              child: GestureDetector(
                onTapDown: (_) => _increaseController.forward(),
                onTapUp: (_) {
                  _increaseController.reverse();
                  widget.onIncrease();
                },
                onTapCancel: () => _increaseController.reverse(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
