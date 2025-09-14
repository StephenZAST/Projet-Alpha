import 'package:admin/models/article.dart';
import 'package:admin/screens/articles/components/article_form_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/article_controller.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import 'components/article_stats_grid.dart';
import 'components/article_table.dart';
import 'components/article_filters.dart';

class ArticlesScreen extends GetView<ArticleController> {
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
                      Obx(() => ArticleStatsGrid(
                            totalArticles: controller.articles.length,
                            activeArticles: controller.articles.length,
                            categoriesCount: _getCategoriesCount(),
                            averagePrice: _getAveragePrice(),
                          )),
                      SizedBox(height: AppSpacing.lg),

                      // Filtres et recherche
                      ArticleFilters(
                        onSearchChanged: controller.searchArticles,
                        onCategoryChanged: (categoryId) {
                          controller.setSelectedCategory(categoryId);
                        },
                        onClearFilters: () {
                          controller.setSelectedCategory(null);
                          controller.searchArticles('');
                        },
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Table des articles avec hauteur contrainte
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
                                    'Chargement des articles...',
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

                          if (controller.articles.isEmpty) {
                            return _buildEmptyState(context, isDark);
                          }

                          return ArticleTable(
                            articles: controller.articles,
                            onEdit: (article) => Get.dialog(
                              ArticleFormDialog(article: article),
                              barrierDismissible: false,
                            ),
                            onDelete: _showDeleteDialog,
                            onDuplicate: (article) => _duplicateArticle(article),
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
              'Gestion des Articles',
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
                      : '${controller.articles.length} article${controller.articles.length > 1 ? 's' : ''} • ${_getCategoriesCount()} catégorie${_getCategoriesCount() > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Catégories',
              icon: Icons.category_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () => Get.toNamed('/categories'),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Nouvel Article',
              icon: Icons.add_circle_outline,
              variant: GlassButtonVariant.primary,
              onPressed: () => Get.dialog(
                ArticleFormDialog(),
                barrierDismissible: false,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: controller.fetchArticles,
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
              Icons.article_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun article trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            controller.selectedCategory.value != null
                ? 'Aucun article ne correspond à vos critères de recherche'
                : 'Aucun article n\'est encore créé dans le système',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          if (controller.selectedCategory.value != null)
            GlassButton(
              label: 'Effacer les filtres',
              icon: Icons.clear_all,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                controller.setSelectedCategory(null);
                controller.searchArticles('');
              },
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Article article) {
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
                'Êtes-vous sûr de vouloir supprimer l\'article "${article.name}" ?',
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
                        controller.deleteArticle(article.id);
                        _showSuccessSnackbar('Article supprimé avec succès');
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

  void _duplicateArticle(Article article) {
    Get.dialog(
      ArticleFormDialog(
        article: Article(
          id: '', // Nouvel ID sera généré
          name: '${article.name} (Copie)',
          description: article.description,
          basePrice: article.basePrice,
          premiumPrice: article.premiumPrice,
          categoryId: article.categoryId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      barrierDismissible: false,
    );
  }

  int _getCategoriesCount() {
    if (!Get.isRegistered<CategoryController>()) return 0;
    final categoryController = Get.find<CategoryController>();
    return categoryController.categories.length;
  }

  double _getAveragePrice() {
    if (controller.articles.isEmpty) return 0.0;
    final total = controller.articles.fold<double>(
      0.0,
      (sum, article) => sum + article.basePrice,
    );
    return total / controller.articles.length;
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
