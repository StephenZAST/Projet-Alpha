import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/article.dart';
import '../../../controllers/article_controller.dart';
import '../../../constants.dart';

class ArticleFormScreen extends StatefulWidget {
  final Article? article;

  const ArticleFormScreen({Key? key, this.article}) : super(key: key);

  @override
  _ArticleFormScreenState createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<ArticleController>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _basePriceController;
  late TextEditingController _premiumPriceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.article?.name);
    _descriptionController =
        TextEditingController(text: widget.article?.description);
    _basePriceController = TextEditingController(
      text: widget.article?.basePrice.toString() ?? '',
    );
    _premiumPriceController = TextEditingController(
      text: widget.article?.premiumPrice.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _premiumPriceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (widget.article != null) {
        // Mise à jour
        controller.updateArticle(
          widget.article!.id,
          name: _nameController.text,
          description: _descriptionController.text,
          basePrice: double.parse(_basePriceController.text),
          premiumPrice: double.parse(_premiumPriceController.text),
          categoryId: controller.selectedCategory.value,
        );
      } else {
        // Création
        if (controller.selectedCategory.value == null) {
          Get.snackbar(
            'Erreur',
            'Veuillez sélectionner une catégorie',
            backgroundColor: AppColors.error,
            colorText: AppColors.textLight,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        controller.createArticle(
          name: _nameController.text,
          description: _descriptionController.text,
          basePrice: double.parse(_basePriceController.text),
          premiumPrice: double.parse(_premiumPriceController.text),
          categoryId: controller.selectedCategory.value!,
        );
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        padding: EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.article != null
                        ? 'Modifier l\'article'
                        : 'Nouvel article',
                    style: AppTextStyles.h2.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Entrez le nom de l\'article',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Entrez une description',
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _basePriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Prix de base',
                        hintText: 'Entrez le prix de base',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le prix est requis';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Prix invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _premiumPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Prix premium',
                        hintText: 'Entrez le prix premium',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le prix premium est requis';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Prix invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Annuler'),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Obx(() => ElevatedButton(
                        onPressed:
                            controller.isLoading.value ? null : _handleSubmit,
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Enregistrer'),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
