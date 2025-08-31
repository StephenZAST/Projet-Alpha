import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:flutter/material.dart';
import 'package:admin/services/user_service.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/widgets/shared/client_selection_dialog.dart';
import 'package:admin/models/user.dart'; // Pour UserRoleExtension

class FlashClientStep extends StatelessWidget {
  final FlashOrderStepperController controller;
  const FlashClientStep({Key? key, required this.controller}) : super(key: key);

  Future<Map<String, dynamic>?> _fetchUser(String userId) async {
    try {
      final user = await UserService.getUserById(userId);
      if (user == null) return null;
      // Ajout d'un log pour debug
      print('[FlashClientStep] Infos utilisateur récupérées: ${user.toJson()}');
      return {
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.label,
        'isActive': user.isActive,
        'loyaltyPoints': user.loyaltyPoints,
      };
    } catch (e) {
      print('[FlashClientStep] Erreur lors de la récupération du client: $e');
      return {'error': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = controller.draft.value;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sélectionner un client',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(draft.userId != null
                  ? 'ID : ${draft.userId}'
                  : 'Aucun client sélectionné'),
              subtitle: draft.userId != null
                  ? FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchUser(draft.userId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Chargement...');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final user = snapshot.data!;
                          if (user['error'] != null) {
                            return Text('Erreur: ${user['error']}');
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Nom : ${user['firstName']} ${user['lastName']}'),
                              Text('Email : ${user['email']}'),
                              if (user['phone'] != null &&
                                  user['phone'].toString().isNotEmpty)
                                Text('Téléphone : ${user['phone']}'),
                              if (user['role'] != null)
                                Text('Rôle : ${user['role']}'),
                              if (user['isActive'] != null)
                                Text(
                                    'Statut : ${user['isActive'] ? 'Actif' : 'Inactif'}'),
                              if (user['loyaltyPoints'] != null)
                                Text(
                                    'Points fidélité : ${user['loyaltyPoints']}'),
                            ],
                          );
                        } else {
                          return Text('Informations client indisponibles');
                        }
                      },
                    )
                  : null,
            ),
          ),
          SizedBox(height: 16),
          GlassButton(
            icon: Icons.search,
            label: 'Changer le client',
            variant: GlassButtonVariant.primary,
            onPressed: () async {
              final selectedClient = await showDialog(
                context: context,
                builder: (ctx) => ClientSelectionDialog(
                  initialSelectedClientId: draft.userId,
                ),
              );
              if (selectedClient != null && selectedClient is String) {
                controller.setDraftField('userId', selectedClient);
              }
            },
          ),
        ],
      ),
    );
  }
}
