import '../../models/article.dart';
import '../../models/article_category.dart';

import '../states/article_state.dart';
import '../actions/article_actions.dart';

ArticleState articleReducer(ArticleState state, dynamic action) {
  if (action is LoadCategoriesAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
      articlesByCategory: {},
    );
  }

  if (action is LoadCategoriesSuccessAction) {
    final List<ArticleCategory> categories = List<ArticleCategory>.from(action.categories);
    return state.copyWith(
      categories: categories,
      isLoading: false,
      articlesByCategory: {},
    );
  }

  if (action is LoadCategoriesFailureAction) {
    return state.copyWith(
      error: action.error,
      isLoading: false,
      articlesByCategory: {},
    );
  }

  if (action is LoadArticlesByCategoryAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
      articlesByCategory: {},
    );
  }

  if (action is LoadArticlesByCategorySuccessAction) {
    final Map<String, List<Article>> newArticlesByCategory =
        Map<String, List<Article>>.from(state.articlesByCategory);
    newArticlesByCategory[action.categoryId] = action.articles;

    return state.copyWith(
      articlesByCategory: newArticlesByCategory,
      isLoading: false,
    );
  }

  if (action is LoadArticlesByCategoryFailureAction) {
    return state.copyWith(
      error: action.error,
      isLoading: false,
      articlesByCategory: {},
    );
  }

  return state;
}
