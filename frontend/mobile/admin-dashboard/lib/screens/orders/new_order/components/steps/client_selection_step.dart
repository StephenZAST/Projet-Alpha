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
    
    // S'assurer que les clients sont chargés avec pagination
    print('[ClientSelectionStep] Initialisation - Chargement des clients avec pagination...');
    controller.loadClients(page: 1, limit: controller.clientItemsPerPage.value).then((_) {
      print('[ClientSelectionStep] Clients chargés: ${controller.clients.length}/${controller.clientTotalItems.value}');
    }).catchError((error) {
      print('[ClientSelectionStep] Erreur lors du chargement des clients: $error');
    });
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(isDark),
                  SizedBox(height: AppSpacing.xl),
                  _buildSearchSection(isDark),
                  SizedBox(height: AppSpacing.lg),
                  // Container avec hauteur fixe pour la liste des clients
                  Container(
                    height: 450, // Hauteur augmentée pour inclure la pagination
                    child: _buildClientList(isDark),
                  ),
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
            final selectedId = controller.selectedClientId.value;
            if (selectedId != null && selectedId.isNotEmpty) {
              return Container(
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
                child: ModernSearchField(
                  controller: searchController,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ModernFilterDropdown(
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
                child: ModernActionButton(
                  icon: Icons.refresh,
                  label: 'Réinitialiser',
                  onPressed: () {
                    searchController.clear();
                    setState(() => selectedFilter = 'all');
                    controller.loadClients();
                  },
                  variant: ClientActionVariant.secondary,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ModernActionButton(
                  icon: Icons.search,
                  label: 'Rechercher',
                  onPressed: _performSearch,
                  variant: ClientActionVariant.primary,
                ),
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

      // Amélioration de la logique d'affichage des clients
      final clientsToShow = searchController.text.isEmpty
          ? (controller.filteredClients.isEmpty 
              ? controller.clients  // Tous les clients par défaut
              : controller.filteredClients)  // Résultats de filtre
          : controller.filteredClients;  // Résultats de recherche

      print('[ClientSelectionStep] Clients à afficher: ${clientsToShow.length}');
      print('[ClientSelectionStep] Tous les clients: ${controller.clients.length}');
      print('[ClientSelectionStep] Clients filtrés: ${controller.filteredClients.length}');

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
            // Header avec compteur
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
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
                  Spacer(),
                  if (searchController.text.isEmpty && controller.filteredClients.isEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Tous',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
            // Liste scrollable avec hauteur fixe
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 200, // Hauteur minimum garantie
                  maxHeight: double.infinity,
                ),
                child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(), // Force le scroll
                  itemCount: clientsToShow.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return Obx(() => ClientCard(
                      client: clientsToShow[index],
                      isSelected: controller.selectedClientId.value ==
                          clientsToShow[index].id,
                      onSelect: () {
                        print('[ClientSelectionStep] Sélection du client: ${clientsToShow[index].id}');
                        controller.selectClient(clientsToShow[index].id);
                        controller.setSelectedClient(clientsToShow[index].id);
                        print('[ClientSelectionStep] Client sélectionné dans le contrôleur: ${controller.selectedClientId.value}');
                        
                        // Feedback utilisateur avec snackbar
                        _showClientSelectedFeedback(clientsToShow[index]);
                      },
                      onViewDetails: () => Get.dialog(
                        ClientDetailsDialog(client: clientsToShow[index]),
                      ),
                      isDark: isDark,
                    ));
                  },
                ),
              ),
            ),
            
            // Pagination (seulement si pas de recherche active et plus d'une page)
            if (searchController.text.isEmpty && 
                controller.filteredClients.isEmpty && 
                controller.clientTotalPages.value > 1)
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.gray800.withOpacity(0.5)
                      : AppColors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.md),
                    bottomRight: Radius.circular(AppRadius.md),
                  ),
                ),
                child: _buildClientPagination(isDark),
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
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.6)
                  ],
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
          ModernActionButton(
            icon: Icons.add,
            label: 'Nouveau Client',
            onPressed: () => Get.dialog(CreateClientDialog()),
            variant: ClientActionVariant.info,
          ),
        ],
      ),
    );
  }

  Widget _buildClientPagination(bool isDark) {
    return Obx(() {
      final currentPage = controller.clientCurrentPage.value;
      final totalPages = controller.clientTotalPages.value;
      final itemsPerPage = controller.clientItemsPerPage.value;
      final totalItems = controller.clientTotalItems.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Affichage du nombre d'éléments par page
          Row(
            children: [
              Text(
                'Afficher',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray700 : AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: DropdownButton<int>(
                  value: itemsPerPage,
                  underline: SizedBox.shrink(),
                  items: [5, 10, 15, 20].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        '$value',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setClientItemsPerPage(value);
                    }
                  },
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'clients',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
            ],
          ),

          // Affichage de la plage d'éléments
          Text(
            '${((currentPage - 1) * itemsPerPage) + 1}–${(currentPage * itemsPerPage).clamp(0, totalItems)} sur $totalItems',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),

          // Navigation entre les pages
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: currentPage > 1
                      ? (isDark ? AppColors.textLight : AppColors.textPrimary)
                      : (isDark ? AppColors.gray600 : AppColors.gray400),
                ),
                onPressed: currentPage > 1 ? controller.clientPreviousPage : null,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray700 : AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: DropdownButton<int>(
                  value: currentPage,
                  underline: SizedBox.shrink(),
                  items: List.generate(totalPages, (i) => i + 1)
                      .map((page) => DropdownMenuItem(
                            value: page,
                            child: Text(
                              'Page $page',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (page) {
                    if (page != null) {
                      controller.goToClientPage(page);
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: currentPage < totalPages
                      ? (isDark ? AppColors.textLight : AppColors.textPrimary)
                      : (isDark ? AppColors.gray600 : AppColors.gray400),
                ),
                onPressed: currentPage < totalPages ? controller.clientNextPage : null,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      );
    });
  }

  void _showClientSelectedFeedback(User client) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${client.firstName[0]}${client.lastName[0]}'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Client sélectionné',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${client.firstName} ${client.lastName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.9),
      borderRadius: 16,
      margin: EdgeInsets.all(24),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
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
