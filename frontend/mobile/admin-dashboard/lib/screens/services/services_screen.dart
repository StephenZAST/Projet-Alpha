import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/controllers/service_type_controller.dart';
import 'package:admin/screens/services/components/service_form_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/service_controller.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import 'components/service_stats_grid.dart';
import 'components/service_table.dart';
import 'components/service_filters.dart';

class ServicesScreen extends GetView<ServiceController> {
  @override
  Widget build(BuildContext context) {
    // S'assure que le ServiceTypeController est bien initialisé
    Get.put(ServiceTypeController());
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
                      Obx(() => ServiceStatsGrid(
                            totalServices: controller.services.length,
                            activeServices: controller.services.length,
                            serviceTypesCount: _getServiceTypesCount(),
                            averagePrice: _getAveragePrice(),
                          )),
                      SizedBox(height: AppSpacing.lg),

                      // Filtres et recherche
                      ServiceFilters(
                        onSearchChanged: controller.searchServices,
                        onClearFilters: () {
                          controller.searchServices('');
                        },
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Table des services avec hauteur contrainte
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                      color: AppColors.primary),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Chargement des services...',
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

                          if (controller.services.isEmpty) {
                            return _buildEmptyState(context, isDark);
                          }

                          return ServiceTable(
                            services: controller.services,
                            onEdit: (service) =>
                                Get.dialog(ServiceFormScreen(service: service)),
                            onDelete: _showDeleteDialog,
                            onDuplicate: (service) =>
                                _duplicateService(service),
                          );
                        }),
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
              'Gestion des Services',
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
                      : '${controller.services.length} service${controller.services.length > 1 ? 's' : ''} • ${_getServiceTypesCount()} type${_getServiceTypesCount() > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Types de Service',
              icon: Icons.category_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () {
                final menuController = Get.find<MenuAppController>();
                menuController.updateIndex(MenuIndices.serviceTypes);
                Get.toNamed('/service-types');
              },
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Couples Service/Article',
              icon: Icons.link_outlined,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                final menuController = Get.find<MenuAppController>();
                menuController.updateIndex(MenuIndices.serviceArticleCouples);
                Get.toNamed('/service-article-couples');
              },
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Nouveau Service',
              icon: Icons.add_circle_outline,
              variant: GlassButtonVariant.primary,
              onPressed: () => Get.dialog(ServiceFormScreen()),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: controller.fetchServices,
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.cleaning_services_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun service trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Créez votre premier service pour commencer',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: 'Créer un service',
            icon: Icons.add_circle_outline,
            variant: GlassButtonVariant.primary,
            onPressed: () => Get.dialog(ServiceFormScreen()),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(service) {
    Get.dialog(
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
                'Êtes-vous sûr de vouloir supprimer le service "${service.name}" ?',
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
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Supprimer',
                      variant: GlassButtonVariant.error,
                      onPressed: () {
                        Get.back();
                        controller.deleteService(service.id);
                        _showSuccessSnackbar('Service supprimé avec succès');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _duplicateService(service) {
    Get.dialog(
      ServiceFormScreen(
        service: service, // Le formulaire gérera la duplication
      ),
    );
  }

  int _getServiceTypesCount() {
    if (!Get.isRegistered<ServiceTypeController>()) return 0;
    final serviceTypeController = Get.find<ServiceTypeController>();
    return serviceTypeController.serviceTypes.length;
  }

  double _getAveragePrice() {
    if (controller.services.isEmpty) return 0.0;
    final total = controller.services.fold<double>(
      0.0,
      (sum, service) => sum + service.price,
    );
    return total / controller.services.length;
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
}
