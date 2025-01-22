import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/service_controller.dart';
import '../../../models/service.dart';

class ServiceFormScreen extends StatefulWidget {
  final Service? service;

  const ServiceFormScreen({Key? key, this.service}) : super(key: key);

  @override
  _ServiceFormScreenState createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<ServiceController>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name);
    _priceController = TextEditingController(
      text: widget.service?.price.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.service?.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final price = double.parse(_priceController.text);

      if (widget.service != null) {
        // Mise à jour
        controller.updateService(
          id: widget.service!.id,
          name: _nameController.text,
          price: price,
          description: _descriptionController.text,
        );
      } else {
        // Création
        controller.createService(
          name: _nameController.text,
          price: price,
          description: _descriptionController.text,
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
                    widget.service != null
                        ? 'Modifier le service'
                        : 'Nouveau service',
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
                  hintText: 'Entrez le nom du service',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
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
                controller: _priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Prix',
                  hintText: 'Entrez le prix du service',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
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
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Entrez une description',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                    borderSide: BorderSide(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
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
