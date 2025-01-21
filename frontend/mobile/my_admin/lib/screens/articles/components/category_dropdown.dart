import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/category_controller.dart';

class CategoryDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    return Obx(() {
      return DropdownButtonFormField<String>(
        value: controller.selectedCategory.value,
        items: controller.categories
            .map((category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ))
            .toList(),
        onChanged: (value) {
          controller.selectedCategory.value = value!;
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
