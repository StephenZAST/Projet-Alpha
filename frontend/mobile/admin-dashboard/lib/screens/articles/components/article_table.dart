import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../models/article.dart';
import '../../../controllers/category_controller.dart';

class ArticleTable extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article) onEdit;
  final void Function(Article) onDelete;
  final void Function(Article) onDuplicate;

  const ArticleTable({
    Key? key,
    required this.articles,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
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
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return _buildTableRow(context, isDark, article, index);
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
              'Article',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Catégorie',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date de création',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Statut',
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
      BuildContext context, bool isDark, Article article, int index) {
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
          onTap: () => onEdit(article),
          hoverColor: isDark
              ? AppColors.gray800.withOpacity(0.3)
              : AppColors.gray50.withOpacity(0.5),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Article (nom + description)
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
                          Icons.article_outlined,
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
                              article.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (article.description != null && article.description!.isNotEmpty)
                              Text(
                                article.description!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.gray300 : AppColors.gray600,
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

                // Catégorie
                Expanded(
                  flex: 3,
                  child: _buildCategoryChip(article.categoryId, isDark),
                ),

                // Date de création
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatDate(article.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray600,
                    ),
                  ),
                ),

                // Statut
                Expanded(
                  flex: 2,
                  child: _buildStatusBadge(true, isDark), // Tous les articles sont actifs pour l'instant
                ),

                // Actions
                SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.content_copy,
                          color: AppColors.info,
                          size: 18,
                        ),
                        onPressed: () => onDuplicate(article),
                        tooltip: 'Dupliquer',
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit(article);
                              break;
                            case 'delete':
                              onDelete(article);
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => [
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
                        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
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

  Widget _buildCategoryChip(String? categoryId, bool isDark) {
    if (categoryId == null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.gray500.withOpacity(0.1),
          borderRadius: AppRadius.radiusSM,
          border: Border.all(color: AppColors.gray500.withOpacity(0.3)),
        ),
        child: Text(
          'Aucune',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray500,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Récupérer le nom de la catégorie
    String categoryName = 'Catégorie';
    if (Get.isRegistered<CategoryController>()) {
      final categoryController = Get.find<CategoryController>();
      final category = categoryController.categories.firstWhereOrNull(
        (c) => c.id == categoryId,
      );
      if (category != null) {
        categoryName = category.name;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder, size: 12, color: AppColors.info),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              categoryName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    Color color = isActive ? AppColors.success : AppColors.error;
    String text = isActive ? 'Actif' : 'Inactif';
    IconData icon = isActive ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}