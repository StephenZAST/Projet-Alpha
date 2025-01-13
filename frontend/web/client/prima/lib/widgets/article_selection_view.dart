import 'package:flutter/material.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/article_category.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:prima/theme/colors.dart';
import 'package:redux/redux.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:prima/redux/actions/article_actions.dart';

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

    // Charger les catégories au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context).dispatch(LoadCategoriesAction());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      onInit: (store) {
        _tabController = TabController(
          length: store.state.articleState.categories.length,
          vsync: this,
        );
      },
      builder: (context, vm) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return Center(child: Text('Error: ${vm.error}'));
        }

        if (vm.categories.isEmpty) {
          return const Center(child: Text('Aucune catégorie disponible'));
        }

        return Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray500,
              tabs: vm.categories
                  .map((category) => Tab(text: category.name))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: vm.categories.map((category) {
                  return _buildCategoryArticles(category, vm);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryArticles(ArticleCategory category, _ViewModel vm) {
    final articles = vm.getArticlesForCategory(category.id);

    if (articles.isEmpty) {
      StoreProvider.of<AppState>(context)
          .dispatch(LoadArticlesByCategoryAction(category.id));
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildArticleItem(article);
      },
    );
  }

  Widget _buildArticleItem(Article article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            SizedBox(
              width: 40,
              child: Text(
                '${_selectedArticles[article.id] ?? 0}',
                textAlign: TextAlign.center,
              ),
            ),
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

class _ViewModel {
  final List<ArticleCategory> categories;
  final Map<String, List<Article>> articlesByCategory;
  final bool isLoading;
  final String? error;

  _ViewModel({
    required this.categories,
    required this.articlesByCategory,
    required this.isLoading,
    this.error,
  });

  List<Article> getArticlesForCategory(String categoryId) {
    return articlesByCategory[categoryId] ?? [];
  }

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      categories: store.state.articleState.categories,
      articlesByCategory: store.state.articleState.articlesByCategory,
      isLoading: store.state.articleState.isLoading,
      error: store.state.articleState.error,
    );
  }
}
