import 'package:admin/screens/orders/new_order/components/create_client_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/orders_controller.dart';
import 'glass_button.dart';

/// Dialog avancé de sélection client, réutilisable (recherche, sélection, création)
class ClientSelectionDialog extends StatefulWidget {
  /// Si fourni, l'ID du client actuellement sélectionné
  final String? initialSelectedClientId;
  const ClientSelectionDialog({Key? key, this.initialSelectedClientId})
      : super(key: key);

  @override
  State<ClientSelectionDialog> createState() => _ClientSelectionDialogState();
}

class _ClientSelectionDialogState extends State<ClientSelectionDialog> {
  final searchController = TextEditingController();
  late final OrdersController controller;
  String selectedFilter = 'all';
  String? selectedClientId;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OrdersController>();
    selectedClientId = widget.initialSelectedClientId;
    controller.loadClients();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedClient =
        controller.clients.firstWhereOrNull((c) => c.id == selectedClientId);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
      child: Container(
        width: 480,
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sélectionner un client', style: AppTextStyles.h3),
            SizedBox(height: AppSpacing.md),
            if (selectedClient != null) ...[
              Card(
                color: AppColors.primary.withOpacity(0.07),
                child: ListTile(
                  leading: Icon(Icons.person, color: AppColors.primary),
                  title: Text(
                      '${selectedClient.firstName} ${selectedClient.lastName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email : ${selectedClient.email}'),
                      if (selectedClient.phone != null)
                        Text('Téléphone : ${selectedClient.phone}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
            ],
            _buildSearchSection(),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 320,
              child: _buildClientList(),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassButton(
                  icon: Icons.person_add,
                  label: 'Créer un nouveau client',
                  variant: GlassButtonVariant.secondary,
                  onPressed: () => Get.dialog(CreateClientDialog()),
                ),
                Row(
                  children: [
                    GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 8),
                    GlassButton(
                      label: 'Valider',
                      variant: GlassButtonVariant.primary,
                      onPressed: selectedClientId != null
                          ? () => Navigator.of(context).pop(selectedClientId)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Rechercher un client...",
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        DropdownButton<String>(
          value: selectedFilter,
          underline: SizedBox(),
          items: [
            DropdownMenuItem(value: 'all', child: Text('Tous les clients')),
            DropdownMenuItem(value: 'name', child: Text('Nom')),
            DropdownMenuItem(value: 'email', child: Text('Email')),
            DropdownMenuItem(value: 'phone', child: Text('Téléphone')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedFilter = value;
                searchController.clear();
                if (value == 'all') {
                  controller.loadClients();
                }
              });
            }
          },
        ),
        SizedBox(width: AppSpacing.sm),
        GlassButton(
          icon: Icons.search,
          label: 'Rechercher',
          variant: GlassButtonVariant.primary,
          onPressed: _performSearch,
        ),
      ],
    );
  }

  void _performSearch() {
    final query = searchController.text.trim();
    if (selectedFilter == 'all') {
      controller.loadClients();
    } else if (query.isNotEmpty) {
      controller.searchClients(query, selectedFilter);
    } else {
      Get.snackbar('Recherche', 'Veuillez entrer un terme de recherche',
          backgroundColor: AppColors.warning);
    }
  }

  Widget _buildClientList() {
    return Obx(() {
      if (controller.isLoadingClients.value) {
        return Center(child: CircularProgressIndicator());
      }
      final clientsToShow =
          controller.filteredClients.isEmpty && searchController.text.isEmpty
              ? controller.clients
              : controller.filteredClients;
      if (clientsToShow.isEmpty) {
        return Center(child: Text('Aucun client trouvé'));
      }
      return ListView.separated(
        itemCount: clientsToShow.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          final client = clientsToShow[index];
          final isSelected = selectedClientId == client.id;
          return Card(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : null,
            shape: RoundedRectangleBorder(
              side: isSelected
                  ? BorderSide(color: AppColors.primary, width: 2)
                  : BorderSide(color: Colors.transparent),
              borderRadius: AppRadius.radiusMD,
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  '${client.firstName[0]}${client.lastName[0]}'.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.primary,
              ),
              title: Text('${client.firstName} ${client.lastName}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email : ${client.email}'),
                  if (client.phone != null) Text('Téléphone : ${client.phone}'),
                ],
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              selected: isSelected,
              onTap: () {
                setState(() {
                  selectedClientId = client.id;
                });
              },
            ),
          );
        },
      );
    });
  }
}
