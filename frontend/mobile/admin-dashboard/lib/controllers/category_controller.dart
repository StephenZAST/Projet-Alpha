import 'package:get/get.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../constants.dart';

class CategoryController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final categories = <Category>[].obs;
  final selectedCategory = Rxn<Category>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await CategoryService.getAllCategories();
      categories.value = result;
    } catch (e) {
      print('[CategoryController] Error fetching categories: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des catégories';

      Get.snackbar(
        'Erreur',
        'Impossible de charger les catégories',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory({
    required String name,
    String? description,
    String? iconName,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final dto = CategoryCreateDTO(
        name: name,
        description: description,
        iconName: iconName,
      );

      await CategoryService.createCategory(dto);
      await fetchCategories();

      Get.snackbar(
        'Succès',
        'Catégorie créée avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[CategoryController] Error creating category: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la création de la catégorie';

      Get.snackbar(
        'Erreur',
        'Impossible de créer la catégorie',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory({
    required String id,
    String? name,
    String? description,
    String? iconName,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final dto = CategoryUpdateDTO(
        name: name,
        description: description,
        iconName: iconName,
        isActive: isActive,
      );

      await CategoryService.updateCategory(id: id, dto: dto);
      await fetchCategories();

      Get.snackbar(
        'Succès',
        'Catégorie mise à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[CategoryController] Error updating category: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la mise à jour de la catégorie';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la catégorie',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await CategoryService.deleteCategory(id);
      await fetchCategories();

      Get.snackbar(
        'Succès',
        'Catégorie supprimée avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[CategoryController] Error deleting category: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la suppression de la catégorie';

      Get.snackbar(
        'Erreur',
        'Impossible de supprimer la catégorie',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchCategories(String query) async {
    try {
      if (query.isEmpty) {
        await fetchCategories();
        return;
      }

      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final results = await CategoryService.searchCategories(query);
      categories.value = results;
    } catch (e) {
      print('[CategoryController] Error searching categories: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la recherche';
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(Category? category) {
    selectedCategory.value = category;
  }

  Category? getCategoryById(String id) {
    return categories.firstWhereOrNull((cat) => cat.id == id);
  }
}
