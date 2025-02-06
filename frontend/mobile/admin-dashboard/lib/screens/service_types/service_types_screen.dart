import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/service_type_controller.dart';
import '../../models/service_type.dart'; // Import correct
import 'components/service_type_card.dart';
import 'components/service_type_form_dialog.dart';

class ServiceTypesScreen extends GetView<ServiceTypeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Types de Services',
                    style: AppTextStyles.h1,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddServiceTypeDialog(context),
                    icon: Icon(Icons.add),
                    label: Text('Nouveau Type'),
                  ),
                ],
              ),
              SizedBox(height: defaultPadding),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: controller.serviceTypes.length,
                    itemBuilder: (context, index) {
                      final type = controller.serviceTypes[index];
                      return ServiceTypeCard(
                        serviceType: type,
                        onEdit: () => _showEditTypeDialog(context, type),
                        onDelete: () => _showDeleteConfirmation(context, type),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddServiceTypeDialog(BuildContext context) {
    Get.dialog(ServiceTypeFormDialog()); // Sans paramètre pour la création
  }

  void _showEditTypeDialog(BuildContext context, ServiceType type) {
    Get.dialog(ServiceTypeFormDialog(
        serviceType: type)); // Avec paramètre pour l'édition
  }

  void _showDeleteConfirmation(BuildContext context, ServiceType type) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${type.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteServiceType(type.id);
              Get.back();
            },
            child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
