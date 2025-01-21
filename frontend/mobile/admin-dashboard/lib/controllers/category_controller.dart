import 'package:get/get.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryController extends GetxController {
  final categories = <Category>[].obs;
  final Rxn<Category> selectedCategory = Rxn<Category>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final List<Category> fetchedCategories =
          await CategoryService.getCategories();
      categories.value = fetchedCategories;
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedCategory(Category? category) {
    selectedCategory.value = category;
  }

  Future<void> createCategory(String name, String description) async {
    try {
      isLoading.value = true;
      final newCategory = await CategoryService.createCategory({
        'name': name,
        'description': description,
      });
      categories.add(newCategory);
      Get.back(); // Close the dialog
      Get.snackbar(
        'Success',
        'Category created successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create category: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
