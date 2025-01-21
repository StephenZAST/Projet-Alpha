import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/category_controller.dart';
import '../../../models/category.dart';

class CategoryDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    return Obx(() {
      return DropdownButtonFormField<Category>(
        value: controller.selectedCategory.value,
        items: controller.categories
            .map((category) => DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                ))
            .toList(),
        onChanged: (Category? value) {
          controller.setSelectedCategory(value);
        },
        decoration: InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null ? 'Please select a category' : null,
      );
    });
  }
}
