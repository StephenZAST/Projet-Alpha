import 'package:admin/models/article.dart';
import 'package:admin/screens/articles/components/article_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/article_controller.dart';
import '../../controllers/category_controller.dart';
import 'package:admin/widgets/shared/glass_button.dart';

class ArticlesScreen extends GetView<ArticleController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: defaultPadding),
              _buildSearchBar(context),
              SizedBox(height: defaultPadding),
              Expanded(
                child: Obx(() => _buildArticlesByCategory(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Gestion des Articles',
          style: AppTextStyles.h1.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        Row(
          children: [
            GlassButton(
              label: 'Nouvel Article',
              icon: Icons.add,
              variant: GlassButtonVariant.primary,
              onPressed: () => _showAddArticleDialog(context),
            ),
            const SizedBox(width: 8),
            GlassButton(
              icon: Icons.refresh,
              label: '',
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: controller.fetchArticles,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      onChanged: controller.searchArticles,
      decoration: InputDecoration(
        hintText: "Rechercher un article...",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Suppression du toggle grille/liste, non utilisé dans la nouvelle UI

  Widget _buildArticlesByCategory(BuildContext context) {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.articles.isEmpty) {
      return Center(
        child: Text('Aucun article trouvé'),
      );
    }

    // Regrouper les articles par catégorie
    final Map<String, List<Article>> articlesByCategory = {};
    for (var article in controller.articles) {
      final catId = article.categoryId ?? 'Autre';
      if (!articlesByCategory.containsKey(catId)) {
        articlesByCategory[catId] = [];
      }
      articlesByCategory[catId]!.add(article);
    }

    // Récupérer les noms de catégorie via le controller (si possible)
    final categoryController = Get.isRegistered<CategoryController>()
        ? Get.find<CategoryController>()
        : null;
    String getCategoryName(String catId) {
      if (categoryController == null) return 'Autre';
      final cat =
          categoryController.categories.firstWhereOrNull((c) => c.id == catId);
      return cat?.name ?? 'Autre';
    }

    return ListView(
      children: articlesByCategory.entries.map((entry) {
        final catId = entry.key;
        final catName = getCategoryName(catId);
        final articles = entry.value;
        return ExpansionTile(
          title: Text(
            catName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.primaryDark,
            ),
          ),
          children: articles.map((article) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(Icons.article_outlined,
                          color: AppColors.primary),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text(
                            article.description ?? '',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppColors.primaryDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .cardColor
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${article.basePrice} FCFA',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              if (article.premiumPrice != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .cardColor
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.orange.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${article.premiumPrice} FCFA',
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: AppColors.primary,
                          onPressed: () => Get.dialog(
                              ArticleFormDialog(article: article),
                              barrierDismissible: false),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: AppColors.error,
                          onPressed: () => controller.deleteArticle(article.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  void _showAddArticleDialog(BuildContext context) {
    Get.dialog(
      ArticleFormDialog(),
      barrierDismissible: false,
    );
  }

  // Suppression des méthodes non utilisées

  // Suppression du calcul du nombre de colonnes, non utilisé dans la nouvelle UI
}
