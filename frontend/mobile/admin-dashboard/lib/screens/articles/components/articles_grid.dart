import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/article.dart';
import '../../../responsive.dart';
import 'article_card.dart';

class ArticlesGrid extends StatelessWidget {
  final List<Article> articles;

  const ArticlesGrid({Key? key, required this.articles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(defaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isMobile(context) ? 1 : 3,
        childAspectRatio: 1,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
      ),
      itemCount: articles.length,
      itemBuilder: (context, index) => ArticleCard(
        article: articles[index],
      ),
    );
  }
}
