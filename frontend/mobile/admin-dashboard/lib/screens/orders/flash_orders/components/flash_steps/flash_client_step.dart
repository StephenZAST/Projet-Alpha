import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:flutter/material.dart';
import 'package:admin/widgets/shared/client_search_bar.dart';

class FlashClientStep extends StatelessWidget {
  final FlashOrderStepperController controller;
  const FlashClientStep({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final draft = controller.draft.value;
    // Affichage lecture seule des infos client associées
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client associé',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 12),
            Text('ID : ${draft.userId ?? '-'}'),
            // TODO : Afficher nom, email, téléphone si disponibles dans le modèle ou via une requête
            // Exemple : Text('Nom : ${draft.clientName ?? '-'}'),
            // Text('Email : ${draft.clientEmail ?? '-'}'),
            // Text('Téléphone : ${draft.clientPhone ?? '-'}'),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.search),
              label: Text('Changer le client'),
              onPressed: () async {
                final selectedClient = await showDialog(
                  context: context,
                  builder: (ctx) {
                    String? clientId;
                    return AlertDialog(
                      title: Text('Rechercher un client'),
                      content: SizedBox(
                        width: 400,
                        child: ClientSearchBar(
                          onSearch: (query, filter) async {
                            // TODO: Requête API pour chercher le client
                            // Simuler sélection client
                            clientId =
                                query; // Remplacer par l'ID réel du client sélectionné
                            Navigator.of(ctx).pop(clientId);
                          },
                        ),
                      ),
                    );
                  },
                );
                if (selectedClient != null && selectedClient is String) {
                  controller.setDraftField('userId', selectedClient);
                  // Recharger les adresses pour le nouveau client
                  await controller.refreshAddresses(selectedClient);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
