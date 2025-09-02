import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';
import '../../../constants.dart';

class ActiveFilterIndicator extends StatelessWidget {
  const ActiveFilterIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() {
      // Utiliser selectedRoleString au lieu de selectedRole pour éviter les problèmes de null
      final roleString = controller.selectedRoleString.value;
      final hasSearch = controller.searchQuery.value.trim().isNotEmpty;
      final hasFilters = controller.selectedStatus.value.isNotEmpty ||
          controller.phoneFilter.value.isNotEmpty ||
          controller.startDate.value != null ||
          controller.endDate.value != null;
      
      // Afficher l'indicateur seulement s'il y a des filtres actifs
      if (roleString == 'ALL' && !hasSearch && !hasFilters) {
        return const SizedBox();
      }

      List<Widget> chips = [];

      // Chip pour le rôle
      if (roleString != 'ALL') {
        chips.add(
          Chip(
            label: Text('Rôle: $roleString'),
            onDeleted: () => controller.filterByRole(null),
            backgroundColor: AppColors.primary.withOpacity(0.1),
            deleteIconColor: AppColors.primary,
          ),
        );
      }

      // Chip pour la recherche
      if (hasSearch) {
        chips.add(
          Chip(
            label: Text('Recherche: "${controller.searchQuery.value}"'),
            onDeleted: () => controller.searchUsers(''),
            backgroundColor: AppColors.accent.withOpacity(0.1),
            deleteIconColor: AppColors.accent,
          ),
        );
      }

      // Chip pour les autres filtres
      if (hasFilters) {
        chips.add(
          Chip(
            label: Text('Filtres avancés'),
            onDeleted: () => controller.resetFilters(),
            backgroundColor: AppColors.warning.withOpacity(0.1),
            deleteIconColor: AppColors.warning,
          ),
        );
      }

      if (chips.isEmpty) return const SizedBox();

      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Wrap(
          spacing: 8,
          children: chips,
        ),
      );
    });
  }
}
