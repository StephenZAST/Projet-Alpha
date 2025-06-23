import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/category_controller.dart';
import '../../../models/category.dart';
import '../../../widgets/shared/glass_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: AppRadius.radiusLG,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 480,
            padding: EdgeInsets.all(defaultPadding * 1.5),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.85),
              borderRadius: AppRadius.radiusLG,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category != null
                        ? 'Modifier la catégorie'
                        : 'Nouvelle catégorie',
                    style:
                        AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      border:
                          OutlineInputBorder(borderRadius: AppRadius.radiusSM),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border:
                          OutlineInputBorder(borderRadius: AppRadius.radiusSM),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                    ),
                    enabled: !_isSubmitting,
                    maxLines: 2,
                  ),
                  if (_errorText != null) ...[
                    SizedBox(height: 12),
                    Text(_errorText!, style: TextStyle(color: AppColors.error)),
                  ],
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GlassButton(
                        label: 'Annuler',
                        variant: GlassButtonVariant.secondary,
                        onPressed: () => Get.back(),
                      ),
                      SizedBox(width: AppSpacing.md),
                      GlassButton(
                        label: _isSubmitting
                            ? 'Enregistrement...'
                            : (widget.category != null
                                ? 'Enregistrer'
                                : 'Créer'),
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        variant: GlassButtonVariant.primary,
                        isLoading: _isSubmitting,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
