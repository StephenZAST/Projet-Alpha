import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/category_controller.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown({
    Key? key,
    this.selectedCategoryId,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(
      builder: (controller) {
        return DropdownButtonFormField<String>(
          value: selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'Catégorie',
            border: OutlineInputBorder(),
          ),
          items: controller.categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Catégorie requise' : null,
        );
      },
    );
  }
}
