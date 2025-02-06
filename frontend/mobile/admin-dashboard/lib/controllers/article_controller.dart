import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/article.dart';
import '../constants.dart';
import 'package:dio/dio.dart' as dio;

class ArticleController extends GetxController {
  final isLoading = false.obs;
  final articles = <Article>[].obs;
  final errorMessage = ''.obs;
  final selectedCategoryId = RxnString();
  final selectedCategory = RxnString(); // Ajout de la propriété manquante

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      isLoading.value = true;
      final dio.Response response = await ApiService().get('/articles');

      if (response.data != null && response.data['data'] != null) {
        final List<Article> articlesList = (response.data['data'] as List)
            .map((item) => Article.fromJson(item))
            .toList();
        articles.value = articlesList;
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des articles';
      Get.snackbar(
        'Erreur',
        'Impossible de charger les articles',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> filterByCategory(String? categoryId) async {
    selectedCategoryId.value = categoryId;
    if (categoryId == null) {
      await fetchArticles();
      return;
    }

    try {
      isLoading.value = true;
      final dio.Response response =
          await ApiService().get('/articles?categoryId=$categoryId');

      if (response.data != null && response.data['data'] != null) {
        final List<Article> filteredArticles = (response.data['data'] as List)
            .map((item) => Article.fromJson(item))
            .toList();
        articles.value = filteredArticles;
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors du filtrage des articles';
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
      final response = await ApiService().get('/articles', queryParameters: {
        'categoryId': categoryId,
      });

      if (response.data != null && response.data['data'] != null) {
        final List<Article> filteredArticles = (response.data['data'] as List)
            .map((item) => Article.fromJson(item))
            .toList();
        articles.value = filteredArticles;
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors du filtrage par catégorie';
      Get.snackbar(
        'Erreur',
        'Impossible de filtrer les articles',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createArticle({
    required String name,
    required String categoryId,
    required double basePrice,
    required double premiumPrice,
    String? description,
  }) async {
    try {
      isLoading.value = true;

      final dto = ArticleCreateDTO(
        name: name,
        categoryId: categoryId,
        description: description,
        basePrice: basePrice,
        premiumPrice: premiumPrice,
      );

      final response = await ApiService().post('/articles', data: dto.toJson());
      await fetchArticles(); // Rafraîchir la liste après création

      Get.back(); // Fermer le formulaire
      Get.snackbar(
        'Succès',
        'Article créé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la création de l\'article';
      Get.snackbar(
        'Erreur',
        'Impossible de créer l\'article',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
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

      final dto = ArticleUpdateDTO(
        name: name,
        categoryId: categoryId,
        description: description,
        basePrice: basePrice,
        premiumPrice: premiumPrice,
        isActive: isActive,
      );

      final response = await ApiService().patch(
        '/articles/$id',
        data: dto.toJson(),
      );

      await fetchArticles(); // Rafraîchir la liste après mise à jour

      Get.back(); // Fermer le formulaire
      Get.snackbar(
        'Succès',
        'Article mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la mise à jour de l\'article';
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour l\'article',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
