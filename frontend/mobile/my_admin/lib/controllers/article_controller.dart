import 'package:get/get.dart';
import '../models/article.dart';
import '../services/article_service.dart';
import '../utils/error_handler.dart';

class ArticleController extends GetxController {
  final articles = <Article>[].obs;
  final isLoading = false.obs;
  final selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    isLoading.value = true;
    try {
      articles.value = await ArticleService.getArticles();
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createArticle(Map<String, dynamic> data) async {
    try {
      await ArticleService.createArticle(data);
      fetchArticles();
      Get.back();
      Get.snackbar('Success', 'Article created successfully');
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }
}
