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
  TabController? _tabController; // Make nullable
  late ArticleProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ArticleProvider>();
    _provider.loadData().then((_) {
      if (mounted) {
        setState(() {
          _tabController = TabController(
            length: _provider.categories.length,
            vsync: this,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Safe dispose with null check
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Erreur: ${provider.error}',
                  style: TextStyle(color: AppColors.error),
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

        // Initialize controller if not already initialized
        if (_tabController == null ||
            _tabController!.length != provider.categories.length) {
          _tabController?.dispose(); // Dispose old controller if exists
          _tabController = TabController(
            length: provider.categories.length,
            vsync: this,
          );
        }

        return Column(
          children: [
            TabBar(
              controller:
                  _tabController!, // Safe to use ! here as we've checked above
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray500,
              tabs: provider.categories
                  .map((cat) => Tab(text: cat.name))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller:
                    _tabController!, // Safe to use ! here as we've checked above
                children: provider.categories.map((category) {
                  final articles = provider.getArticlesForCategory(category.id);
                  return ArticleList(
                    articles: articles,
                    selectedArticles: widget.selectedArticles,
                    onArticleQuantityChanged: widget.onArticleQuantityChanged,
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

class ArticleList extends StatelessWidget {
  final List<Article> articles;
  final Map<String, int> selectedArticles;
  final Function(String, int) onArticleQuantityChanged;

  const ArticleList({
    Key? key,
    required this.articles,
    required this.selectedArticles,
    required this.onArticleQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        final quantity = selectedArticles[article.id] ?? 0;

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
                      ? () => onArticleQuantityChanged(article.id, quantity - 1)
                      : null,
                ),
                Text('$quantity'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      onArticleQuantityChanged(article.id, quantity + 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
