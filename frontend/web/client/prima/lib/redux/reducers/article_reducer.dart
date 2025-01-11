import '../states/article_state.dart';
import '../actions/article_actions.dart';

ArticleState articleReducer(ArticleState state, dynamic action) {
  if (action is LoadCategoriesAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is LoadCategoriesSuccessAction) {
    return state.copyWith(
      categories: action.categories,
      isLoading: false,
    );
  }

  if (action is LoadCategoriesFailureAction) {
    return state.copyWith(
      error: action.error,
      isLoading: false,
    );
  }

  if (action is LoadArticlesByCategoryAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is LoadArticlesByCategorySuccessAction) {
    final newArticlesByCategory =
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
    );
  }

  return state;
}
