import 'package:admin/widgets/shared/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';
import '../../../../../models/user.dart';
import '../create_client_dialog.dart';
import '../client_details_dialog.dart';

class ClientSelectionStep extends StatefulWidget {
  @override
  State<ClientSelectionStep> createState() => _ClientSelectionStepState();
}

class _ClientSelectionStepState extends State<ClientSelectionStep> {
  final searchController = TextEditingController();
  String selectedFilter = 'all'; // Modification ici pour avoir 'all' par défaut
  late final OrdersController controller; // Déclaration du controller

  @override
  void initState() {
    super.initState();
    controller = Get.find<OrdersController>(); // Initialisation du controller
    // Charger tous les clients au démarrage
    controller.loadClients();
  }

  @override
  void dispose() {
    searchController.dispose(); // Cleanup du TextEditingController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sélectionner un client', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.md),
          _buildSearchSection(),
          SizedBox(height: AppSpacing.md),
          Expanded(child: _buildClientList()),
          SizedBox(height: AppSpacing.md),
          _buildCreateClientButton(),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : AppColors.gray50,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Rechercher un client...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              _buildFilterDropdown(),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GlassButton(
                label: 'Réinitialiser',
                variant: GlassButtonVariant.secondary,
                onPressed: () {
                  searchController.clear();
                  controller.filteredClients.clear();
                },
              ),
              SizedBox(width: AppSpacing.sm),
              Obx(() => GlassButton(
                    label: 'Rechercher',
                    icon: Icons.search,
                    variant: GlassButtonVariant.primary,
                    isLoading: controller.isLoadingClients.value,
                    onPressed: () => _performSearch(),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: AppRadius.radiusSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedFilter != 'all') ...[
            Text(
              'Type de recherche :',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
          ],
          DropdownButton<String>(
            value: selectedFilter,
            underline: SizedBox(),
            hint: Text('Type de recherche'),
            items: [
              DropdownMenuItem(value: 'all', child: Text('Tous les clients')),
              DropdownMenuItem(value: 'name', child: Text('Recherche par nom')),
              DropdownMenuItem(
                  value: 'email', child: Text('Recherche par email')),
              DropdownMenuItem(
                  value: 'phone', child: Text('Recherche par téléphone')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedFilter = value;
                  searchController
                      .clear(); // Vider la recherche lors du changement de filtre
                  if (value == 'all') {
                    controller.loadClients();
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    final query = searchController.text.trim();
    if (selectedFilter == 'all') {
      controller.loadClients();
    } else if (query.isNotEmpty) {
      controller.searchClients(query, selectedFilter);
    } else {
      Get.snackbar(
        'Attention',
        'Veuillez entrer un terme de recherche',
        backgroundColor: AppColors.warning.withOpacity(0.1),
        colorText: AppColors.warning,
      );
    }
  }

  Widget _buildClientList() {
    final isDark = Get.isDarkMode;

    return Obx(() {
      if (controller.isLoadingClients.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      }

      final clientsToShow =
          controller.filteredClients.isEmpty && searchController.text.isEmpty
              ? controller.clients
              : controller.filteredClients;

      if (clientsToShow.isEmpty) {
        return _buildEmptyState();
      }

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.white,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: isDark ? AppColors.gray700 : AppColors.gray200,
          ),
        ),
        child: ListView.separated(
          itemCount: clientsToShow.length,
          separatorBuilder: (_, __) => Divider(
            color: isDark ? AppColors.gray700 : AppColors.gray200,
          ),
          itemBuilder: (context, index) {
            return _buildClientCard(context, clientsToShow[index]);
          },
        ),
      );
    });
  }

  Widget _buildClientCard(BuildContext context, User client) {
    return Obx(() {
      final isSelected = controller.selectedClientId.value == client.id;
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
              Text(client.email),
              Text(client.phone ?? 'Pas de téléphone'),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              isSelected ? Icons.check_circle : Icons.check_circle_outline,
              color: isSelected ? AppColors.primary : AppColors.gray400,
            ),
            onPressed: () => controller.selectClient(client.id),
          ),
          onTap: () => Get.dialog(ClientDetailsDialog(client: client)),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 48, color: AppColors.gray400),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Aucun client trouvé',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateClientButton() {
    return TextButton.icon(
      icon: Icon(Icons.person_add),
      label: Text('Créer un nouveau client'),
      onPressed: () => Get.dialog(CreateClientDialog()),
    );
  }
}
