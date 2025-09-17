import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/delivery_controller.dart';
import '../../widgets/shared/glass_container.dart';
import '../../widgets/shared/glass_button.dart';
import 'components/deliverers_table.dart';
import 'components/delivery_stats_grid.dart';
import 'components/delivery_filters.dart';
import 'components/delivery_list.dart';
import 'components/deliverer_create_dialog.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  late DeliveryController controller;

  @override
  void initState() {
    super.initState();
    print('[DeliveryScreen] initState: Initialisation');

    // S'assurer que le contrôleur existe et est unique
    if (Get.isRegistered<DeliveryController>()) {
      controller = Get.find<DeliveryController>();
    } else {
      controller = Get.put(DeliveryController(), permanent: true);
    }
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
                      // Titre de la section
                      Text(
                        'Équipe de Livraison',
                        style: AppTextStyles.h2.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Gérez votre équipe de livreurs et suivez les performances',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Statistiques
                      DeliveryStatsGrid(),
                      SizedBox(height: AppSpacing.lg),

                      // Filtres et recherche
                      DeliveryFilters(),
                      SizedBox(height: AppSpacing.md),

                      // Table des livreurs avec hauteur contrainte
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: AppColors.primary),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Chargement des livreurs...',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.textLight
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (controller.filteredDeliverers.isEmpty) {
                            return _buildEmptyState(context, isDark);
                          }

                          return DeliverersTable();
                        }),
                      ),

                      // Pagination
                      SizedBox(height: AppSpacing.md),
                      _buildPagination(context, isDark),
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
              'Gestion des Livreurs',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Obx(() => Text(
                  controller.isLoading.value
                      ? 'Chargement...'
                      : '${controller.totalDeliverers.value} livreur${controller.totalDeliverers.value > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Livraisons',
              icon: Icons.local_shipping_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () => _showActiveDeliveries(context),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Nouveau Livreur',
              icon: Icons.person_add_outlined,
              variant: GlassButtonVariant.success,
              onPressed: () => _showCreateDelivererDialog(context),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.primary,
              size: GlassButtonSize.small,
              onPressed: () {
                print('[DeliveryScreen] Bouton Actualiser cliqué');
                controller.refreshAll();
              },
            ),
          ],
        ),
      ],
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
              color: AppColors.teal.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.delivery_dining_outlined,
              size: 60,
              color: AppColors.teal.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun livreur trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            controller.searchQuery.value.isNotEmpty ||
                    controller.showActiveOnly.value
                ? 'Aucun livreur ne correspond à vos critères de recherche'
                : 'Aucun livreur n\'est encore enregistré dans le système',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          if (controller.searchQuery.value.isNotEmpty ||
              controller.showActiveOnly.value)
            GlassButton(
              label: 'Effacer les filtres',
              icon: Icons.clear_all,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                controller.searchQuery.value = '';
                controller.showActiveOnly.value = false;
              },
            )
          else
            GlassButton(
              label: 'Ajouter un livreur',
              icon: Icons.person_add_outlined,
              variant: GlassButtonVariant.success,
              onPressed: () => _showCreateDelivererDialog(context),
            ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.totalPages.value <= 1) return SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.gray800.withOpacity(0.5)
              : Colors.white.withOpacity(0.8),
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: isDark
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page ${controller.currentPage.value} sur ${controller.totalPages.value}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                GlassButton(
                  label: '',
                  icon: Icons.chevron_left,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: controller.currentPage.value > 1
                      ? controller.previousPage
                      : null,
                ),
                SizedBox(width: AppSpacing.sm),
                GlassButton(
                  label: '',
                  icon: Icons.chevron_right,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed:
                      controller.currentPage.value < controller.totalPages.value
                          ? controller.nextPage
                          : null,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showCreateDelivererDialog(BuildContext context) {
    Get.dialog(
      DelivererCreateDialog(),
      barrierDismissible: false,
    );
  }

  void _showActiveDeliveries(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 900,
          height: 700,
          child: GlassSectionContainer(
            title: 'Livraisons Actives',
            subtitle: 'Suivez toutes les livraisons en cours',
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.info,
            actions: [
              GlassButton(
                label: 'Fermer',
                icon: Icons.close,
                variant: GlassButtonVariant.secondary,
                size: GlassButtonSize.small,
                onPressed: () => Get.back(),
              ),
            ],
            child: Container(
              height: 500,
              child: DeliveryList(),
            ),
          ),
        ),
      ),
    );
  }
}
