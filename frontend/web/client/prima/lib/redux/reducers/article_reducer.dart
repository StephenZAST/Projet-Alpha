import '../../models/article.dart';
import '../../models/article_category.dart';
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
    // Éviter la conversion de type explicite
    return state.copyWith(
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
    // Éviter la création d'une nouvelle Map
    return state.copyWith(
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
