import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../models/category.dart';
import '../../../services/article_service.dart';
import '../../../controllers/menu_app_controller.dart';

class CategoryTable extends StatelessWidget {
  final List<Category> categories;
  final void Function(Category) onEdit;
  final void Function(Category) onDelete;

  const CategoryTable({
    Key? key,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // En-tête du tableau
          _buildTableHeader(context, isDark),

          // Divider
          Divider(
            height: 1,
            color: isDark
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),

          // Corps du tableau
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildTableRow(context, isDark, category, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray900.withOpacity(0.3)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.radiusMD.topLeft,
          topRight: AppRadius.radiusMD.topRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Catégorie',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Description',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Articles',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Créée le',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 120), // Espace pour les actions
        ],
      ),
    );
  }

  Widget _buildTableRow(
      BuildContext context, bool isDark, Category category, int index) {
    return Container(
      // Effet de zébrage
      color: index % 2 == 0
          ? (isDark ? AppColors.gray900 : AppColors.gray50)
          : Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? AppColors.gray700.withOpacity(0.2)
                  : AppColors.gray200.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: InkWell(
          onTap: () => onEdit(category),
          hoverColor: isDark
              ? AppColors.gray800.withOpacity(0.3)
              : AppColors.gray50.withOpacity(0.5),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Catégorie (nom + icône)
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Icon(
                          Icons.folder_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Description
                Expanded(
                  flex: 3,
                  child: Text(
                    category.description ?? 'Aucune description',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Nombre d'articles avec bouton pour voir les articles
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: category.articlesCount > 0
                              ? AppColors.info.withOpacity(0.1)
                              : AppColors.gray500.withOpacity(0.1),
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Text(
                          '${category.articlesCount}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: category.articlesCount > 0
                                ? AppColors.info
                                : AppColors.gray500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (category.articlesCount > 0) ...[
                        SizedBox(width: AppSpacing.xs),
                        IconButton(
                          icon: Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.info,
                          ),
                          onPressed: () =>
                              _showArticlesDialog(context, category, isDark),
                          tooltip: 'Voir les articles',
                        ),
                      ],
                    ],
                  ),
                ),

                // Date de création
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatDate(category.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray600,
                    ),
                  ),
                ),

                // Actions
                SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit(category);
                              break;
                            case 'delete':
                              onDelete(category);
                              break;
                            case 'view_articles':
                              _showArticlesDialog(context, category, isDark);
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'view_articles',
                            child: ListTile(
                              leading: Icon(Icons.article_outlined,
                                  size: 18, color: AppColors.info),
                              title: Text('Voir les articles'),
                              dense: true,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined, size: 18),
                              title: Text('Modifier'),
                              dense: true,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.error),
                              title: Text('Supprimer',
                                  style: TextStyle(color: AppColors.error)),
                              dense: true,
                            ),
                          ),
                        ],
                        icon: Icon(
                          Icons.more_vert,
                          color: isDark ? AppColors.gray300 : AppColors.gray600,
                        ),
                        color: isDark
                            ? AppColors.cardBgDark
                            : AppColors.cardBgLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMD,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode _buildStatusBadge supprimée car les catégories n'ont pas de champ isActive

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showArticlesDialog(
      BuildContext context, Category category, bool isDark) async {
    // Afficher un dialogue de chargement
    Get.dialog(
      Center(
        child: GlassContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: AppSpacing.md),
              Text(
                'Chargement des articles...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Récupérer les articles de cette catégorie
      final articles = await ArticleService.getArticlesByCategory(category.id);

      // Fermer le dialogue de chargement
      Get.back();

      // Afficher le dialogue avec les articles
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: ClipRRect(
              borderRadius: AppRadius.radiusLG,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: GlassContainer(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: AppRadius.radiusMD,
                            ),
                            child: Icon(
                              Icons.folder_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Articles de "${category.name}"',
                                  style: AppTextStyles.h3.copyWith(
                                    color: isDark
                                        ? AppColors.textLight
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${articles.length} article${articles.length > 1 ? 's' : ''} trouvé${articles.length > 1 ? 's' : ''}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isDark
                                        ? AppColors.gray300
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Icon(
                              Icons.close,
                              color: isDark
                                  ? AppColors.gray300
                                  : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Liste des articles
                      Expanded(
                        child: articles.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.article_outlined,
                                      size: 64,
                                      color: AppColors.gray400,
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Aucun article dans cette catégorie',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.gray400,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: articles.length,
                                itemBuilder: (context, index) {
                                  final article = articles[index];
                                  return Container(
                                    margin:
                                        EdgeInsets.only(bottom: AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? (isDark
                                              ? AppColors.gray800
                                                  .withOpacity(0.3)
                                              : AppColors.gray50
                                                  .withOpacity(0.5))
                                          : Colors.transparent,
                                      borderRadius: AppRadius.radiusMD,
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.gray700.withOpacity(0.3)
                                            : AppColors.gray200
                                                .withOpacity(0.5),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.success
                                              .withOpacity(0.15),
                                          borderRadius: AppRadius.radiusSM,
                                        ),
                                        child: Icon(
                                          Icons.inventory_2_outlined,
                                          color: AppColors.success,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        article.name,
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.textLight
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      subtitle: article.description != null &&
                                              article.description!.isNotEmpty
                                          ? Text(
                                              article.description!,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: isDark
                                                    ? AppColors.gray300
                                                    : AppColors.gray600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : null,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.info
                                                  .withOpacity(0.1),
                                              borderRadius: AppRadius.radiusSM,
                                            ),
                                            child: Text(
                                              'ID: ${article.id.substring(0, 8)}...',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.info,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GlassButton(
                            label: 'Aller aux Articles',
                            icon: Icons.arrow_forward,
                            variant: GlassButtonVariant.primary,
                            onPressed: () {
                              Get.back();
                              // Utiliser le MenuAppController pour une navigation centralisée
                              final menuController = Get.find<MenuAppController>();
                              menuController.goToArticles();
                              
                              // TODO: Implémenter le filtrage par catégorie dans ArticlesScreen
                              // Pour l'instant, on navigue vers Articles sans filtre spécifique
                            },
                          ),
                          SizedBox(width: AppSpacing.md),
                          GlassButton(
                            label: 'Fermer',
                            variant: GlassButtonVariant.secondary,
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      Get.back();

      // Afficher un dialogue d'erreur
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: GlassContainer(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Erreur de chargement',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Impossible de charger les articles de cette catégorie.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
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
  }
}
