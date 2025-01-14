import '../../models/article.dart';
import '../states/article_state.dart';
import '../actions/article_actions.dart';

ArticleState articleReducer(ArticleState state, dynamic action) {
  print('ArticleReducer: handling action ${action.runtimeType}');

  if (action is LoadCategoriesAction) {
    print('Loading categories...'); // Log pour debug
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is LoadCategoriesSuccessAction) {
    print('Categories loaded: ${action.categories?.length}');
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
    print('Articles loaded for category ${action.categoryId}');
    final currentArticles =
        Map<String, List<Article>>.from(state.articlesByCategory);
    currentArticles[action.categoryId] = action.articles;

    return state.copyWith(
      articlesByCategory: currentArticles,
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
