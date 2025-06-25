import 'package:admin/widgets/shared/action_button.dart';
import 'package:admin/widgets/shared/app_button.dart';
import 'package:admin/widgets/shared/bouncy_button.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';
import 'components/category_dialog.dart';
import 'components/category_list_tile.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchController = TextEditingController();
    final RxString searchQuery = ''.obs;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header moderne avec titre, bouton glassy et refresh
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Catégories',
                    style: AppTextStyles.h1.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      GlassButton(
                        label: 'Nouvelle catégorie',
                        icon: Icons.add,
                        variant: GlassButtonVariant.primary,
                        onPressed: () => showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => CategoryDialog(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassButton(
                        icon: Icons.refresh,
                        label: '',
                        variant: GlassButtonVariant.secondary,
                        size: GlassButtonSize.small,
                        onPressed: controller.fetchCategories,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Barre de recherche
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.white70,
                    width: 1.2,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) => searchQuery.value = value,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une catégorie...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (searchQuery.value.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          searchController.clear();
                          searchQuery.value = '';
                        },
                        child: Icon(Icons.close, color: AppColors.gray400),
                      ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
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

                  // Filtrage par recherche
                  final filteredCategories = controller.categories.where((cat) {
                    final query = searchQuery.value.toLowerCase();
                    return cat.name.toLowerCase().contains(query) ||
                        (cat.description?.toLowerCase().contains(query) ??
                            false);
                  }).toList();

                  if (filteredCategories.isEmpty) {
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
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return CategoryListTile(
                        category: category,
                        onEdit: (cat) =>
                            Get.dialog(CategoryDialog(category: cat)),
                        onDelete: (cat) =>
                            _showDeleteDialog(context, cat, controller),
                        // Ajout d'options pour badge, nombre d'articles, etc. dans le widget
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
