import 'package:flutter/material.dart';
import '../../../models/category.dart';

class CategoryListTile extends StatelessWidget {
  final Category category;

  const CategoryListTile({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.name),
      subtitle: Text(category.description ?? ''),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        // TODO: Implement navigation to category details
      },
    );
  }
}
