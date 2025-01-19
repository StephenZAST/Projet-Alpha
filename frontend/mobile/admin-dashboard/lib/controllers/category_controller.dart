import 'package:get/get.dart';
import '../models/article_category.dart';
import '../services/category_service.dart';

class CategoryController extends GetxController {
  final categories = <ArticleCategory>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      categories.value = await CategoryService.getCategories();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory(String name, String? description) async {
    try {
      await CategoryService.createCategory(name, description);
      fetchCategories();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
