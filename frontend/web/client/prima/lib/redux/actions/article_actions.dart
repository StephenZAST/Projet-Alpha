import '../../models/article.dart';
import '../../models/article_category.dart';

class LoadArticlesAction {}

class LoadArticlesSuccessAction {
  final List<Article> articles;
  LoadArticlesSuccessAction(this.articles);
}

class LoadArticlesFailureAction {
  final String error;
  LoadArticlesFailureAction(this.error);
}

// Actions pour les catégories
class LoadCategoriesAction {}

class LoadCategoriesSuccessAction {
  final List<ArticleCategory> categories;
  LoadCategoriesSuccessAction(this.categories);
}

class LoadCategoriesFailureAction {
  final String error;
  LoadCategoriesFailureAction(this.error);
}

// Actions pour les articles
class LoadArticlesByCategoryAction {
  final String categoryId;
  LoadArticlesByCategoryAction(this.categoryId);
}

class LoadArticlesByCategorySuccessAction {
  final String categoryId;
  final List<Article> articles;
  LoadArticlesByCategorySuccessAction(this.categoryId, this.articles);
}

class LoadArticlesByCategoryFailureAction {
  final String categoryId;
  final String error;
  LoadArticlesByCategoryFailureAction(this.categoryId, this.error);
}
