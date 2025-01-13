import 'package:prima/redux/states/app_state.dart';
import 'package:redux/redux.dart';
import '../store.dart';
import '../actions/article_actions.dart';
import '../../services/article_service.dart';
import '../../models/article.dart';
import '../../models/article_category.dart';

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
      final categories = await articleService.getCategories();
      store.dispatch(
          LoadCategoriesSuccessAction(categories as List<ArticleCategory>));
    } catch (e) {
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
      final articles =
          await articleService.getArticlesByCategory(action.categoryId);
      store.dispatch(LoadArticlesByCategorySuccessAction(
        action.categoryId,
        List<Article>.from(articles),
      ));
    } catch (e) {
      store.dispatch(
          LoadArticlesByCategoryFailureAction(action.categoryId, e.toString()));
    }
  }
}
