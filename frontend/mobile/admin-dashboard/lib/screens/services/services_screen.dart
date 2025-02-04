import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../widgets/shared/header.dart';
import '../../widgets/shared/app_button.dart';
import '../../controllers/service_controller.dart';

class ServicesScreen extends StatelessWidget {
  final controller = Get.find<ServiceController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(
            title: 'Services',
            actions: [
              AppButton(
                label: 'Nouveau Service',
                icon: Icons.add,
                onPressed: () => _showCreateServiceDialog(context),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.services.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildServicesList(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: () => controller.fetchServices(),
      child: ListView.builder(
        itemCount: controller.services.length,
        padding: EdgeInsets.symmetric(vertical: defaultPadding),
        itemBuilder: (context, index) {
          final service = controller.services[index];
          return Card(
            margin: EdgeInsets.only(bottom: defaultPadding),
            child: ListTile(
              title: Text(
                service.name,
                style: AppTextStyles.h4,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (service.description != null) ...[
                    SizedBox(height: 4),
                    Text(
                      service.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                  SizedBox(height: 4),
                  Text(
                    service.price != null
                        ? '${service.price!.toStringAsFixed(2)} €'
                        : 'Prix variable',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: service.price != null
                          ? AppColors.primary
                          : AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showEditServiceDialog(context, service),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(context, service),
                    color: AppColors.error,
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cleaning_services_outlined,
            size: 64,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          SizedBox(height: defaultPadding),
          Text(
            'Aucun service',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: defaultPadding / 2),
          AppButton(
            label: 'Ajouter un service',
            icon: Icons.add,
            onPressed: () => _showCreateServiceDialog(context),
          ),
        ],
      ),
    );
  }

  void _showCreateServiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Nouveau Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du service',
                  hintText: 'Entrez le nom du service',
                ),
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Prix',
                  hintText: 'Entrez le prix',
                ),
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Entrez la description',
                ),
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            label: 'Annuler',
            variant: AppButtonVariant.secondary,
            onPressed: () => Get.back(),
          ),
          AppButton(
            label: 'Créer',
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0;
              final description = descriptionController.text.trim();

              if (name.isNotEmpty && price > 0) {
                controller.createService(
                  name: name,
                  price: price,
                  description: description.isEmpty ? null : description,
                );
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, dynamic service) {
    final nameController = TextEditingController(text: service.name);
    final priceController =
        TextEditingController(text: service.price.toString());
    final descriptionController =
        TextEditingController(text: service.description);

    Get.dialog(
      AlertDialog(
        title: Text('Modifier le Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du service',
                  hintText: 'Entrez le nom du service',
                ),
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Prix',
                  hintText: 'Entrez le prix',
                ),
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Entrez la description',
                ),
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            label: 'Annuler',
            variant: AppButtonVariant.secondary,
            onPressed: () => Get.back(),
          ),
          AppButton(
            label: 'Mettre à jour',
            onPressed: () {
              final name = nameController.text.trim();
              final price = priceController.text.isEmpty
                  ? null
                  : double.tryParse(priceController.text);
              final description = descriptionController.text.trim();

              if (name.isNotEmpty && (price == null || price > 0)) {
                controller.updateService(
                  id: service.id,
                  name: name,
                  price: price,
                  description: description.isEmpty ? null : description,
                );
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic service) {
    Get.dialog(
      AlertDialog(
        title: Text('Supprimer le Service'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce service ?'),
        actions: [
          AppButton(
            label: 'Annuler',
            variant: AppButtonVariant.secondary,
            onPressed: () => Get.back(),
          ),
          AppButton(
            label: 'Supprimer',
            variant: AppButtonVariant.error,
            onPressed: () {
              controller.deleteService(service.id);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
