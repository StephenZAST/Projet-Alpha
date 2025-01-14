import 'package:prima/redux/states/app_state.dart';
import 'package:redux/redux.dart';
import '../actions/article_actions.dart';
import '../../services/article_service.dart';
import '../../models/article.dart';

class ArticleMiddleware {
  final ArticleService articleService;

  ArticleMiddleware(this.articleService);

  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, LoadCategoriesAction>(_handleLoadCategories),
      TypedMiddleware<AppState, LoadArticlesByCategoryAction>(
          _handleLoadArticlesByCategory),
    ];
  }

  void _handleLoadCategories(
    Store<AppState> store,
    LoadCategoriesAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      print('Fetching categories...');
      final categories = await articleService.getCategories();
      print('Categories fetched: ${categories.length}');
      store.dispatch(LoadCategoriesSuccessAction(categories));
    } catch (e) {
      print('Error loading categories: $e');
      store.dispatch(LoadCategoriesFailureAction(e.toString()));
    }
  }

  void _handleLoadArticlesByCategory(
    Store<AppState> store,
    LoadArticlesByCategoryAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      print('Fetching articles for category ${action.categoryId}...');
      final articles =
          await articleService.getArticlesByCategory(action.categoryId);
      print(
          'Articles fetched for category ${action.categoryId}: ${articles.length}');
      store.dispatch(LoadArticlesByCategorySuccessAction(
        action.categoryId,
        List<Article>.from(articles),
      ));
    } catch (e) {
      print('Error loading articles for category ${action.categoryId}: $e');
      store.dispatch(
          LoadArticlesByCategoryFailureAction(action.categoryId, e.toString()));
    }
  }
}
