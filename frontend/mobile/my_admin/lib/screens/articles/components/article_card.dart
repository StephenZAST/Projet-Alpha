import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryBg,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              Image.network(article.imageUrl!, height: 100, fit: BoxFit.cover),
            SizedBox(height: defaultPadding),
            Text(
              article.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '\$${article.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Spacer(),
            Text(
              article.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
