import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import 'components/category_dialog.dart';
import 'components/category_stats_grid.dart';
import 'components/category_table.dart';
import 'components/category_filters.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
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
                child: _buildHeader(context, isDark, controller),
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
                        'Catégories et Articles',
                        style: AppTextStyles.h2.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Gérez vos catégories et visualisez les articles associ��s',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Statistiques
                      Obx(() => CategoryStatsGrid(
                            totalCategories: controller.categories.length,
                            activeCategories: controller.categories.length, // Toutes les catégories sont considérées comme actives
                            totalArticles: controller.categories
                                .fold<int>(0, (sum, c) => sum + (c.articlesCount)),
                            averageArticlesPerCategory: controller.categories.isEmpty
                                ? 0.0
                                : controller.categories.fold<int>(
                                        0, (sum, c) => sum + (c.articlesCount)) /
                                    controller.categories.length,
                          )),
                      SizedBox(height: AppSpacing.lg),

                      // Filtres et recherche
                      CategoryFilters(
                        onSearchChanged: controller.searchCategories,
                        onClearFilters: () {
                          controller.searchCategories('');
                        },
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Table des catégories avec hauteur contrainte
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
                                    'Chargement des catégories...',
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

                          if (controller.hasError.value) {
                            return _buildErrorState(context, isDark, controller);
                          }

                          if (controller.categories.isEmpty) {
                            return _buildEmptyState(context, isDark);
                          }

                          return CategoryTable(
                            categories: controller.categories,
                            onEdit: (category) =>
                                Get.dialog(CategoryDialog(category: category)),
                            onDelete: (category) =>
                                _showDeleteDialog(context, category, controller),
                            onToggleStatus: (category) {
                              // Méthode supprimée car les catégories n'ont pas de champ isActive
                            },
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

  Widget _buildHeader(
      BuildContext context, bool isDark, CategoryController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Catégories',
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
                      : '${controller.categories.length} catégorie${controller.categories.length > 1 ? 's' : ''} • ${controller.categories.fold<int>(0, (sum, c) => sum + c.articlesCount)} articles',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Articles',
              icon: Icons.article_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () => Get.toNamed('/articles'),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Nouvelle Catégorie',
              icon: Icons.add_circle_outline,
              variant: GlassButtonVariant.primary,
              onPressed: () => Get.dialog(CategoryDialog()),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: controller.fetchCategories,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(
      BuildContext context, bool isDark, CategoryController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Erreur de chargement',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            controller.errorMessage.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: 'Réessayer',
            icon: Icons.refresh_outlined,
            variant: GlassButtonVariant.primary,
            onPressed: controller.fetchCategories,
          ),
        ],
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
              Icons.category_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucune catégorie trouvée',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Créez votre première catégorie pour organiser vos articles',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: 'Créer une catégorie',
            icon: Icons.add_circle_outline,
            variant: GlassButtonVariant.primary,
            onPressed: () => Get.dialog(CategoryDialog()),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Category category,
    CategoryController controller,
  ) {
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
                'Êtes-vous sûr de vouloir supprimer la catégorie "${category.name}" ?',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (category.articlesCount > 0) ...[
                SizedBox(height: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.warning, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Cette catégorie contient ${category.articlesCount} article${category.articlesCount > 1 ? 's' : ''}. Ils seront également supprimés.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                        controller.deleteCategory(category.id);
                        _showSuccessSnackbar('Catégorie supprimée avec succès');
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

  // Méthode _toggleCategoryStatus supprimée car les catégories n'ont pas de champ isActive

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
