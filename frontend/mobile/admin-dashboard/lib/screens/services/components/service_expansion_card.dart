import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/service.dart';
import 'package:admin/models/service_type.dart';
import 'package:get/get.dart';
import 'service_form_screen.dart';
import '../../../controllers/service_controller.dart';

class ServiceExpansionCard extends StatelessWidget {
  final Service service;
  final ServiceType? serviceType;
  const ServiceExpansionCard(
      {Key? key, required this.service, this.serviceType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            // Service Name à gauche
            Expanded(
              flex: 3,
              child: Text(
                service.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Type au centre
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  serviceType?.name ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Prix à droite
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  service.price > 0 ? '${service.price} FCFA' : 'Non renseigné',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 6),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Nom : ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: service.name),
                ])),
                if (service.description != null &&
                    service.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: 'Description : ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: service.description!),
                    ])),
                  ),
                if (serviceType != null)
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: 'Type : ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: serviceType!.name),
                  ])),
                if (serviceType?.description != null &&
                    serviceType!.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: 'Type description : ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: serviceType!.description!),
                    ])),
                  ),
                if (serviceType?.pricingType != null)
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: 'Tarification : ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: serviceType!.pricingType ?? 'Non renseigné'),
                  ])),
                if (serviceType?.requiresWeight == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('Ce service nécessite le poids.',
                        style: TextStyle(color: Colors.blueGrey)),
                  ),
                if (serviceType?.supportsPremium == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('Ce service supporte le premium.',
                        style: TextStyle(color: Colors.blueGrey)),
                  ),
                SizedBox(height: 12),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Disponible : ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          'Oui'), // À adapter si tu as une propriété isAvailable
                ])),
                SizedBox(height: 12),
                Text('Prix',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 6),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Base : ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: service.price > 0
                          ? '${service.price} FCFA'
                          : 'Non renseigné'),
                ])),
                SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          Get.dialog(ServiceFormScreen(service: service)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: Text(
                                'Voulez-vous vraiment supprimer ce service ?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Supprimer',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          controller.deleteService(service.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
