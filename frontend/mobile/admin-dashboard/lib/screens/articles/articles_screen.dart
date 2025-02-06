import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/article_controller.dart';
import '../../responsive.dart';

class ArticlesScreen extends GetView<ArticleController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Articles'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.fetchArticles,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: defaultPadding),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.articles.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucun article disponible',
                      style: AppTextStyles.bodyLarge,
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.isMobile(context)
                        ? 1
                        : Responsive.isTablet(context)
                            ? 2
                            : 3,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: defaultPadding,
                    mainAxisSpacing: defaultPadding,
                  ),
                  itemCount: controller.articles.length,
                  itemBuilder: (context, index) {
                    final article = controller.articles[index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.name,
                              style: AppTextStyles.h4,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Prix: ${article.basePrice} FCFA',
                              style: AppTextStyles.bodyMedium,
                            ),
                            if (article.category != null) ...[
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                'Catégorie: ${article.category}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout d'article
          Get.snackbar(
            'Info',
            'Fonctionnalité en cours de développement',
            backgroundColor: AppColors.info,
            colorText: AppColors.white,
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Ajouter un article',
      ),
    );
  }
}
