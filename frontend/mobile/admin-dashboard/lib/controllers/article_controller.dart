import 'package:get/get.dart';
import '../models/article.dart';
import '../services/article_service.dart';
import '../constants.dart';

class ArticleController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final articles = <Article>[].obs;
  final selectedArticle = Rxn<Article>();
  final selectedCategory = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await ArticleService.getAllArticles();
      articles.value = result;
    } catch (e) {
      print('[ArticleController] Error fetching articles: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des articles';

      Get.snackbar(
        'Erreur',
        'Impossible de charger les articles',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createArticle({
    required String name,
    required double basePrice,
    required double premiumPrice,
    required String categoryId,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final dto = ArticleCreateDTO(
        name: name,
        basePrice: basePrice,
        premiumPrice: premiumPrice,
        categoryId: categoryId,
        description: description,
      );

      await ArticleService.createArticle(dto);
      await fetchArticles();

      Get.snackbar(
        'Succès',
        'Article créé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ArticleController] Error creating article: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la création de l\'article';

      Get.snackbar(
        'Erreur',
        'Impossible de créer l\'article',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateArticle(
    String id, {
    String? name,
    String? categoryId,
    String? description,
    double? basePrice,
    double? premiumPrice,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final dto = ArticleUpdateDTO(
        name: name,
        categoryId: categoryId,
        description: description,
        basePrice: basePrice,
        premiumPrice: premiumPrice,
        isActive: isActive,
      );

      await ArticleService.updateArticle(id: id, dto: dto);
      await fetchArticles();

      Get.snackbar(
        'Succès',
        'Article mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ArticleController] Error updating article: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la mise à jour de l\'article';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour l\'article',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteArticle(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await ArticleService.deleteArticle(id);
      await fetchArticles();

      Get.snackbar(
        'Succès',
        'Article supprimé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ArticleController] Error deleting article: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la suppression de l\'article';

      Get.snackbar(
        'Erreur',
        'Impossible de supprimer l\'article',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadImage(String articleId, String imagePath) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await ArticleService.uploadArticleImage(articleId, imagePath);
      await fetchArticles();

      Get.snackbar(
        'Succès',
        'Image téléchargée avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ArticleController] Error uploading image: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du téléchargement de l\'image';

      Get.snackbar(
        'Erreur',
        'Impossible de télécharger l\'image',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedCategory(String? categoryId) {
    selectedCategory.value = categoryId;
    if (categoryId != null) {
      _fetchArticlesByCategory(categoryId);
    } else {
      fetchArticles();
    }
  }

  Future<void> _fetchArticlesByCategory(String categoryId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await ArticleService.getArticlesByCategory(categoryId);
      articles.value = result;
    } catch (e) {
      print('[ArticleController] Error fetching articles by category: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des articles';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchArticles(String query) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (query.isEmpty) {
        await fetchArticles();
        return;
      }

      final results = await ArticleService.searchArticles(query);
      articles.value = results;
    } catch (e) {
      print('[ArticleController] Error searching articles: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la recherche';
    } finally {
      isLoading.value = false;
    }
  }
}
