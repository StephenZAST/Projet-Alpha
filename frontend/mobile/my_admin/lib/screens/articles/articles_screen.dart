import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/article_controller.dart';
import '../../responsive.dart';
import '../components/header.dart';
import 'components/categories_sidebar.dart';
import 'components/articles_grid.dart';
import 'components/article_form_screen.dart';

class ArticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArticleController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Header(title: 'Articles Management'),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 1,
                      child: CategoriesSidebar(),
                    ),
                  Expanded(
                    flex: 4,
                    child: Obx(
                      () => controller.isLoading.value
                          ? Center(child: CircularProgressIndicator())
                          : ArticlesGrid(articles: controller.articles),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => ArticleFormScreen()),
        child: Icon(Icons.add),
      ),
    );
  }
}
