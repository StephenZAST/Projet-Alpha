import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/article_controller.dart';
import '../../models/article.dart';
import 'components/article_card.dart';
import 'components/article_form_screen.dart';
import 'components/categories_sidebar.dart';

class ArticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();
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
                    'Articles',
                    style: AppTextStyles.h1.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Nouvel article'),
                    onPressed: () => Get.dialog(ArticleFormScreen()),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              TextField(
                onChanged: controller.searchArticles,
                decoration: InputDecoration(
                  hintText: 'Rechercher un article...',
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar avec les catégories
                    CategoriesSidebar(),
                    SizedBox(width: defaultPadding),
                    // Liste des articles
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
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
                                  onPressed: controller.fetchArticles,
                                  child: Text('Réessayer'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (controller.articles.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: AppSpacing.md),
                                Text(
                                  'Aucun article trouvé',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _getCrossAxisCount(context),
                            crossAxisSpacing: defaultPadding,
                            mainAxisSpacing: defaultPadding,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: controller.articles.length,
                          itemBuilder: (context, index) {
                            final article = controller.articles[index];
                            return ArticleCard(article: article);
                          },
                        );
                      }),
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

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1800) return 4;
    if (width > 1400) return 3;
    if (width > 1000) return 2;
    return 1;
  }
}
