import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../services/offer_service.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import 'components/offer_form_dialog.dart';
import 'components/offer_stats_grid.dart';
import 'components/offer_table.dart';
import 'components/offer_filters.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> offers = [];
  List<Map<String, dynamic>> filteredOffers = [];
  bool isLoading = false;
  String searchQuery = '';
  String? selectedStatus;
  String? selectedType;
  late TabController _tabController;

  // Statistiques
  int totalOffers = 0;
  int activeOffers = 0;
  int expiredOffers = 0;
  double totalDiscountValue = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOffers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    setState(() => isLoading = true);
    try {
      final result = await OfferService.getAllOffersAsMap();
      setState(() {
        offers = result;
        _updateStatistics();
        _applyFilters();
      });
    } catch (e) {
      _showErrorSnackbar('Erreur chargement des offres: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _updateStatistics() {
    totalOffers = offers.length;
    activeOffers = offers.where((o) => o['isActive'] == true).length;
    expiredOffers = offers.where((o) => _isOfferExpired(o)).length;
    totalDiscountValue = offers
        .where((o) => o['isActive'] == true)
        .fold(0.0, (sum, o) => sum + (o['discountValue'] ?? 0.0));
  }

  bool _isOfferExpired(Map<String, dynamic> offer) {
    final endDate = offer['endDate'];
    if (endDate == null) return false;
    try {
      final date = DateTime.parse(endDate);
      return date.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  void _applyFilters() {
    filteredOffers = offers.where((offer) {
      // Filtre par recherche
      if (searchQuery.isNotEmpty) {
        final name = (offer['name'] ?? '').toString().toLowerCase();
        final description = (offer['description'] ?? '').toString().toLowerCase();
        if (!name.contains(searchQuery.toLowerCase()) &&
            !description.contains(searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Filtre par statut
      if (selectedStatus != null) {
        switch (selectedStatus) {
          case 'active':
            if (!(offer['isActive'] == true)) return false;
            break;
          case 'inactive':
            if (offer['isActive'] == true) return false;
            break;
          case 'expired':
            if (!_isOfferExpired(offer)) return false;
            break;
        }
      }

      // Filtre par type
      if (selectedType != null && offer['discountType'] != selectedType) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _addOffer(Map<String, dynamic> data) async {
    try {
      final created = await OfferService.createOfferFromMap(data);
      if (created != null) {
        _showSuccessSnackbar('Offre créée avec succès');
        await _loadOffers();
      } else {
        _showErrorSnackbar('Erreur création offre');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur création offre: $e');
    }
  }

  void _editOffer(Map<String, dynamic> offer) {
    if (offer['id'] == null) {
      _showErrorSnackbar('Erreur: Offre sans identifiant');
      return;
    }

    Get.dialog(
      OfferFormDialog(
        initialData: offer,
        onSubmit: (data) async {
          await _updateOffer(offer['id'], data);
        },
      ),
    );
  }

  Future<void> _updateOffer(String offerId, Map<String, dynamic> data) async {
    try {
      final updated = await OfferService.updateOfferFromMap(offerId, data);
      if (updated != null) {
        _showSuccessSnackbar('Offre modifiée avec succès');
        await _loadOffers();
      } else {
        _showErrorSnackbar('Erreur: Aucune donnée retournée du serveur');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur modification offre: $e');
    }
  }

  Future<void> _deleteOffer(Map<String, dynamic> offer) async {
    // Dialog de confirmation
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 48, color: AppColors.warning),
              SizedBox(height: AppSpacing.md),
              Text(
                'Confirmer la suppression',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Êtes-vous sûr de vouloir supprimer l\'offre "${offer['name']}" ?',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Supprimer',
                      variant: GlassButtonVariant.error,
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        final ok = await OfferService.deleteOffer(offer['id']);
        if (ok) {
          _showSuccessSnackbar('Offre supprimée avec succès');
          await _loadOffers();
        } else {
          _showErrorSnackbar('Erreur suppression offre');
        }
      } catch (e) {
        _showErrorSnackbar('Erreur suppression offre: $e');
      }
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> offer) async {
    try {
      final newStatus = !(offer['isActive'] ?? true);
      final ok = await OfferService.toggleOfferStatus(offer['id'], newStatus);
      if (ok) {
        _showSuccessSnackbar(
            'Offre ${newStatus ? 'activée' : 'désactivée'} avec succès');
        await _loadOffers();
      } else {
        _showErrorSnackbar('Erreur modification statut');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur modification statut: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
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
                  fontSize: 16),
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec hauteur flexible
              Flexible(
                flex: 0,
                child: _buildHeader(context, isDark),
              ),
              SizedBox(height: AppSpacing.md),

              // Contenu principal scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistiques
                      OfferStatsGrid(
                        totalOffers: totalOffers,
                        activeOffers: activeOffers,
                        expiredOffers: expiredOffers,
                        totalDiscountValue: totalDiscountValue,
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Onglets
                      _buildTabBar(context, isDark),
                      SizedBox(height: AppSpacing.md),

                      // Contenu des onglets avec hauteur contrainte
                      Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOffersTab(context, isDark),
                            _buildAnalyticsTab(context, isDark),
                            _buildSettingsTab(context, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Offres',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              isLoading
                  ? 'Chargement...'
                  : '$totalOffers offre${totalOffers > 1 ? 's' : ''} • $activeOffers active${activeOffers > 1 ? 's' : ''}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Statistiques',
              icon: Icons.analytics_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () => _tabController.animateTo(1),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Nouvelle offre',
              icon: Icons.add_circle_outline,
              variant: GlassButtonVariant.primary,
              onPressed: () => Get.dialog(
                OfferFormDialog(
                  onSubmit: (data) async {
                    await _addOffer(data);
                  },
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: _loadOffers,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: AppRadius.radiusMD,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor:
            isDark ? AppColors.gray300 : AppColors.textSecondary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_offer_outlined, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Offres'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.analytics_outlined, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Analytics'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_outlined, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Paramètres'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Filtres et recherche
        OfferFilters(
          searchQuery: searchQuery,
          selectedStatus: selectedStatus,
          selectedType: selectedType,
          onSearchChanged: (query) {
            setState(() {
              searchQuery = query;
              _applyFilters();
            });
          },
          onStatusChanged: (status) {
            setState(() {
              selectedStatus = status;
              _applyFilters();
            });
          },
          onTypeChanged: (type) {
            setState(() {
              selectedType = type;
              _applyFilters();
            });
          },
          onClearFilters: () {
            setState(() {
              searchQuery = '';
              selectedStatus = null;
              selectedType = null;
              _applyFilters();
            });
          },
        ),
        SizedBox(height: AppSpacing.md),

        // Table des offres
        Expanded(
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Chargement des offres...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : filteredOffers.isEmpty
                  ? _buildEmptyState(context, isDark)
                  : OfferTable(
                      offers: filteredOffers,
                      onEdit: _editOffer,
                      onDelete: _deleteOffer,
                      onToggleStatus: _toggleStatus,
                    ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined,
                size: 64, color: AppColors.primary.withOpacity(0.5)),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Analytics des Offres',
              style: AppTextStyles.h3,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Fonctionnalité en cours de développement',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context, bool isDark) {
    return _glassCard(
      context,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_outlined,
                size: 64, color: AppColors.primary.withOpacity(0.5)),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Paramètres des Offres',
              style: AppTextStyles.h3,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Configuration globale des offres',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.local_offer_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucune offre trouvée',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            searchQuery.isNotEmpty || selectedStatus != null || selectedType != null
                ? 'Aucune offre ne correspond à vos critères de recherche'
                : 'Aucune offre n\'est encore créée dans le système',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          if (searchQuery.isNotEmpty || selectedStatus != null || selectedType != null)
            GlassButton(
              label: 'Effacer les filtres',
              icon: Icons.clear_all,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                setState(() {
                  searchQuery = '';
                  selectedStatus = null;
                  selectedType = null;
                  _applyFilters();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _glassCard(BuildContext context,
      {required Widget child, EdgeInsets? padding}) {
    return GlassContainer(
      padding: padding,
      child: child,
    );
  }
}
