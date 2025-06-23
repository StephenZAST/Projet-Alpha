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
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController =
        TextEditingController(text: widget.category?.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.category != null) {
          await controller.updateCategory(
            id: widget.category!.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
          );
          Get.snackbar('Succès', 'Catégorie modifiée',
              backgroundColor: Colors.white.withOpacity(0.7),
              colorText: AppColors.primary,
              icon: Icon(Icons.check_circle, color: AppColors.success));
        } else {
          await controller.createCategory(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
          );
          Get.snackbar('Succès', 'Catégorie créée',
              backgroundColor: Colors.white.withOpacity(0.7),
              colorText: AppColors.primary,
              icon: Icon(Icons.check_circle, color: AppColors.success));
        }
        Get.back();
      } catch (e) {
        setState(() {
          _errorText = e.toString();
        });
      }
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  InputDecoration _buildInputDecoration(
      String label, String hint, bool isDark) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.white.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(
        color: isDark ? AppColors.textLight : AppColors.textPrimary,
      ),
    );
  }

  void _onPressed() {
    _handleSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.white70,
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.category != null
                    ? 'Modifier la catégorie'
                    : 'Nouvelle catégorie',
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration:
                    _buildInputDecoration('Nom', 'Nom de la catégorie', isDark),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  // TODO: Unicité côté backend ou via controller.categories
                  return null;
                },
                enabled: !_isSubmitting,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(
                    'Description', 'Description (optionnelle)', isDark),
                enabled: !_isSubmitting,
                maxLines: 2,
              ),
              if (_errorText != null) ...[
                SizedBox(height: 12),
                Text(_errorText!, style: TextStyle(color: AppColors.error)),
              ],
              SizedBox(height: 28),
              AppButton(
                label: _isSubmitting
                    ? 'Enregistrement...'
                    : (widget.category != null ? 'Enregistrer' : 'Créer'),
                onPressed: _isSubmitting
                    ? () {}
                    : () {
                        _handleSubmit();
                      },
                variant: AppButtonVariant.primary,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
