import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../constants.dart';

class CategoryController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final categories = <Category>[].obs;
  final selectedCategory = Rxn<Category>();

  // Ajout pour la sélection multiple
  final selectedCategoryIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    print('[CategoryController] Initializing...');
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      print('[CategoryController] Starting fetchCategories...');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await CategoryService.getAllCategories();
      print('[CategoryController] Categories fetched: ${result.length}');
      categories.value = result;
    } catch (e) {
      print('[CategoryController] Error fetching categories: $e');
      hasError.value = true;
      errorMessage.value = e.toString();

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
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final dto = CategoryCreateDTO(
        name: name,
        description: description,
      );

      await CategoryService.createCategory(dto);
      await fetchCategories();

      Get.closeAllSnackbars();
      Get.rawSnackbar(
        messageText: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Catégorie créée avec succès',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success.withOpacity(0.85),
        borderRadius: 16,
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        boxShadows: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        isDismissible: true,
        overlayBlur: 2.5,
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
  }) async {
    try {
      print('[CategoryController] Starting category update...');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Validation des données
      if (name?.isEmpty ?? true) {
        throw 'Le nom de la catégorie est requis';
      }

      final dto = CategoryUpdateDTO(
        name: name,
        description: description,
      );

      print('[CategoryController] Update DTO: ${dto.toJson()}');
      final updatedCategory =
          await CategoryService.updateCategory(id: id, dto: dto);

      // Mise à jour de la liste locale
      final index = categories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        categories[index] = updatedCategory;
        categories.refresh(); // Force la mise à jour de l'UI
      }

      Get.back(); // Ferme le dialogue de modification

      Get.closeAllSnackbars();
      Get.rawSnackbar(
        messageText: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Catégorie mise à jour avec succès',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success.withOpacity(0.85),
        borderRadius: 16,
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        boxShadows: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        isDismissible: true,
        overlayBlur: 2.5,
      );
    } catch (e) {
      print('[CategoryController] Error updating category: $e');
      hasError.value = true;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la catégorie: ${e.toString()}',
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

  Future<Category?> getCategoryById(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final category = await CategoryService.getCategoryById(id);
      return category;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement de la catégorie';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Category? getCategoryByIdSync(String id) {
    return categories.firstWhereOrNull((cat) => cat.id == id);
  }

  void toggleCategorySelection(String id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
  }

  void clearCategorySelection() {
    selectedCategoryIds.clear();
  }
}
