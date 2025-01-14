import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';
import 'package:prima/theme/colors.dart';

class ArticleSelection extends StatelessWidget {
  final ArticleCategory? selectedCategory;
  final Map<String, int> selectedArticles;
  final Function(String, int) onArticleQuantityChanged;
  final TabController categoryTabController;

  const ArticleSelection({
    Key? key,
    this.selectedCategory,
    required this.selectedArticles,
    required this.onArticleQuantityChanged,
    required this.categoryTabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement des articles...'),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Erreur: ${provider.error}',
                  style: TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadData(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.categories.isEmpty) {
          return const Center(child: Text('Aucune catégorie disponible'));
        }

        return Column(
          children: [
            TabBar(
              controller: categoryTabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray500,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              tabs: provider.categories
                  .map((category) => Tab(text: category.name))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: categoryTabController,
                children: provider.categories.map((category) {
                  return _buildArticleList(context, category, provider);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticleList(BuildContext context, ArticleCategory category,
      ArticleProvider provider) {
    final articles = provider.getArticlesForCategory(category.id);

    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              'Aucun article dans cette catégorie',
              style: TextStyle(color: AppColors.gray600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) =>
          _buildArticleCard(context, articles[index]),
    );
  }

  Widget _buildArticleCard(BuildContext context, Article article) {
    final quantity = selectedArticles[article.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (article.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      article.description!,
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${article.basePrice}€',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildQuantityControls(context, article.id, quantity),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(
      BuildContext context, String articleId, int quantity) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: quantity > 0
              ? () => onArticleQuantityChanged(articleId, quantity - 1)
              : null,
          color: quantity > 0 ? AppColors.primary : AppColors.gray400,
        ),
        Text(
          quantity.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onArticleQuantityChanged(articleId, quantity + 1),
          color: AppColors.primary,
        ),
      ],
    );
  }
}
