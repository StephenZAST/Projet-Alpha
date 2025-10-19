import 'package:flutter/material.dart';
import 'package:prima/models/article.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/models/article_category.dart';
import 'package:provider/provider.dart';
import 'package:spring_button/spring_button.dart';

class ArticleSelectionView extends StatefulWidget {
  final Function(Map<String, int>) onArticlesSelected;
  final Map<String, int> initialSelection;

  const ArticleSelectionView({
    Key? key,
    required this.onArticlesSelected,
    this.initialSelection = const {},
  }) : super(key: key);

  @override
  State<ArticleSelectionView> createState() => _ArticleSelectionViewState();
}

class _ArticleSelectionViewState extends State<ArticleSelectionView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int> _selectedArticles = {};

  @override
  void initState() {
    super.initState();
    _selectedArticles = Map.from(widget.initialSelection);
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    final articleProvider = context.read<ArticleProvider>();

    // Déplacer l'appel dans un Future.microtask
    Future.microtask(() => articleProvider.loadData());

    _tabController = TabController(
      length: articleProvider.categories.length,
      vsync: this,
    );
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
          return Center(child: Text('Error: ${provider.error}'));
        }

        if (provider.categories.isEmpty) {
          return const Center(child: Text('Aucune catégorie disponible'));
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
                  return _buildCategoryArticles(category, provider);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryArticles(
      ArticleCategory category, ArticleProvider provider) {
    final articles = provider.getArticlesForCategory(category.id);

    if (articles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 48, color: AppColors.gray400),
            SizedBox(height: 16),
            Text(
              'Aucun article dans cette catégorie',
              style: TextStyle(color: AppColors.gray600),
            ),
          ],
        ),
      );
    }

        return ListView.builder(
          itemCount: articles.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final article = articles[index];
            return _buildArticleItem(article);
          },
        );
      },
    );
  }

  Widget _buildArticleItem(Article article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(article.name),
        subtitle: Text('\$${article.basePrice}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuantityButton(
              icon: Icons.remove,
              onPressed: () => _updateQuantity(article.id, -1),
            ),
            const SizedBox(width: 8),
            Text('${_selectedArticles[article.id] ?? 0}'),
            const SizedBox(width: 8),
            _buildQuantityButton(
              icon: Icons.add,
              onPressed: () => _updateQuantity(article.id, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
      onTap: onPressed,
      scaleCoefficient: 0.95,
    );
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

      widget.onArticlesSelected(_selectedArticles);
    });
  }
}
