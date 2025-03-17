import 'package:admin/widgets/shared/action_button.dart';
import 'package:admin/widgets/shared/app_button.dart';
import 'package:admin/widgets/shared/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';
import '../../widgets/shared/header.dart';
import 'components/category_dialog.dart';
import 'components/header_actions.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                title: 'Catégories',
                actions: [
                  BouncyButton(
                    onTap: () => Get.dialog(CategoryDialog()),
                    label: 'Nouvelle Catégorie',
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
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

                  if (controller.hasError.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            controller.errorMessage.value,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: 'Réessayer',
                            icon: Icons.refresh_outlined,
                            onPressed: controller.fetchCategories,
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.categories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 48,
                            color:
                                isDark ? AppColors.gray600 : AppColors.gray400,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Aucune catégorie trouvée',
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

                  return ListView.builder(
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: AppSpacing.md),
                        child: ListTile(
                          leading: Icon(
                            Icons.folder,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            category.name,
                            style: AppTextStyles.h4.copyWith(
                              fontSize: 16.0,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          subtitle: category.description != null
                              ? Text(
                                  category.description!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textLight
                                        : AppColors.textSecondary,
                                  ),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ActionButton(
                                icon: Icons.edit_rounded,
                                label: '',
                                color: AppColors.primary,
                                onTap: () => Get.dialog(
                                  CategoryDialog(category: category),
                                ),
                                variant: ActionButtonVariant.ghost,
                                isCompact: true,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              ActionButton(
                                icon: Icons.delete_rounded,
                                label: '',
                                color: AppColors.error,
                                onTap: () => _showDeleteDialog(
                                  context,
                                  category,
                                  controller,
                                ),
                                variant: ActionButtonVariant.ghost,
                                isCompact: true,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
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
        title: Text('Confirmation'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la catégorie "${category.name}" ?',
        ),
        actions: [
          AppButton(
            label: 'Annuler',
            variant: AppButtonVariant.secondary,
            onPressed: () => Get.back(),
          ),
          AppButton(
            label: 'Supprimer',
            variant: AppButtonVariant.error,
            onPressed: () {
              Get.back();
              controller.deleteCategory(category.id);
            },
          ),
        ],
      ),
    );
  }
}
