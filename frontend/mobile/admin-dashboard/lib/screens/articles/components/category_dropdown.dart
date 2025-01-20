import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/article_controller.dart';

class CategoryDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      value: controller.selectedCategory.value,
      items: [
        DropdownMenuItem(
          value: '',
          child: Text('Select Category'),
        ),
        // TODO: Add categories from API
      ],
      onChanged: (value) => controller.selectedCategory.value = value ?? '',
      validator: (value) =>
          value?.isEmpty ?? true ? 'Category is required' : null,
    );
  }
}
