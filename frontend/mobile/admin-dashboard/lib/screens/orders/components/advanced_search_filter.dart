import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../widgets/shared/glass_container.dart';

class AdvancedSearchFilter extends StatefulWidget {
  @override
  _AdvancedSearchFilterState createState() => _AdvancedSearchFilterState();
}

class _AdvancedSearchFilterState extends State<AdvancedSearchFilter>
    with TickerProviderStateMixin {
  final controller = Get.find<OrdersController>();
  late AnimationController _animationController;
  late AnimationController _expandController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _expandAnimation;

  bool _isExpanded = false;
  int _activeSection = 0;

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

    _expandController = AnimationController(
      duration: Duration(milliseconds: 400),
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
      begin: Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _expandController.dispose();
    super.dispose();
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
            child: GlassSectionContainer(
              title: 'Recherche Avancée',
              subtitle: 'Filtres intelligents et recherche précise',
              icon: Icons.manage_search,
              iconColor: AppColors.accent,
              actions: [
                _ModernSearchToggle(
                  isExpanded: _isExpanded,
                  onToggle: () {
                    setState(() => _isExpanded = !_isExpanded);
                    if (_isExpanded) {
                      _expandController.forward();
                    } else {
                      _expandController.reverse();
                    }
                  },
                ),
                SizedBox(width: AppSpacing.sm),
                _ModernResetButton(
                  onPressed: controller.resetFilters,
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickSearch(isDark),
                  SizedBox(height: AppSpacing.lg),
                  _buildSearchTabs(isDark),
                  SizedBox(height: AppSpacing.lg),
                  AnimatedBuilder(
                    animation: _expandAnimation,
                    builder: (context, child) {
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: _expandAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        _buildActiveSection(isDark),
                        SizedBox(height: AppSpacing.lg),
                        _buildActionButtons(isDark),
                      ],
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

  Widget _buildQuickSearch(bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _ModernSearchField(
            label: 'Recherche globale',
            hint: 'ID, nom client, téléphone, email...',
            icon: Icons.search,
            controller:
                TextEditingController(text: controller.searchQuery.value),
            onChanged: (value) => controller.searchQuery.value = value,
            onClear: () {
              controller.searchQuery.value = '';
              controller.fetchOrders();
            },
            isDark: isDark,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: _ModernSearchField(
            label: 'Recherche par ID',
            hint: 'ID exact de la commande',
            icon: Icons.tag,
            controller:
                TextEditingController(text: controller.orderIdSearch.value),
            onChanged: (value) => controller.orderIdSearch.value = value,
            onClear: controller.resetOrderIdSearch,
            isDark: isDark,
            suffixAction: _ModernSearchButton(
              onPressed: () async {
                if (controller.orderIdSearch.value.isNotEmpty) {
                  await controller
                      .fetchOrderDetails(controller.orderIdSearch.value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTabs(bool isDark) {
    final tabs = [
      {
        'icon': Icons.filter_list,
        'label': 'Filtres',
        'color': AppColors.primary
      },
      {'icon': Icons.date_range, 'label': 'Dates', 'color': AppColors.accent},
      {
        'icon': Icons.attach_money,
        'label': 'Montants',
        'color': AppColors.success
      },
      {
        'icon': Icons.location_on,
        'label': 'Localisation',
        'color': AppColors.info
      },
    ];

    return Row(
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        final isActive = _activeSection == index;

        return Expanded(
          child: _ModernSearchTab(
            icon: tab['icon'] as IconData,
            label: tab['label'] as String,
            color: tab['color'] as Color,
            isActive: isActive,
            onTap: () => setState(() => _activeSection = index),
            isDark: isDark,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveSection(bool isDark) {
    switch (_activeSection) {
      case 0:
        return _buildFiltersSection(isDark);
      case 1:
        return _buildDatesSection(isDark);
      case 2:
        return _buildAmountsSection(isDark);
      case 3:
        return _buildLocationSection(isDark);
      default:
        return _buildFiltersSection(isDark);
    }
  }

  Widget _buildFiltersSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres Généraux',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModernDropdownField(
                label: 'Type de service',
                value: controller.selectedServiceType.value,
                items: [
                  {'value': null, 'label': 'Tous les types'},
                  ...controller.serviceTypes.map((type) => {
                        'value': type.id,
                        'label': type.name,
                      }),
                ],
                onChanged: (value) =>
                    controller.selectedServiceType.value = value,
                icon: Icons.design_services,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModernDropdownField(
                label: 'Méthode de paiement',
                value: controller.selectedPaymentMethod.value,
                items: controller.paymentMethods
                    .map((method) => {
                          'value': method,
                          'label':
                              method == 'CASH' ? 'Espèces' : 'Orange Money',
                        })
                    .toList(),
                onChanged: (value) =>
                    controller.selectedPaymentMethod.value = value,
                icon: Icons.payment,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModernSearchField(
                label: 'Code affilié',
                hint: 'Code de parrainage',
                icon: Icons.code,
                controller:
                    TextEditingController(text: controller.affiliateCode.value),
                onChanged: (value) => controller.affiliateCode.value = value,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModernDropdownField(
                label: 'Type de récurrence',
                value: controller.selectedRecurrenceType.value,
                items: controller.recurrenceTypes
                    .map((type) => {
                          'value': type,
                          'label': type,
                        })
                    .toList(),
                onChanged: (value) =>
                    controller.selectedRecurrenceType.value = value,
                icon: Icons.repeat,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        _ModernSwitchTile(
          title: 'Commandes récurrentes uniquement',
          subtitle: 'Afficher seulement les commandes avec récurrence',
          value: controller.isRecurring.value,
          onChanged: (value) => controller.isRecurring.value = value,
          icon: Icons.repeat,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDatesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres par Dates',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        _buildDateRangeGroup(
          'Dates de Création',
          Icons.event,
          AppColors.primary,
          controller.startDateController,
          controller.endDateController,
          () => controller.pickStartDate(context),
          () => controller.pickEndDate(context),
          isDark,
        ),
        SizedBox(height: AppSpacing.md),
        _buildDateRangeGroup(
          'Dates de Collecte',
          Icons.event_available,
          AppColors.accent,
          controller.collectionDateStartController,
          controller.collectionDateEndController,
          () => controller.pickCollectionDateStart(context),
          () => controller.pickCollectionDateEnd(context),
          isDark,
        ),
        SizedBox(height: AppSpacing.md),
        _buildDateRangeGroup(
          'Dates de Livraison',
          Icons.local_shipping,
          AppColors.success,
          controller.deliveryDateStartController,
          controller.deliveryDateEndController,
          () => controller.pickDeliveryDateStart(context),
          () => controller.pickDeliveryDateEnd(context),
          isDark,
        ),
      ],
    );
  }

  Widget _buildAmountsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres par Montants',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModernAmountField(
                label: 'Montant minimum',
                hint: '0',
                value: controller.minAmount.value,
                onChanged: (value) => controller.minAmount.value = value,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModernAmountField(
                label: 'Montant maximum',
                hint: '999999',
                value: controller.maxAmount.value,
                onChanged: (value) => controller.maxAmount.value = value,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        _buildAmountPresets(isDark),
      ],
    );
  }

  Widget _buildLocationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres par Localisation',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModernSearchField(
                label: 'Ville',
                hint: 'Nom de la ville',
                icon: Icons.location_city,
                controller: TextEditingController(text: controller.city.value),
                onChanged: (value) => controller.city.value = value,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModernSearchField(
                label: 'Code postal',
                hint: 'Code postal',
                icon: Icons.markunread_mailbox,
                controller:
                    TextEditingController(text: controller.postalCode.value),
                onChanged: (value) => controller.postalCode.value = value,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeGroup(
    String title,
    IconData icon,
    Color color,
    TextEditingController startController,
    TextEditingController endController,
    VoidCallback onStartTap,
    VoidCallback onEndTap,
    bool isDark,
  ) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ModernDateField(
                  label: 'Du',
                  controller: startController,
                  onTap: onStartTap,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ModernDateField(
                  label: 'Au',
                  controller: endController,
                  onTap: onEndTap,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPresets(bool isDark) {
    final presets = [
      {'label': '< 10k', 'min': '', 'max': '10000'},
      {'label': '10k - 50k', 'min': '10000', 'max': '50000'},
      {'label': '50k - 100k', 'min': '50000', 'max': '100000'},
      {'label': '> 100k', 'min': '100000', 'max': ''},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presets rapides',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: presets.map((preset) {
            return _ModernPresetChip(
              label: preset['label']!,
              onPressed: () {
                controller.minAmount.value = preset['min']!;
                controller.maxAmount.value = preset['max']!;
              },
              isDark: isDark,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ModernActionButton(
          label: 'Réinitialiser',
          icon: Icons.refresh,
          onPressed: controller.resetFilters,
          variant: _SearchActionVariant.secondary,
        ),
        SizedBox(width: AppSpacing.md),
        _ModernActionButton(
          label: 'Rechercher',
          icon: Icons.search,
          onPressed: controller.applyFilters,
          variant: _SearchActionVariant.primary,
        ),
      ],
    );
  }
}

// Composants modernes pour la recherche avancée
enum _SearchActionVariant { primary, secondary }

class _ModernSearchToggle extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ModernSearchToggle({
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  _ModernSearchToggleState createState() => _ModernSearchToggleState();
}

class _ModernSearchToggleState extends State<_ModernSearchToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
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

    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.sm),
        borderRadius: AppRadius.lg,
        onTap: widget.onToggle,
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: Icon(
                Icons.expand_more,
                color: _isHovered
                    ? AppColors.accent
                    : (isDark ? AppColors.textLight : AppColors.textPrimary),
                size: 20,
              ),
            );
          },
        ),
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
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
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
                    Icons.clear_all,
                    color: AppColors.error,
                    size: 18,
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

class _ModernSearchField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final bool isDark;
  final Widget? suffixAction;

  const _ModernSearchField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.onChanged,
    this.onClear,
    required this.isDark,
    this.suffixAction,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            onChanged: onChanged,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              prefixIcon: Icon(
                icon,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                size: 20,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.text.isNotEmpty && onClear != null)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                        size: 18,
                      ),
                      onPressed: onClear,
                      splashRadius: 16,
                    ),
                  if (suffixAction != null) suffixAction!,
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernSearchButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernSearchButton({required this.onPressed});

  @override
  _ModernSearchButtonState createState() => _ModernSearchButtonState();
}

class _ModernSearchButtonState extends State<_ModernSearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20,
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

class _ModernSearchTab extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _ModernSearchTab({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  _ModernSearchTabState createState() => _ModernSearchTabState();
}

class _ModernSearchTabState extends State<_ModernSearchTab>
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
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  gradient: widget.isActive
                      ? LinearGradient(
                          colors: [
                            widget.color.withOpacity(0.2),
                            widget.color.withOpacity(0.1),
                          ],
                        )
                      : null,
                  color: widget.isActive
                      ? null
                      : (_isHovered
                          ? (widget.isDark
                              ? AppColors.gray700.withOpacity(0.5)
                              : AppColors.gray100.withOpacity(0.8))
                          : Colors.transparent),
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(
                    color: widget.isActive
                        ? widget.color.withOpacity(0.4)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isActive
                          ? widget.color
                          : (widget.isDark
                              ? AppColors.gray400
                              : AppColors.gray600),
                      size: 24,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: widget.isActive
                            ? widget.color
                            : (widget.isDark
                                ? AppColors.gray400
                                : AppColors.gray600),
                        fontWeight:
                            widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Continuons avec les autres composants...
class _ModernDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, dynamic>> items;
  final Function(String?) onChanged;
  final IconData icon;
  final bool isDark;

  const _ModernDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                size: 16,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(
                  item['label'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ModernSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final IconData icon;
  final bool isDark;

  const _ModernSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withOpacity(0.3),
            inactiveThumbColor: AppColors.gray400,
            inactiveTrackColor: AppColors.gray200,
          ),
        ],
      ),
    );
  }
}

class _ModernDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final bool isDark;

  const _ModernDateField({
    required this.label,
    required this.controller,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color:
              (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
          borderRadius: AppRadius.radiusSM,
          border: Border.all(
            color: (isDark ? AppColors.gray600 : AppColors.gray300)
                .withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              size: 16,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                controller.text.isEmpty ? label : controller.text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: controller.text.isEmpty
                      ? (isDark ? AppColors.gray400 : AppColors.gray600)
                      : (isDark ? AppColors.textLight : AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernAmountField extends StatelessWidget {
  final String label;
  final String hint;
  final String value;
  final Function(String) onChanged;
  final bool isDark;

  const _ModernAmountField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          TextField(
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              prefixIcon: Icon(
                Icons.attach_money,
                color: AppColors.success,
                size: 20,
              ),
              suffixText: 'FCFA',
              suffixStyle: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: (isDark ? AppColors.gray600 : AppColors.gray300)
                      .withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
                borderSide: BorderSide(
                  color: AppColors.success,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernPresetChip extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDark;

  const _ModernPresetChip({
    required this.label,
    required this.onPressed,
    required this.isDark,
  });

  @override
  _ModernPresetChipState createState() => _ModernPresetChipState();
}

class _ModernPresetChipState extends State<_ModernPresetChip>
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
            child: GestureDetector(
              onTap: widget.onPressed,
              child: Container(
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
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  widget.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
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

class _ModernActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final _SearchActionVariant variant;

  const _ModernActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.variant,
  });

  @override
  _ModernActionButtonState createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<_ModernActionButton>
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
      case _SearchActionVariant.primary:
        return AppColors.accent;
      case _SearchActionVariant.secondary:
        return AppColors.gray600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();

    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: widget.variant == _SearchActionVariant.primary
                  ? GlassContainerVariant.primary
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.variant == _SearchActionVariant.primary
                        ? Colors.white
                        : variantColor,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _SearchActionVariant.primary
                          ? Colors.white
                          : variantColor,
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
