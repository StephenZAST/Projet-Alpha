import 'package:flutter/material.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:provider/provider.dart';

class ArticleSelectionStep extends StatefulWidget {
  final Map<String, int> selectedArticles;
  final Function(Map<String, int>) onArticlesUpdated;

  const ArticleSelectionStep({
    Key? key,
    required this.selectedArticles,
    required this.onArticlesUpdated,
  }) : super(key: key);

  @override
  State<ArticleSelectionStep> createState() => _ArticleSelectionStepState();
}

class _ArticleSelectionStepState extends State<ArticleSelectionStep>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int> _selectedArticles = {};

  @override
  void initState() {
    super.initState();
    _selectedArticles = Map.from(widget.selectedArticles);
    final articleProvider = context.read<ArticleProvider>();
    _tabController =
        TabController(length: articleProvider.categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateQuantity(String articleId, int change) {
    setState(() {
      final currentQuantity = _selectedArticles[articleId] ?? 0;
      final newQuantity = currentQuantity + change;

      if (newQuantity <= 0) {
        _selectedArticles.remove(articleId);
      } else {
        _selectedArticles[articleId] = newQuantity;
      }

      widget.onArticlesUpdated(_selectedArticles);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
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

        return Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray500,
              tabs: provider.categories
                  .map((category) => Tab(text: category.name))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: provider.categories.map((category) {
                  final categoryArticles =
                      provider.getArticlesForCategory(category.id);

                  if (categoryArticles.isEmpty) {
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
                    itemCount: categoryArticles.length,
                    itemBuilder: (context, index) {
                      final article = categoryArticles[index];
                      final quantity = _selectedArticles[article.id] ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(article.name),
                          subtitle: Text('${article.basePrice}€'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: quantity > 0
                                    ? () => _updateQuantity(article.id, -1)
                                    : null,
                              ),
                              Text('$quantity'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _updateQuantity(article.id, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
