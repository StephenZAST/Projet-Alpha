import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../components/custom_header.dart';
import '../../controllers/service_controller.dart';

class ServicesScreen extends StatelessWidget {
  final controller = Get.find<ServiceController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomHeader(
            title: 'Services',
            actions: [
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Nouveau Service'),
                onPressed: () => _showCreateServiceDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
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
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  SizedBox(height: 4),
                  Text(
                    '${service.price.toStringAsFixed(2)} €',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cleaning_services_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          SizedBox(height: defaultPadding),
          Text(
            'Aucun service',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: defaultPadding / 2),
          ElevatedButton.icon(
            onPressed: () => _showCreateServiceDialog(context),
            icon: Icon(Icons.add),
            label: Text('Ajouter un service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
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
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
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
            child: Text('Créer'),
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
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0;
              final description = descriptionController.text.trim();

              if (name.isNotEmpty && price > 0) {
                controller.updateService(
                  id: service.id,
                  name: name,
                  price: price,
                  description: description.isEmpty ? null : description,
                );
                Get.back();
              }
            },
            child: Text('Mettre à jour'),
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
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteService(service.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
