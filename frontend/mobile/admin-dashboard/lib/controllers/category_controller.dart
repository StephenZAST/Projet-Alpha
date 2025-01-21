import 'package:get/get.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../utils/error_handler.dart';

class CategoryController extends GetxController {
  final categories = <Category>[].obs;
  final isLoading = false.obs;
  final selectedCategory = Rxn<Category>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final fetchedCategories = await CategoryService.getCategories();
      categories.value = fetchedCategories;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory(String name, String description) async {
    try {
      isLoading.value = true;
      final newCategory = await CategoryService.createCategory({
        'name': name,
        'description': description,
      });
      categories.add(newCategory);
      Get.back(); // Ferme le dialogue
      Get.snackbar('Success', 'Category created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedCategory(Category? category) {
    selectedCategory.value = category;
  }
}
