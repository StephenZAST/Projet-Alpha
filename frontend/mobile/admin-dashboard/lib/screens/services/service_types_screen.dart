import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/services/components/service_type_dialog.dart';
import '../../widgets/shared/glass_button.dart';
import '../../controllers/service_type_controller.dart';
import '../../services/service_type_service.dart';

class ServiceTypesScreen extends StatefulWidget {
  const ServiceTypesScreen({Key? key}) : super(key: key);

  @override
  State<ServiceTypesScreen> createState() => _ServiceTypesScreenState();
}

class _ServiceTypesScreenState extends State<ServiceTypesScreen> {
  final controller = Get.put(ServiceTypeController());

  @override
  void initState() {
    super.initState();
    controller.fetchServiceTypes();
  }

  // Suppression de la logique locale, tout est géré par le contrôleur GetX

  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
              child: Text(message,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16))),
        ],
      ),
      backgroundColor: Colors.green.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4))
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
              child: Text(message,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16))),
        ],
      ),
      backgroundColor: Colors.red.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4))
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Types de service'),
        actions: [
          GlassButton(
            label: 'Ajouter un type',
            variant: GlassButtonVariant.primary,
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => ServiceTypeDialog(),
              );
              if (result != null) {
                final success = await controller.addServiceType(result);
                if (success) {
                  _showSuccessSnackbar('Type de service ajouté avec succès');
                } else {
                  _showErrorSnackbar(controller.errorMessage.value);
                }
              }
            },
          ),
          GlassButton(
            label: 'Voir les désactivés',
            variant: GlassButtonVariant.secondary,
            onPressed: () async {
              // Récupérer tous les services types (actifs et désactivés)
              final allTypes = await ServiceTypeService.getAllServiceTypes(
                  includeInactive: true);
              final inactiveTypes =
                  allTypes.where((t) => t.isActive == false).toList();
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Services types désactivés'),
                  content: SizedBox(
                    width: 400,
                    child: inactiveTypes.isEmpty
                        ? Text('Aucun service type désactivé.')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: inactiveTypes.length,
                            itemBuilder: (context, index) {
                              final type = inactiveTypes[index];
                              return ListTile(
                                title: Text(type.name),
                                subtitle: Text(type.description ?? ''),
                                trailing: GlassButton(
                                  label: 'Réactiver',
                                  variant: GlassButtonVariant.success,
                                  onPressed: () async {
                                    final success = await controller
                                        .updateServiceType(
                                            type.id, {'is_active': true});
                                    if (success) {
                                      Navigator.of(context).pop();
                                      _showSuccessSnackbar(
                                          'Type réactivé avec succès');
                                      controller.fetchServiceTypes();
                                    } else {
                                      _showErrorSnackbar(
                                          controller.errorMessage.value);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Fermer'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: controller.serviceTypes.length,
          itemBuilder: (context, index) {
            final type = controller.serviceTypes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(type.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(type.description ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final result = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) =>
                              ServiceTypeDialog(editType: type),
                        );
                        if (result != null) {
                          final success = await controller.updateServiceType(
                              type.id, result);
                          if (success) {
                            _showSuccessSnackbar(
                                'Type de service modifié avec succès');
                          } else {
                            _showErrorSnackbar(controller.errorMessage.value);
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmer la suppression'),
                            content: Text(
                                'Voulez-vous vraiment supprimer ce type de service ?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('Supprimer',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final success =
                              await controller.deleteServiceType(type.id);
                          if (success) {
                            _showSuccessSnackbar(
                                'Type de service supprimé avec succès');
                          } else {
                            _showErrorSnackbar(controller.errorMessage.value);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
