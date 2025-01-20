import 'package:get/get.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../utils/error_handler.dart';

class CategoryController extends GetxController {
  final categories = <Category>[].obs;
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
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
