import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';
import '../../../../../models/user.dart';
import '../create_client_dialog.dart';
import '../client_details_dialog.dart';
import 'client_selection_components.dart';
import 'dart:ui';

class ClientSelectionStep extends StatefulWidget {
  @override
  State<ClientSelectionStep> createState() => _ClientSelectionStepState();
}

class _ClientSelectionStepState extends State<ClientSelectionStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _searchController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchPulseAnimation;

  final searchController = TextEditingController();
  String selectedFilter = 'all';
  late final OrdersController controller;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    controller = Get.find<OrdersController>();
    controller.loadClients();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _searchController = AnimationController(
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

    _searchPulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _searchController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    searchController.dispose();
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
            child: Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(isDark),
                  SizedBox(height: AppSpacing.xl),
                  _buildSearchSection(isDark),
                  SizedBox(height: AppSpacing.lg),
                  Expanded(child: _buildClientList(isDark)),
                  SizedBox(height: AppSpacing.lg),
                  _buildCreateClientSection(isDark),
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
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.person_search,
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
                  'Sélection du Client',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Choisissez le client pour cette commande',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.selectedClientId.value.isNotEmpty) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                  ),
                  borderRadius: AppRadius.md,
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
                      'Client sélectionné',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSearchSection(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _searchPulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _searchPulseAnimation.value,
                    child: Icon(
                      Icons.search,
                      color: AppColors.info,
                      size: 20,
                    ),
                  );
                },
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Recherche de Client',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _ModernSearchField(
                  controller: searchController,
                  onChanged: (value) => _performSearch(),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ModernFilterDropdown(
                  value: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value;
                      searchController.clear();
                      if (value == 'all') {
                        controller.loadClients();
                      }
                    });
                  },
                  isDark: isDark,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.md),
          
          Row(
            children: [
              Expanded(
                child: _ModernActionButton(
                  icon: Icons.refresh,
                  label: 'Réinitialiser',
                  onPressed: () {
                    searchController.clear();
                    setState(() => selectedFilter = 'all');
                    controller.loadClients();
                  },
                  variant: _ClientActionVariant.secondary,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Obx(() => _ModernActionButton(
                  icon: Icons.search,
                  label: 'Rechercher',
                  onPressed: _performSearch,
                  variant: _ClientActionVariant.primary,
                  isLoading: controller.isLoadingClients.value,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientList(bool isDark) {
    return Obx(() {
      if (controller.isLoadingClients.value) {
        return _buildLoadingState(isDark);
      }

      final clientsToShow = controller.filteredClients.isEmpty && searchController.text.isEmpty
          ? controller.clients
          : controller.filteredClients;

      if (clientsToShow.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: AppColors.accent,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Clients Disponibles (${clientsToShow.length})',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            
            Expanded(
              child: ListView.separated(
                itemCount: clientsToShow.length,
                separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return _ClientCard(
                    client: clientsToShow[index],
                    isSelected: controller.selectedClientId.value == clientsToShow[index].id,
                    onSelect: () {
                      controller.selectClient(clientsToShow[index].id);
                      controller.setSelectedClient(clientsToShow[index].id);
                    },
                    onViewDetails: () => Get.dialog(
                      ClientDetailsDialog(client: clientsToShow[index]),
                    ),
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingState(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)],
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
              'Chargement des clients...',
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

  Widget _buildEmptyState(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun client trouvé',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              searchController.text.isNotEmpty
                  ? 'Essayez avec d\'autres critères de recherche'
                  : 'Créez un nouveau client pour commencer',
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

  Widget _buildCreateClientSection(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.info,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_add,
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
                  'Client introuvable ?',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Créez un nouveau client rapidement',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          _ModernActionButton(
            icon: Icons.add,
            label: 'Nouveau Client',
            onPressed: () => Get.dialog(CreateClientDialog()),
            variant: _ClientActionVariant.info,
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    final query = searchController.text.trim();
    if (selectedFilter == 'all') {
      controller.loadClients();
    } else if (query.isNotEmpty) {
      controller.searchClients(query, selectedFilter);
    } else if (query.isEmpty && selectedFilter != 'all') {
      _showGlassySnackbar(
        message: 'Veuillez entrer un terme de recherche',
        icon: Icons.warning,
        color: AppColors.warning,
      );
    }
  }

  void _showGlassySnackbar({
    required String message,
    IconData icon = Icons.warning,
    Color? color,
    Duration? duration,
  }) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
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
      backgroundColor: (color ?? AppColors.warning).withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: duration ?? Duration(seconds: 3),
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
}