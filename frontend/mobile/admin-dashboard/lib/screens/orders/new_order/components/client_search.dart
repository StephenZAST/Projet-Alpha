import 'package:admin/screens/orders/new_order/components/create_client_dialog.dart';
import 'package:admin/widgets/shared/client_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import '../../../../models/user.dart';

class ClientSearch extends StatefulWidget {
  @override
  State<ClientSearch> createState() => _ClientSearchState();
}

class _ClientSearchState extends State<ClientSearch> {
  final controller = Get.find<OrdersController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        SizedBox(height: AppSpacing.md),
        _buildClientList(),
        SizedBox(height: AppSpacing.md),
        _buildCreateClientButton(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ClientSearchBar(
      isLoading: controller.isLoadingClients.value,
      onSearch: (query, filter) {
        controller.searchClients(query, filter);
      },
    );
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
        height: 300,
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
    return Card(
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
          icon: Icon(Icons.check_circle_outline),
          color: AppColors.primary,
          onPressed: () => controller.selectClient(client.id),
        ),
      ),
    );
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
