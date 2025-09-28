import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/orders_controller.dart';
import '../../models/delivery_order.dart';
import '../../widgets/cards/order_card_mobile.dart';
import '../../widgets/shared/glass_container.dart';

/// 🔍 Écran de Recherche Avancée - Alpha Delivery App
///
/// Interface mobile-first pour la recherche avancée des commandes livreur.
/// Fonctionnalités : filtres multiples, recherche par critères, résultats paginés.
class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen>
    with TickerProviderStateMixin {
  
  // ==========================================================================
  // 📦 PROPRIÉTÉS
  // ==========================================================================
  
  late final OrdersController controller;
  late final AnimationController _animationController;
  late final AnimationController _expandController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _expandAnimation;

  bool _isExpanded = false;
  int _activeSection = 0;

  // Contrôleurs de texte
  final _searchController = TextEditingController();
  final _orderIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  // Filtres sélectionnés
  OrderStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _collectionStartDate;
  DateTime? _collectionEndDate;
  DateTime? _deliveryStartDate;
  DateTime? _deliveryEndDate;

  // Résultats de recherche
  final RxList<DeliveryOrder> _searchResults = <DeliveryOrder>[].obs;
  final RxBool _isSearching = false.obs;
  final RxString _searchError = ''.obs;
  final RxInt _totalResults = 0.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OrdersController>();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
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
    _searchController.dispose();
    _orderIdController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // =================================================================
          // 📱 APP BAR
          // =================================================================
          _buildSliverAppBar(isDark),

          // =================================================================
          // 🔍 SECTION DE RECHERCHE
          // =================================================================
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildSearchSection(isDark),
                  ),
                );
              },
            ),
          ),

          // =================================================================
          // 📊 RÉSULTATS DE RECHERCHE
          // =================================================================
          Obx(() {
            if (_isSearching.value) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (_searchError.value.isNotEmpty) {
              return SliverFillRemaining(
                child: _buildErrorState(isDark),
              );
            }

            if (_searchResults.isEmpty && _hasSearched()) {
              return SliverFillRemaining(
                child: _buildEmptyState(isDark),
              );
            }

            if (_searchResults.isNotEmpty) {
              return _buildResultsList(isDark);
            }

            return SliverFillRemaining(
              child: _buildInitialState(isDark),
            );
          }),
        ],
      ),
    );
  }

  /// 📱 App Bar
  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: isDark ? AppColors.gray800 : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Recherche Avancée',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _resetAllFilters,
          icon: const Icon(Icons.clear_all, color: Colors.white),
          tooltip: 'Réinitialiser',
        ),
      ],
    );
  }

  /// 🔍 Section de recherche
  Widget _buildSearchSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec bouton d'expansion
            Row(
              children: [
                Icon(
                  Icons.manage_search,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recherche Intelligente',
                        style: AppTextStyles.h4.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Filtres avancés et recherche précise',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildExpandToggle(isDark),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Recherche rapide
            _buildQuickSearch(isDark),

            const SizedBox(height: AppSpacing.lg),

            // Onglets de filtres
            _buildFilterTabs(isDark),

            const SizedBox(height: AppSpacing.lg),

            // Section expandable
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
                  _buildActiveFilterSection(isDark),
                  const SizedBox(height: AppSpacing.lg),
                  _buildActionButtons(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔄 Bouton d'expansion
  Widget _buildExpandToggle(bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
        if (_isExpanded) {
          _expandController.forward();
        } else {
          _expandController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _expandController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _expandController.value * 3.14159,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.expand_more,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔍 Recherche rapide
  Widget _buildQuickSearch(bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildSearchField(
            controller: _searchController,
            label: 'Recherche globale',
            hint: 'ID, nom client, téléphone...',
            icon: Icons.search,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: _buildSearchField(
            controller: _orderIdController,
            label: 'ID Commande',
            hint: 'ID exact',
            icon: Icons.tag,
            isDark: isDark,
            suffixAction: _buildSearchButton(),
          ),
        ),
      ],
    );
  }

  /// 📑 Onglets de filtres
  Widget _buildFilterTabs(bool isDark) {
    final tabs = [
      {'icon': Icons.filter_list, 'label': 'Filtres', 'color': AppColors.primary},
      {'icon': Icons.date_range, 'label': 'Dates', 'color': AppColors.secondary},
      {'icon': Icons.attach_money, 'label': 'Montants', 'color': AppColors.success},
      {'icon': Icons.person, 'label': 'Client', 'color': AppColors.info},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isActive = _activeSection == index;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _buildFilterTab(
              icon: tab['icon'] as IconData,
              label: tab['label'] as String,
              color: tab['color'] as Color,
              isActive: isActive,
              onTap: () => setState(() => _activeSection = index),
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  /// 📑 Onglet de filtre
  Widget _buildFilterTab({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: isActive ? color.withOpacity(0.4) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? color : (isDark ? AppColors.gray400 : AppColors.gray600),
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isActive ? color : (isDark ? AppColors.gray400 : AppColors.gray600),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Section de filtre active
  Widget _buildActiveFilterSection(bool isDark) {
    switch (_activeSection) {
      case 0:
        return _buildGeneralFilters(isDark);
      case 1:
        return _buildDateFilters(isDark);
      case 2:
        return _buildAmountFilters(isDark);
      case 3:
        return _buildCustomerFilters(isDark);
      default:
        return _buildGeneralFilters(isDark);
    }
  }

  /// 🔧 Filtres généraux
  Widget _buildGeneralFilters(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres Généraux',
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Filtre par statut
        _buildStatusFilter(isDark),
      ],
    );
  }

  /// 📅 Filtres par dates
  Widget _buildDateFilters(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres par Dates',
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Dates de création
        _buildDateRangeGroup(
          'Dates de Création',
          Icons.event,
          AppColors.primary,
          _startDate,
          _endDate,
          (start) => setState(() => _startDate = start),
          (end) => setState(() => _endDate = end),
          isDark,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Dates de collecte
        _buildDateRangeGroup(
          'Dates de Collecte',
          Icons.event_available,
          AppColors.secondary,
          _collectionStartDate,
          _collectionEndDate,
          (start) => setState(() => _collectionStartDate = start),
          (end) => setState(() => _collectionEndDate = end),
          isDark,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Dates de livraison
        _buildDateRangeGroup(
          'Dates de Livraison',
          Icons.local_shipping,
          AppColors.success,
          _deliveryStartDate,
          _deliveryEndDate,
          (start) => setState(() => _deliveryStartDate = start),
          (end) => setState(() => _deliveryEndDate = end),
          isDark,
        ),
      ],
    );
  }

  /// 💰 Filtres par montants
  Widget _buildAmountFilters(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres par Montants',
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        Row(
          children: [
            Expanded(
              child: _buildAmountField(
                controller: _minAmountController,
                label: 'Montant minimum',
                hint: '0',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildAmountField(
                controller: _maxAmountController,
                label: 'Montant maximum',
                hint: '999999',
                isDark: isDark,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        _buildAmountPresets(isDark),
      ],
    );
  }

  /// 👤 Filtres par client
  Widget _buildCustomerFilters(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres par Client',
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        Row(
          children: [
            Expanded(
              child: _buildSearchField(
                controller: _customerNameController,
                label: 'Nom du client',
                hint: 'Nom ou prénom',
                icon: Icons.person,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSearchField(
                controller: _phoneController,
                label: 'Téléphone',
                hint: 'Numéro de téléphone',
                icon: Icons.phone,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔍 Champ de recherche
  Widget _buildSearchField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    Widget? suffixAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
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
            suffixIcon: suffixAction,
            filled: true,
            fillColor: (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusSM,
              borderSide: BorderSide(
                color: (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusSM,
              borderSide: BorderSide(
                color: (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusSM,
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }

  /// 🔘 Bouton de recherche
  Widget _buildSearchButton() {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _performQuickSearch,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  /// 📊 Filtre par statut
  Widget _buildStatusFilter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut de la commande',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: OrderStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return FilterChip(
              label: Text(_getStatusLabel(status)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? status : null;
                });
              },
              backgroundColor: isDark ? AppColors.gray700 : AppColors.gray100,
              selectedColor: _getStatusColor(status).withOpacity(0.2),
              checkmarkColor: _getStatusColor(status),
              labelStyle: TextStyle(
                color: isSelected
                    ? _getStatusColor(status)
                    : (isDark ? AppColors.textLight : AppColors.textPrimary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 📅 Groupe de sélection de dates
  Widget _buildDateRangeGroup(
    String title,
    IconData icon,
    Color color,
    DateTime? startDate,
    DateTime? endDate,
    Function(DateTime?) onStartChanged,
    Function(DateTime?) onEndChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Du',
                  date: startDate,
                  onChanged: onStartChanged,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildDateField(
                  label: 'Au',
                  date: endDate,
                  onChanged: onEndChanged,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📅 Champ de date
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onChanged,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        onChanged(selectedDate);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
          borderRadius: AppRadius.radiusSM,
          border: Border.all(
            color: (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                date != null
                    ? '${date.day}/${date.month}/${date.year}'
                    : label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: date != null
                      ? (isDark ? AppColors.textLight : AppColors.textPrimary)
                      : (isDark ? AppColors.gray400 : AppColors.gray600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💰 Champ de montant
  Widget _buildAmountField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
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
            filled: true,
            fillColor: (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusSM,
              borderSide: BorderSide(
                color: (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusSM,
              borderSide: BorderSide(
                color: (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusSM,
              borderSide: BorderSide(
                color: AppColors.success,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }

  /// 💰 Presets de montants
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
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: presets.map((preset) {
            return GestureDetector(
              onTap: () {
                _minAmountController.text = preset['min']!;
                _maxAmountController.text = preset['max']!;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
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
                ),
                child: Text(
                  preset['label']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 🎯 Boutons d'action
  Widget _buildActionButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bouton Réinitialiser
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray600.withOpacity(0.1),
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: AppColors.gray600.withOpacity(0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _resetAllFilters,
              borderRadius: AppRadius.radiusLG,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: AppColors.gray600,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Réinitialiser',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: AppSpacing.md),
        
        // Bouton Rechercher
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: AppRadius.radiusLG,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _performAdvancedSearch,
              borderRadius: AppRadius.radiusLG,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Rechercher',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 📋 Liste des résultats
  Widget _buildResultsList(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              // En-tête des résultats
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${_totalResults.value} résultat${_totalResults.value > 1 ? 's' : ''} trouvé${_totalResults.value > 1 ? 's' : ''}',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final order = _searchResults[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: OrderCardMobile(
                order: order,
                onTap: () => _navigateToDetails(order),
                onStatusUpdate: (newStatus) =>
                    controller.updateOrderStatus(order.id, newStatus),
              ),
            );
          },
          childCount: _searchResults.length + 1,
        ),
      ),
    );
  }

  /// ❌ État d'erreur
  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Erreur de recherche',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _searchError.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _performAdvancedSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun résultat',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Aucune commande ne correspond à vos critères de recherche',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _resetAllFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Réinitialiser les filtres'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 État initial
  Widget _buildInitialState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search,
              size: 80,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Recherche Avancée',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Utilisez les filtres ci-dessus pour rechercher des commandes spécifiques',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 🎯 MÉTHODES DE RECHERCHE
  // ==========================================================================

  /// Recherche rapide par ID
  void _performQuickSearch() {
    if (_orderIdController.text.isNotEmpty) {
      _performAdvancedSearch();
    }
  }

  /// Recherche avancée
  void _performAdvancedSearch() async {
    _isSearching.value = true;
    _searchError.value = '';

    try {
      // Construire les paramètres de recherche
      final searchParams = <String, dynamic>{};

      // Recherche globale
      if (_searchController.text.isNotEmpty) {
        searchParams['searchTerm'] = _searchController.text;
      }

      // Recherche par ID
      if (_orderIdController.text.isNotEmpty) {
        searchParams['searchTerm'] = _orderIdController.text;
      }

      // Recherche par nom client
      if (_customerNameController.text.isNotEmpty) {
        searchParams['customerName'] = _customerNameController.text;
      }

      // Recherche par téléphone
      if (_phoneController.text.isNotEmpty) {
        searchParams['phone'] = _phoneController.text;
      }

      // Filtre par statut
      if (_selectedStatus != null) {
        searchParams['status'] = _selectedStatus!.name;
      }

      // Filtres par dates
      if (_startDate != null) {
        searchParams['startDate'] = _startDate!.toIso8601String();
      }
      if (_endDate != null) {
        searchParams['endDate'] = _endDate!.toIso8601String();
      }

      // Filtres par montants
      if (_minAmountController.text.isNotEmpty) {
        searchParams['minAmount'] = double.tryParse(_minAmountController.text);
      }
      if (_maxAmountController.text.isNotEmpty) {
        searchParams['maxAmount'] = double.tryParse(_maxAmountController.text);
      }

      // Appel au service de recherche
      final results = await controller.searchOrdersAdvanced(searchParams);
      
      _searchResults.value = results;
      _totalResults.value = results.length;

    } catch (e) {
      _searchError.value = 'Erreur lors de la recherche: ${e.toString()}';
    } finally {
      _isSearching.value = false;
    }
  }

  /// Réinitialiser tous les filtres
  void _resetAllFilters() {
    setState(() {
      _searchController.clear();
      _orderIdController.clear();
      _customerNameController.clear();
      _phoneController.clear();
      _minAmountController.clear();
      _maxAmountController.clear();
      
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _collectionStartDate = null;
      _collectionEndDate = null;
      _deliveryStartDate = null;
      _deliveryEndDate = null;
      
      _activeSection = 0;
      _isExpanded = false;
    });
    
    _expandController.reverse();
    _searchResults.clear();
    _totalResults.value = 0;
    _searchError.value = '';
  }

  /// Vérifier si une recherche a été effectuée
  bool _hasSearched() {
    return _searchController.text.isNotEmpty ||
           _orderIdController.text.isNotEmpty ||
           _customerNameController.text.isNotEmpty ||
           _phoneController.text.isNotEmpty ||
           _selectedStatus != null ||
           _startDate != null ||
           _endDate != null ||
           _minAmountController.text.isNotEmpty ||
           _maxAmountController.text.isNotEmpty;
  }

  /// Navigation vers les détails
  void _navigateToDetails(DeliveryOrder order) {
    Get.toNamed('/orders/details', arguments: {'order': order});
  }

  // ==========================================================================
  // 🎨 MÉTHODES UTILITAIRES
  // ==========================================================================

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.DRAFT:
        return 'Brouillon';
      case OrderStatus.PENDING:
        return 'En attente';
      case OrderStatus.COLLECTING:
        return 'En collecte';
      case OrderStatus.COLLECTED:
        return 'Collectée';
      case OrderStatus.PROCESSING:
        return 'En traitement';
      case OrderStatus.READY:
        return 'Prête';
      case OrderStatus.DELIVERING:
        return 'En livraison';
      case OrderStatus.DELIVERED:
        return 'Livrée';
      case OrderStatus.CANCELLED:
        return 'Annulée';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.DRAFT:
        return AppColors.gray500;
      case OrderStatus.PENDING:
        return AppColors.warning;
      case OrderStatus.COLLECTING:
        return AppColors.info;
      case OrderStatus.COLLECTED:
        return AppColors.accent;
      case OrderStatus.PROCESSING:
        return AppColors.secondary;
      case OrderStatus.READY:
        return AppColors.primary;
      case OrderStatus.DELIVERING:
        return AppColors.info;
      case OrderStatus.DELIVERED:
        return AppColors.success;
      case OrderStatus.CANCELLED:
        return AppColors.error;
    }
  }
}