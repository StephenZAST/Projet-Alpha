import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/service_type_controller.dart';
import '../../services/service_type_service.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import 'components/service_type_dialog.dart';
import 'components/service_type_stats_grid.dart';
import 'components/service_type_table.dart';
import 'components/service_type_filters.dart';

class ServiceTypesScreen extends StatefulWidget {
  const ServiceTypesScreen({Key? key}) : super(key: key);

  @override
  State<ServiceTypesScreen> createState() => _ServiceTypesScreenState();
}

class _ServiceTypesScreenState extends State<ServiceTypesScreen> {
  final controller = Get.put(ServiceTypeController());

  @override
  void initState() {
    super.initState();
    controller.fetchServiceTypes();
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
                      Obx(() => ServiceTypeStatsGrid(
                        totalTypes: controller.serviceTypes.length,
                        activeTypes: controller.serviceTypes.where((t) => t.isActive == true).length,
                        fixedPricingTypes: controller.serviceTypes.where((t) => t.pricingType == 'FIXED').length,
                        weightBasedTypes: controller.serviceTypes.where((t) => t.pricingType == 'WEIGHT_BASED').length,
                      )),
                      SizedBox(height: AppSpacing.lg),

                      // Filtres et recherche
                      ServiceTypeFilters(
                        onSearchChanged: (query) {
                          // TODO: Implémenter la recherche
                        },
                        onPricingTypeChanged: (type) {
                          // TODO: Implémenter le filtre par type de tarification
                        },
                        onStatusChanged: (status) {
                          // TODO: Implémenter le filtre par statut
                        },
                        onClearFilters: () {
                          // TODO: Effacer les filtres
                        },
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Table des types de service avec hauteur contrainte
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
                                    'Chargement des types de service...',
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

                          if (controller.serviceTypes.isEmpty) {
                            return _buildEmptyState(context, isDark);
                          }

                          return ServiceTypeTable(
                            serviceTypes: controller.serviceTypes,
                            onEdit: (type) => _showTypeDialog(type),
                            onDelete: _showDeleteDialog,
                            onToggleStatus: (type) => _toggleTypeStatus(type),
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
              'Types de Service',
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
                  : '${controller.serviceTypes.length} type${controller.serviceTypes.length > 1 ? 's' : ''} • ${controller.serviceTypes.where((t) => t.isActive == true).length} actif${controller.serviceTypes.where((t) => t.isActive == true).length > 1 ? 's' : ''}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Types Désactivés',
              icon: Icons.visibility_off_outlined,
              variant: GlassButtonVariant.secondary,
              onPressed: () => _showInactiveTypesDialog(),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Nouveau Type',
              icon: Icons.add_circle_outline,
              variant: GlassButtonVariant.primary,
              onPressed: () => _showTypeDialog(null),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: controller.fetchServiceTypes,
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
              Icons.category_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun type de service trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Créez votre premier type de service pour organiser vos services',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: 'Créer un type',
            icon: Icons.add_circle_outline,
            variant: GlassButtonVariant.primary,
            onPressed: () => _showTypeDialog(null),
          ),
        ],
      ),
    );
  }

  void _showTypeDialog(serviceType) async {
    final result = await Get.dialog<Map<String, dynamic>>(
      ServiceTypeDialog(editType: serviceType),
    );
    if (result != null) {
      final success = serviceType == null
          ? await controller.addServiceType(result)
          : await controller.updateServiceType(serviceType.id, result);
      
      if (success) {
        _showSuccessSnackbar(serviceType == null 
            ? 'Type de service créé avec succès'
            : 'Type de service modifié avec succès');
      } else {
        _showErrorSnackbar(controller.errorMessage.value);
      }
    }
  }

  void _showDeleteDialog(serviceType) {
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
                'Êtes-vous sûr de vouloir supprimer le type "${serviceType.name}" ?',
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
                      onPressed: () async {
                        Get.back();
                        final success = await controller.deleteServiceType(serviceType.id);
                        if (success) {
                          _showSuccessSnackbar('Type supprimé avec succès');
                        } else {
                          _showErrorSnackbar(controller.errorMessage.value);
                        }
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

  void _toggleTypeStatus(serviceType) async {
    final success = await controller.updateServiceType(
      serviceType.id, 
      {'is_active': !serviceType.isActive}
    );
    if (success) {
      _showSuccessSnackbar('Statut modifié avec succès');
    } else {
      _showErrorSnackbar(controller.errorMessage.value);
    }
  }

  void _showInactiveTypesDialog() async {
    final allTypes = await ServiceTypeService.getAllServiceTypes(includeInactive: true);
    final inactiveTypes = allTypes.where((t) => t.isActive == false).toList();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          width: 600,
          height: 500,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text(
                'Types de Service Désactivés',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: inactiveTypes.isEmpty
                    ? Center(child: Text('Aucun type désactivé'))
                    : ListView.builder(
                        itemCount: inactiveTypes.length,
                        itemBuilder: (context, index) {
                          final type = inactiveTypes[index];
                          return ListTile(
                            title: Text(type.name),
                            subtitle: Text(type.description ?? ''),
                            trailing: GlassButton(
                              label: 'Réactiver',
                              variant: GlassButtonVariant.success,
                              size: GlassButtonSize.small,
                              onPressed: () async {
                                final success = await controller.updateServiceType(
                                    type.id, {'is_active': true});
                                if (success) {
                                  Get.back();
                                  _showSuccessSnackbar('Type réactivé avec succès');
                                  controller.fetchServiceTypes();
                                } else {
                                  _showErrorSnackbar(controller.errorMessage.value);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
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
