import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/article_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../models/article.dart';
import '../../../widgets/shared/glass_button.dart';

class ArticleFormDialog extends StatefulWidget {
  final Article? article;
  const ArticleFormDialog({Key? key, this.article}) : super(key: key);

  @override
  State<ArticleFormDialog> createState() => _ArticleFormDialogState();
}

class _ArticleFormDialogState extends State<ArticleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _premiumPriceController = TextEditingController();
  String? _categoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _nameController.text = widget.article!.name;
      _descriptionController.text = widget.article!.description ?? '';
      _basePriceController.text = widget.article!.basePrice.toString();
      _premiumPriceController.text =
          widget.article!.premiumPrice?.toString() ?? '';
      _categoryId = widget.article!.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _premiumPriceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    final controller = Get.find<ArticleController>();
    try {
      if (widget.article == null) {
        await controller.createArticle(
          name: _nameController.text.trim(),
          categoryId: _categoryId!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          basePrice: double.parse(_basePriceController.text),
          premiumPrice: _premiumPriceController.text.trim().isEmpty
              ? 0.0
              : double.parse(_premiumPriceController.text),
        );
        if (mounted) {
          Get.back();
          Get.snackbar('Succès', 'Article créé avec succès',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        await controller.updateArticle(
          widget.article!.id,
          name: _nameController.text.trim(),
          categoryId: _categoryId!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          basePrice: double.parse(_basePriceController.text),
          premiumPrice: _premiumPriceController.text.trim().isEmpty
              ? 0.0
              : double.parse(_premiumPriceController.text),
        );
        if (mounted) {
          Get.back();
          Get.snackbar('Succès', 'Article mis à jour',
              snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Erreur', e.toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.7),
            colorText: Colors.white);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final isEdit = widget.article != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                                isEdit ? 'Modifier l\'article' : 'Créer un nouvel article',
                                style: AppTextStyles.h3.copyWith(
                                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isEdit 
                                    ? 'Modifiez les informations de l\'article'
                                    : 'Ajoutez un nouvel article à votre catalogue',
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
                    
                    // Contenu scrollable
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Informations générales
                            _buildSectionHeader('Informations générales', Icons.info_outline, isDark),
                            SizedBox(height: AppSpacing.md),
                            
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDecoration('Nom de l\'article', isDark: isDark),
                              validator: (value) =>
                                  value?.trim().isEmpty ?? true ? 'Champ requis' : null,
                            ),
                            SizedBox(height: AppSpacing.md),
                            
                            Obx(() => DropdownButtonFormField<String>(
                                  value: _categoryId,
                                  decoration: _inputDecoration('Catégorie', isDark: isDark),
                                  dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
                                  style: TextStyle(
                                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                  ),
                                  items: categoryController.categories.map((category) {
                                    return DropdownMenuItem(
                                      value: category.id,
                                      child: Row(
                                        children: [
                                          Icon(Icons.folder, size: 16, color: AppColors.primary),
                                          SizedBox(width: AppSpacing.xs),
                                          Text(category.name),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() => _categoryId = value);
                                  },
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Catégorie requise'
                                      : null,
                                )),
                            SizedBox(height: AppSpacing.md),
                            
                            TextFormField(
                              controller: _descriptionController,
                              decoration: _inputDecoration('Description (optionnelle)', isDark: isDark),
                              maxLines: 3,
                            ),
                            
                            SizedBox(height: AppSpacing.xl),
                            
                            // Section Tarification
                            _buildSectionHeader('Tarification', Icons.monetization_on_outlined, isDark),
                            SizedBox(height: AppSpacing.md),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _basePriceController,
                                    decoration: _inputDecoration('Prix de base', 
                                        isDark: isDark, 
                                        prefixIcon: Icons.attach_money),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Prix requis';
                                      final val = double.tryParse(value);
                                      if (val == null || val <= 0) return 'Prix invalide (> 0)';
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: TextFormField(
                                    controller: _premiumPriceController,
                                    decoration: _inputDecoration('Prix premium (optionnel)', 
                                        isDark: isDark, 
                                        prefixIcon: Icons.star_outline),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        final val = double.tryParse(value);
                                        if (val == null || val < 0)
                                          return 'Prix premium invalide';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: AppSpacing.sm),
                            
                            // Info sur les prix
                            Container(
                              padding: EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: AppRadius.radiusMD,
                                border: Border.all(
                                  color: AppColors.info.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, 
                                      color: AppColors.info, size: 20),
                                  SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      'Le prix premium est optionnel et sera utilisé pour les services premium.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GlassButton(
                          label: 'Annuler',
                          variant: GlassButtonVariant.secondary,
                          onPressed: _isLoading ? null : () => Get.back(),
                        ),
                        SizedBox(width: AppSpacing.md),
                        GlassButton(
                          label: isEdit ? 'Mettre à jour' : 'Créer l\'article',
                          variant: GlassButtonVariant.primary,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _submitForm,
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

  InputDecoration _inputDecoration(String label,
      {bool isDark = false, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
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
