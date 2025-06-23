import 'dart:ui';
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
    final isEdit = widget.service != null;
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
                    isEdit ? 'Modifier le service' : 'Nouveau service',
                    style:
                        AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom du service',
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
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Prix',
                      border:
                          OutlineInputBorder(borderRadius: AppRadius.radiusSM),
                      suffixText: 'FCFA',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
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
                        onPressed: () => Get.back(),
                      ),
                      SizedBox(width: AppSpacing.md),
                      GlassButton(
                        label: isEdit ? 'Mettre à jour' : 'Créer',
                        variant: GlassButtonVariant.primary,
                        isLoading: isSubmitting,
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => isSubmitting = true);
                                  if (!isEdit) {
                                    await controller.createService(
                                      name: _nameController.text.trim(),
                                      price: double.parse(_priceController.text
                                          .replaceAll(',', '.')),
                                      description:
                                          _descriptionController.text.trim(),
                                    );
                                  } else {
                                    await controller.updateService(
                                      id: widget.service!.id,
                                      name: _nameController.text.trim(),
                                      price: double.parse(_priceController.text
                                          .replaceAll(',', '.')),
                                      description:
                                          _descriptionController.text.trim(),
                                    );
                                  }
                                  setState(() => isSubmitting = false);
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
    );
  }
}
