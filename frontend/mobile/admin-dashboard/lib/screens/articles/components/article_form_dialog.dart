import 'package:admin/controllers/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/article_controller.dart';
import '../../../models/article.dart';
import 'category_dropdown.dart';

class ArticleFormDialog extends StatelessWidget {
  final Article? article;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _premiumPriceController = TextEditingController();
  final _categoryController = TextEditingController();

  ArticleFormDialog({Key? key, this.article}) : super(key: key) {
    if (article != null) {
      _nameController.text = article!.name;
      _descriptionController.text = article!.description ?? '';
      _basePriceController.text = article!.basePrice.toString();
      _premiumPriceController.text = article!.premiumPrice.toString();
      _categoryController.text = article!.categoryId ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();
    final categoryController = Get.find<CategoryController>();

    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  article == null ? 'Nouvel Article' : 'Modifier l\'Article',
                  style: AppTextStyles.h3,
                ),
                SizedBox(height: defaultPadding),

                // Nom
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                ),
                SizedBox(height: defaultPadding),

                // Catégorie
                Obx(() => DropdownButtonFormField<String>(
                      value: _categoryController.text.isEmpty
                          ? null
                          : _categoryController.text,
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(),
                      ),
                      items: categoryController.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        _categoryController.text = value ?? '';
                      },
                      validator: (value) =>
                          value == null ? 'Catégorie requise' : null,
                    )),
                SizedBox(height: defaultPadding),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: defaultPadding),

                // Prix de base
                TextFormField(
                  controller: _basePriceController,
                  decoration: InputDecoration(
                    labelText: 'Prix de base',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Prix requis';
                    if (double.tryParse(value) == null) return 'Prix invalide';
                    return null;
                  },
                ),
                SizedBox(height: defaultPadding),

                // Prix premium
                TextFormField(
                  controller: _premiumPriceController,
                  decoration: InputDecoration(
                    labelText: 'Prix premium',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Prix requis';
                    if (double.tryParse(value) == null) return 'Prix invalide';
                    return null;
                  },
                ),
                SizedBox(height: defaultPadding),

                // Boutons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Annuler'),
                    ),
                    SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(article == null ? 'Créer' : 'Mettre à jour'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = Get.find<ArticleController>();

      if (article == null) {
        controller.createArticle(
          name: _nameController.text,
          categoryId: _categoryController.text,
          description: _descriptionController.text,
          basePrice: double.parse(_basePriceController.text),
          premiumPrice: double.parse(_premiumPriceController.text),
        );
      } else {
        controller.updateArticle(
          article!.id,
          name: _nameController.text,
          categoryId: _categoryController.text,
          description: _descriptionController.text,
          basePrice: double.parse(_basePriceController.text),
          premiumPrice: double.parse(_premiumPriceController.text),
        );
      }
    }
  }
}
