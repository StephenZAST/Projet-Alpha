import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio
    show Response; // Ajouter l'import explicite pour Response avec prefix
import '../services/article_service.dart';
import '../models/article.dart';
import '../constants.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ArticleViewMode { grid, list }

class ArticleController extends GetxController {
  final isLoading = false.obs;
  final articles = <Article>[].obs;
  final errorMessage = ''.obs;
  final selectedCategoryId = RxnString();
  final selectedCategory = RxnString(); // Ajout de la propriété manquante
  final viewMode = Rx<ArticleViewMode>(ArticleViewMode.grid);

  @override
  void onInit() {
    super.onInit();
    _loadSavedViewMode();
    fetchArticles();
  }

  Future<void> _loadSavedViewMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString('article_view_mode');
      if (savedMode != null) {
        viewMode.value = ArticleViewMode.values.firstWhere(
          (mode) => mode.toString() == savedMode,
          orElse: () => ArticleViewMode.grid,
        );
      }
    } catch (e) {
      print('Error loading view mode: $e');
    }
  }

  Future<void> toggleViewMode(ArticleViewMode mode) async {
    try {
      viewMode.value = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('article_view_mode', mode.toString());
    } catch (e) {
      print('Error saving view mode: $e');
    }
  }

  Future<void> fetchArticles() async {
    try {
      isLoading.value = true;
      final result = await ArticleService
          .getAllArticles(); // Cette méthode existe maintenant
      articles.value = result;
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

      // Utiliser le service article au lieu d'appeler directement l'API
      await ArticleService.addNewArticle(dto);
      await fetchArticles();

      Get.back();
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

      // Utiliser le service article
      await ArticleService.updateArticle(id: id, dto: dto);
      await fetchArticles();

      Get.back();
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

  Future<void> archiveArticle(String id, String reason) async {
    try {
      isLoading.value = true;
      await ArticleService.archiveArticle(id, reason);
      await fetchArticles();

      Get.back();
      Get.snackbar(
        'Succès',
        'Article archivé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'archivage de l\'article';
      Get.snackbar(
        'Erreur',
        'Impossible d\'archiver l\'article',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteArticle(String id) async {
    try {
      isLoading.value = true;
      await ArticleService.deleteArticle(id);
      await fetchArticles();

      Get.snackbar(
        'Succès',
        'Article supprimé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      final isReferenced = e.toString().contains('referenced');
      errorMessage.value = isReferenced
          ? 'Cet article est utilisé dans des commandes existantes'
          : 'Erreur lors de la suppression';

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchArticles(String query) async {
    try {
      isLoading.value = true;
      if (query.isEmpty) {
        await fetchArticles();
        return;
      }

      final filteredArticles = articles.where((article) {
        final name = article.name.toLowerCase();
        final description = article.description?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();

      articles.value = filteredArticles;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la recherche';
      Get.snackbar(
        'Erreur',
        'Impossible de rechercher les articles',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
