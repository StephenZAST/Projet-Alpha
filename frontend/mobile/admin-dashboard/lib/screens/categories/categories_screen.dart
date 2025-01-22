import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';
import 'components/category_dialog.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Catégories',
                    style: AppTextStyles.h1.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Nouvelle catégorie'),
                    onPressed: () => Get.dialog(CategoryDialog()),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              TextField(
                onChanged: controller.searchCategories,
                decoration: InputDecoration(
                  hintText: 'Rechercher une catégorie...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
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
                            style: TextStyle(color: AppColors.error),
                          ),
                          SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: controller.fetchCategories,
                            child: Text('Réessayer'),
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
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Aucune catégorie trouvée',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
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
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => Get.dialog(
                                  CategoryDialog(category: category),
                                ),
                                color: AppColors.textSecondary,
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _showDeleteDialog(
                                  context,
                                  category,
                                  controller,
                                ),
                                color: AppColors.error,
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
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Supprimer'),
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
