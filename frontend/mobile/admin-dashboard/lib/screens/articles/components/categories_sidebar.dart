import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/article_controller.dart';

class CategoriesSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();

    return Container(
      color: AppColors.secondaryBg,
      child: ListView(
        padding: EdgeInsets.all(defaultPadding),
        children: [
          Text(
            'Categories',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: defaultPadding),
          ...controller.articles.map((article) {
            return ListTile(
              title: Text(article.name),
              onTap: () {
                controller.selectedCategory.value = article.categoryId;
                controller.fetchArticles();
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
