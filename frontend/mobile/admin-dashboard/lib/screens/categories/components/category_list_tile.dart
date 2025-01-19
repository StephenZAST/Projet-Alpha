import 'package:flutter/material.dart';
import '../../../models/article_category.dart';

class CategoryListTile extends StatelessWidget {
  final ArticleCategory category;

  const CategoryListTile({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.name),
      subtitle: Text(category.description ?? ''),
      trailing: Text('${category.articlesCount} articles'),
      onTap: () => _showEditDialog(context),
    );
  }

  void _showEditDialog(BuildContext context) {
    // TODO: Implement edit dialog
  }
}
