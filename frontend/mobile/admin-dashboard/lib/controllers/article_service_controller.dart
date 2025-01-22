import 'package:get/get.dart';
import '../models/article_service.dart';
import '../services/article_service_service.dart';
import '../constants.dart';

class ArticleServiceController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final articleServices = <ArticleService>[].obs;
  final selectedArticleService = Rxn<ArticleService>();

  @override
  void onInit() {
    super.onInit();
    fetchArticleServices();
  }

  Future<void> fetchArticleServices() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await ArticleServiceService.getAllArticleServices();
      articleServices.value = result;
    } catch (e) {
      print('[ArticleServiceController] Error fetching article services: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des services associés';

      Get.snackbar(
        'Erreur',
        'Impossible de charger les services associés',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createArticleService({
    required String articleId,
    required String serviceId,
    required double priceMultiplier,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final dto = ArticleServiceCreateDTO(
        articleId: articleId,
        serviceId: serviceId,
        priceMultiplier: priceMultiplier,
      );

      await ArticleServiceService.createArticleService(dto);
      await fetchArticleServices();

      Get.snackbar(
        'Succès',
        'Service associé créé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ArticleServiceController] Error creating article service: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la création du service associé';

      Get.snackbar(
        'Erreur',
        'Impossible de créer le service associé',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateArticleService({
    required String id,
    required double priceMultiplier,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final dto = ArticleServiceUpdateDTO(
        priceMultiplier: priceMultiplier,
      );

      await ArticleServiceService.updateArticleService(id: id, dto: dto);
      await fetchArticleServices();

      Get.snackbar(
        'Succès',
        'Service associé mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ArticleServiceController] Error updating article service: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la mise à jour du service associé';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le service associé',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteArticleService(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await ArticleServiceService.deleteArticleService(id);
      await fetchArticleServices();

      Get.snackbar(
        'Succès',
        'Service associé supprimé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[ArticleServiceController] Error deleting article service: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la suppression du service associé';

      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le service associé',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ArticleService>> getArticleServicesByArticleId(
      String articleId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      return await ArticleServiceService.getArticleServicesByArticleId(
          articleId);
    } catch (e) {
      print(
          '[ArticleServiceController] Error getting services for article: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des services associés';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ArticleService>> getArticleServicesByServiceId(
      String serviceId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      return await ArticleServiceService.getArticleServicesByServiceId(
          serviceId);
    } catch (e) {
      print(
          '[ArticleServiceController] Error getting articles for service: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des articles associés';
      return [];
    } finally {
      isLoading.value = false;
    }
  }
}
