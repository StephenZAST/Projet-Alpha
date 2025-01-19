import 'package:get/get.dart';
import '../models/article.dart';
import '../services/article_service.dart';

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
      // TODO: Implement API call
      articles.value = await ArticleService.getArticles();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createArticle(Article article) async {
    try {
      await ArticleService.createArticle(article);
      fetchArticles();
      Get.back();
      Get.snackbar('Success', 'Article created successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
