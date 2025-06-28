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
                    isEdit ? 'Modifier l\'article' : 'Nouvel article',
                    style:
                        AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom de l\'article',
                      border:
                          OutlineInputBorder(borderRadius: AppRadius.radiusSM),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                    ),
                    validator: (value) =>
                        value?.trim().isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Obx(() => DropdownButtonFormField<String>(
                        value: _categoryId,
                        decoration: InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusSM),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                        ),
                        items: categoryController.categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
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
                    controller: _basePriceController,
                    decoration: InputDecoration(
                      labelText: 'Prix de base',
                      border:
                          OutlineInputBorder(borderRadius: AppRadius.radiusSM),
                      prefixIcon: Icon(Icons.attach_money),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Prix requis';
                      final val = double.tryParse(value);
                      if (val == null || val <= 0) return 'Prix invalide (> 0)';
                      return null;
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _premiumPriceController,
                    decoration: InputDecoration(
                      labelText: 'Prix premium (optionnel)',
                      border:
                          OutlineInputBorder(borderRadius: AppRadius.radiusSM),
                      prefixIcon: Icon(Icons.attach_money),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final val = double.tryParse(value);
                        if (val == null || val < 0)
                          return 'Prix premium invalide';
                      }
                      return null;
                    },
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
                    maxLines: 3,
                  ),
                  SizedBox(height: AppSpacing.xl),
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
                        label: isEdit ? 'Mettre à jour' : 'Créer',
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
    );
  }
}
