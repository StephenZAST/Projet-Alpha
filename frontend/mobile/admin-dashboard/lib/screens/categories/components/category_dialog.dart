import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/category_controller.dart';
import '../../../models/category.dart';

class CategoryDialog extends StatefulWidget {
  final Category? category;

  const CategoryDialog({Key? key, this.category}) : super(key: key);

  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<CategoryController>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconNameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController =
        TextEditingController(text: widget.category?.description);
    _iconNameController =
        TextEditingController(text: widget.category?.iconName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconNameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (widget.category != null) {
        // Mise à jour
        controller.updateCategory(
          id: widget.category!.id,
          name: _nameController.text,
          description: _descriptionController.text,
          iconName: _iconNameController.text,
        );
      } else {
        // Création
        controller.createCategory(
          name: _nameController.text,
          description: _descriptionController.text,
          iconName: _iconNameController.text,
        );
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      child: Container(
        width: 500,
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
                    widget.category != null
                        ? 'Modifier la catégorie'
                        : 'Nouvelle catégorie',
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
                  hintText: 'Entrez le nom de la catégorie',
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
              TextFormField(
                controller: _iconNameController,
                decoration: InputDecoration(
                  labelText: 'Icône',
                  hintText: 'Nom de l\'icône (ex: folder)',
                ),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
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
