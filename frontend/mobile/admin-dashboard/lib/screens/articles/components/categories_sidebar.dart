import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/article_controller.dart';
import '../../../models/category.dart';

class CategoriesSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 250,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catégories',
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // Bouton "Toutes les catégories"
          InkWell(
            onTap: () => controller.setSelectedCategory(null),
            borderRadius: AppRadius.radiusSM,
            child: Obx(() {
              final isSelected = controller.selectedCategory.value == null;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 20,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Toutes les catégories',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: AppSpacing.sm),
          // Liste des catégories
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              // TODO: Implémenter le chargement des catégories
              // Pour l'instant, utilisons des catégories de test
              final categories = [
                Category(id: '1', name: 'Vêtements'),
                Category(id: '2', name: 'Chaussures'),
                Category(id: '3', name: 'Accessoires'),
                Category(id: '4', name: 'Sacs'),
                Category(id: '5', name: 'Linge de maison'),
              ];

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return InkWell(
                    onTap: () => controller.setSelectedCategory(category.id),
                    borderRadius: AppRadius.radiusSM,
                    child: Obx(() {
                      final isSelected =
                          controller.selectedCategory.value == category.id;
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder,
                              size: 20,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                category.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
