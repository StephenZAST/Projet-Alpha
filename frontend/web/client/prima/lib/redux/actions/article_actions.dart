import '../../models/article.dart'; // Nouveau modèle à créer
import '../../models/article_category.dart'; // Nouveau modèle à créer

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
