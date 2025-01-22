import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/article_service_controller.dart';
import '../../../controllers/service_controller.dart';
import '../../../models/article.dart';
import '../../../models/article_service.dart';

class ArticleServiceDialog extends StatefulWidget {
  final Article article;
  final ArticleService? articleService;

  const ArticleServiceDialog({
    Key? key,
    required this.article,
    this.articleService,
  }) : super(key: key);

  @override
  _ArticleServiceDialogState createState() => _ArticleServiceDialogState();
}

class _ArticleServiceDialogState extends State<ArticleServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final articleServiceController = Get.find<ArticleServiceController>();
  final serviceController = Get.find<ServiceController>();

  late TextEditingController _priceMultiplierController;
  String? selectedServiceId;

  @override
  void initState() {
    super.initState();
    _priceMultiplierController = TextEditingController(
      text: widget.articleService?.priceMultiplier.toString() ?? '1.0',
    );
    selectedServiceId = widget.articleService?.serviceId;

    // Charger les services si ce n'est pas déjà fait
    if (serviceController.services.isEmpty) {
      serviceController.fetchServices();
    }
  }

  @override
  void dispose() {
    _priceMultiplierController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate() && selectedServiceId != null) {
      final priceMultiplier = double.parse(_priceMultiplierController.text);

      if (widget.articleService != null) {
        // Mise à jour
        await articleServiceController.updateArticleService(
          id: widget.articleService!.id,
          priceMultiplier: priceMultiplier,
        );
      } else {
        // Création
        await articleServiceController.createArticleService(
          articleId: widget.article.id,
          serviceId: selectedServiceId!,
          priceMultiplier: priceMultiplier,
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
                    widget.articleService != null
                        ? 'Modifier le service associé'
                        : 'Ajouter un service',
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
              if (widget.articleService == null) ...[
                // Le service ne peut être modifié qu'à la création
                Obx(() {
                  if (serviceController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: selectedServiceId,
                    items: serviceController.services.map((service) {
                      return DropdownMenuItem(
                        value: service.id,
                        child: Text(service.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedServiceId = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Service',
                      hintText: 'Sélectionnez un service',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusSM,
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le service est requis';
                      }
                      return null;
                    },
                  );
                }),
                SizedBox(height: AppSpacing.md),
              ],
              TextFormField(
                controller: _priceMultiplierController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Multiplicateur de prix',
                  hintText: 'Ex: 1.5 pour +50%',
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
                    return 'Le multiplicateur est requis';
                  }
                  final number = double.tryParse(value);
                  if (number == null) {
                    return 'Valeur invalide';
                  }
                  if (number <= 0) {
                    return 'Le multiplicateur doit être supérieur à 0';
                  }
                  return null;
                },
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
                        onPressed: articleServiceController.isLoading.value
                            ? null
                            : _handleSubmit,
                        child: articleServiceController.isLoading.value
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
