import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/article_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../models/category.dart';

class CategoriesSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final articleController = Get.find<ArticleController>();
    final categoryController = Get.find<CategoryController>();
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
          _buildAllCategoriesButton(articleController),
          SizedBox(height: AppSpacing.sm),
          _buildCategoriesList(articleController, categoryController),
        ],
      ),
    );
  }

  Widget _buildAllCategoriesButton(ArticleController controller) {
    return InkWell(
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
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Toutes les catégories',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCategoriesList(
    ArticleController articleController,
    CategoryController categoryController,
  ) {
    return Expanded(
      child: Obx(() {
        if (categoryController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (categoryController.hasError.value) {
          return Center(
            child: Text(
              categoryController.errorMessage.value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (categoryController.categories.isEmpty) {
          return Center(
            child: Text(
              'Aucune catégorie disponible',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          itemCount: categoryController.categories.length,
          itemBuilder: (context, index) {
            final category = categoryController.categories[index];
            return _buildCategoryItem(category, articleController);
          },
        );
      }),
    );
  }

  Widget _buildCategoryItem(Category category, ArticleController controller) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == category.id;
      return InkWell(
        onTap: () => controller.setSelectedCategory(category.id),
        borderRadius: AppRadius.radiusSM,
        child: Container(
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
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  category.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppColors.primary : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (category.articlesCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.2),
                    borderRadius: AppRadius.radiusXS,
                  ),
                  child: Text(
                    '${category.articlesCount}',
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
