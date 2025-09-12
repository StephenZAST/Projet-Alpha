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
        } else {
          await controller.createCategory(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
          );
        }
        // Le controller ferme déjà le dialog et affiche la notif
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
    final isEdit = widget.category != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLG,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardBgDark
                    : AppColors.cardBgLight,
                borderRadius: AppRadius.radiusLG,
                border: Border.all(
                  color: isDark
                      ? AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity)
                      : AppColors.gray200.withOpacity(AppColors.glassBorderLightOpacity),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                    // En-tête avec icône
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: AppRadius.radiusMD,
                          ),
                          child: Icon(
                            isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit ? 'Modifier la catégorie' : 'Créer une nouvelle catégorie',
                                style: AppTextStyles.h3.copyWith(
                                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isEdit 
                                    ? 'Modifiez les informations de la catégorie'
                                    : 'Organisez vos articles avec une nouvelle catégorie',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Section Informations générales
                    _buildSectionHeader('Informations générales', Icons.info_outline, isDark),
                    SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Nom de la catégorie', isDark: isDark),
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
                      decoration: _inputDecoration('Description (optionnelle)', isDark: isDark),
                      enabled: !_isSubmitting,
                      maxLines: 3,
                    ),
                    
                    if (_errorText != null) ...[
                      SizedBox(height: AppSpacing.md),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: AppRadius.radiusMD,
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, 
                                color: AppColors.error, size: 20),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _errorText!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GlassButton(
                          label: 'Annuler',
                          variant: GlassButtonVariant.secondary,
                          onPressed: _isSubmitting ? null : () => Get.back(),
                        ),
                        SizedBox(width: AppSpacing.md),
                        GlassButton(
                          label: _isSubmitting
                              ? 'Enregistrement...'
                              : (isEdit ? 'Enregistrer' : 'Créer la catégorie'),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: AppSpacing.md),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, {bool isDark = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? AppColors.gray300 : AppColors.gray700,
      ),
      filled: true,
      fillColor: isDark
          ? AppColors.gray800.withOpacity(0.5)
          : AppColors.white.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide(color: AppColors.primary, width: 1),
      ),
    );
  }
}
