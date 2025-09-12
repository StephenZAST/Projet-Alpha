import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../models/category.dart';

class CategoryTable extends StatelessWidget {
  final List<Category> categories;
  final void Function(Category) onEdit;
  final void Function(Category) onDelete;
  final void Function(Category) onToggleStatus;

  const CategoryTable({
    Key? key,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
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
              'Description',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Articles',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Statut',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
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
                flex: 3,
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
                          if (!category.isActive)
                            Text(
                              'Inactive',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Description
              Expanded(
                flex: 2,
                child: Text(
                  category.description ?? 'Aucune description',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.gray600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Nombre d'articles
              Expanded(
                flex: 1,
                child: Container(
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
              ),

              // Statut
              Expanded(
                flex: 1,
                child: _buildStatusBadge(category.isActive, isDark),
              ),

              // Date de création
              Expanded(
                flex: 1,
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
                    IconButton(
                      icon: Icon(
                        category.isActive ? Icons.toggle_on : Icons.toggle_off,
                        color: category.isActive ? AppColors.success : AppColors.gray400,
                        size: 28,
                      ),
                      onPressed: () => onToggleStatus(category),
                      tooltip: category.isActive ? 'Désactiver' : 'Activer',
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit(category);
                            break;
                          case 'delete':
                            onDelete(category);
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
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    Color color = isActive ? AppColors.success : AppColors.error;
    String text = isActive ? 'Active' : 'Inactive';
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