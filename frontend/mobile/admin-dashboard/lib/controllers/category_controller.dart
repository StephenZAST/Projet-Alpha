import 'package:get/get.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../utils/error_handler.dart';

class CategoryController extends GetxController {
  final categories = <Category>[].obs;
  final isLoading = false.obs;
  final selectedCategory = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      categories.value = await CategoryService.getCategories();
      if (categories.isNotEmpty) {
        selectedCategory.value = categories.first.id;
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory(String name, String description) async {
    try {
      isLoading.value = true;
      await CategoryService.createCategory({
        'name': name,
        'description': description,
      });
      await fetchCategories();
      Get.back();
      Get.snackbar('Success', 'Category created successfully');
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
