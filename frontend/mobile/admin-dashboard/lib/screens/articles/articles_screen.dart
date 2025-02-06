import 'package:admin/models/article.dart';
import 'package:admin/screens/articles/components/article_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/article_controller.dart';
import '../../responsive.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gestion des Articles',
                    style: AppTextStyles.h1,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddArticleDialog(context),
                    icon: Icon(Icons.add),
                    label: Text('Nouvel Article'),
                  ),
                ],
              ),
              SizedBox(height: defaultPadding),

              // Searchbar
              TextField(
                onChanged: controller.searchArticles,
                decoration: InputDecoration(
                  hintText: "Rechercher un article...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: defaultPadding),

              // Articles Grid
              Expanded(
                child: Obx(
                  () => controller.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _getCrossAxisCount(context),
                            crossAxisSpacing: defaultPadding,
                            mainAxisSpacing: defaultPadding,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: controller.articles.length,
                          itemBuilder: (context, index) {
                            final article = controller.articles[index];
                            return ArticleCard(
                              article: article,
                              onEdit: () =>
                                  _showEditArticleDialog(context, article),
                              onDelete: () =>
                                  _showDeleteConfirmation(context, article),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddArticleDialog(BuildContext context) {
    // TODO: Implement dialog to add new article
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvel Article'),
        content: Text('Formulaire à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showEditArticleDialog(BuildContext context, Article article) {
    // TODO: Implement edit dialog
  }

  void _showDeleteConfirmation(BuildContext context, Article article) {
    // TODO: Implement delete confirmation
  }

  int _getCrossAxisCount(BuildContext context) {
    if (Responsive.isDesktop(context)) return 3;
    if (Responsive.isTablet(context)) return 2;
    return 1;
  }
}
