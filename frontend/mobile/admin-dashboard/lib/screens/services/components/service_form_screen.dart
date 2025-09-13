import 'dart:ui';
import 'package:admin/controllers/service_type_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/service_controller.dart';
import '../../../models/service.dart';
import '../../../widgets/shared/glass_button.dart';

class ServiceFormScreen extends StatefulWidget {
  final Service? service;
  ServiceFormScreen({this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  bool isSubmitting = false;
  String? _selectedServiceTypeId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _priceController =
        TextEditingController(text: widget.service?.price.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.service?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();
    final serviceTypeController = Get.find<ServiceTypeController>();
    final isEdit = widget.service != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Préselectionner le type si édition
    if (isEdit && _selectedServiceTypeId == null) {
      _selectedServiceTypeId = widget.service?.serviceTypeId;
    }
    
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
                                isEdit ? 'Modifier le service' : 'Créer un nouveau service',
                                style: AppTextStyles.h3.copyWith(
                                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isEdit 
                                    ? 'Modifiez les informations du service'
                                    : 'Ajoutez un nouveau service à votre catalogue',
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
                              decoration: _inputDecoration('Nom du service', isDark: isDark),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Le nom est requis';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: AppSpacing.md),
                            
                            // Dropdown pour le type de service
                            Obx(() {
                              if (serviceTypeController.isLoading.value) {
                                return Center(child: CircularProgressIndicator());
                              }
                              return DropdownButtonFormField<String>(
                                value: _selectedServiceTypeId,
                                decoration: _inputDecoration('Type de service', isDark: isDark),
                                dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
                                style: TextStyle(
                                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                ),
                                items: serviceTypeController.serviceTypes
                                    .map((type) => DropdownMenuItem(
                                          value: type.id,
                                          child: Row(
                                            children: [
                                              Icon(Icons.category, size: 16, color: AppColors.primary),
                                              SizedBox(width: AppSpacing.xs),
                                              Text(type.name),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedServiceTypeId = val;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le type de service est requis';
                                  }
                                  return null;
                                },
                              );
                            }),
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
                            
                            TextFormField(
                              controller: _priceController,
                              decoration: _inputDecoration('Prix du service', 
                                  isDark: isDark, 
                                  suffixText: 'FCFA',
                                  prefixIcon: Icons.attach_money),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Le prix est requis';
                                }
                                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                                  return 'Prix invalide';
                                }
                                return null;
                              },
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
                                      'Le prix peut varier selon le type de service et les articles associés.',
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
                          onPressed: isSubmitting ? null : () => Get.back(),
                        ),
                        SizedBox(width: AppSpacing.md),
                        GlassButton(
                          label: isEdit ? 'Mettre à jour' : 'Créer le service',
                          variant: GlassButtonVariant.primary,
                          isLoading: isSubmitting,
                          onPressed: isSubmitting ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => isSubmitting = true);
                              try {
                                if (!isEdit) {
                                  await controller.createService(
                                    name: _nameController.text.trim(),
                                    price: double.parse(_priceController.text
                                        .replaceAll(',', '.')),
                                    description: _descriptionController.text.trim(),
                                    typeId: _selectedServiceTypeId,
                                  );
                                } else {
                                  await controller.updateService(
                                    id: widget.service!.id,
                                    name: _nameController.text.trim(),
                                    price: double.parse(_priceController.text
                                        .replaceAll(',', '.')),
                                    description: _descriptionController.text.trim(),
                                    typeId: _selectedServiceTypeId,
                                  );
                                }
                                Get.back();
                              } finally {
                                setState(() => isSubmitting = false);
                              }
                            }
                          },
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
      {bool isDark = false, IconData? prefixIcon, String? suffixText}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixText: suffixText,
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
