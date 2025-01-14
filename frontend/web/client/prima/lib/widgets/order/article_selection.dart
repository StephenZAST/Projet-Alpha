import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/models/article.dart';
import 'package:prima/theme/colors.dart';

class ArticleSelection extends StatefulWidget {
  final Map<String, int> selectedArticles;
  final Function(String, int) onArticleQuantityChanged;

  const ArticleSelection({
    Key? key,
    required this.selectedArticles,
    required this.onArticleQuantityChanged,
  }) : super(key: key);

  @override
  State<ArticleSelection> createState() => _ArticleSelectionState();
}

class _ArticleSelectionState extends State<ArticleSelection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final articleProvider = context.read<ArticleProvider>();
    if (articleProvider.categories.isEmpty) {
      articleProvider.loadData().then((_) {
        if (mounted) {
          _tabController = TabController(
            length: articleProvider.categories.length,
            vsync: this,
          );
          setState(() {});
        }
      });
    } else {
      _tabController = TabController(
        length: articleProvider.categories.length,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            child: Text('Erreur: ${provider.error}'),
          );
        }

        return Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: provider.categories
                  .map((cat) => Tab(text: cat.name))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: provider.categories.map((category) {
                  final categoryArticles =
                      provider.getArticlesForCategory(category.id);
                  return _buildArticleList(categoryArticles);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticleList(List<Article> articles) {
    if (articles.isEmpty) {
      return const Center(
        child: Text('Aucun article dans cette catégorie'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        final quantity = widget.selectedArticles[article.id] ?? 0;

        return Card(
          child: ListTile(
            title: Text(article.name),
            subtitle: Text('${article.basePrice}€'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: quantity > 0
                      ? () => widget.onArticleQuantityChanged(
                          article.id, quantity - 1)
                      : null,
                ),
                Text('$quantity'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      widget.onArticleQuantityChanged(article.id, quantity + 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
