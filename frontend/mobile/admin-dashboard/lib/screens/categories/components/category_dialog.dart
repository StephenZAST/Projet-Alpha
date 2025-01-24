import 'package:admin/widgets/shared/app_button.dart';
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

  InputDecoration _buildInputDecoration(
      String label, String hint, bool isDark) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: isDark ? AppColors.textLight : AppColors.textSecondary,
      ),
      hintStyle: TextStyle(
        color: isDark ? AppColors.gray600 : AppColors.gray400,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusSM,
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusSM,
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusSM,
        borderSide: BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: isDark ? AppColors.gray800.withOpacity(0.5) : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = TextStyle(
      color: isDark ? AppColors.textLight : AppColors.textPrimary,
    );

    return Dialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
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
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                    color:
                        isDark ? AppColors.textLight : AppColors.textSecondary,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                style: textStyle,
                decoration: _buildInputDecoration(
                  'Nom',
                  'Entrez le nom de la catégorie',
                  isDark,
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
                style: textStyle,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  'Description',
                  'Entrez une description',
                  isDark,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _iconNameController,
                style: textStyle,
                decoration: _buildInputDecoration(
                  'Icône',
                  'Nom de l\'icône (ex: folder)',
                  isDark,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Annuler',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Obx(() => AppButton(
                        label: 'Enregistrer',
                        onPressed:
                            controller.isLoading.value ? () {} : _handleSubmit,
                        isLoading: controller.isLoading.value,
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
