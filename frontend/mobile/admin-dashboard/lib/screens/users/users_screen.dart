import 'package:admin/screens/users/components/users_table.dart';
import 'package:admin/widgets/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/users_controller.dart';
import 'components/user_stats_grid.dart';
import 'components/active_filter_indicator.dart';
import '../../widgets/shared/glass_button.dart';
import 'components/user_create_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late UsersController controller;

  @override
  void initState() {
    super.initState();
    print('[UsersScreen] initState: Initialisation');
    
    // S'assurer que le contrôleur existe et est unique
    if (Get.isRegistered<UsersController>()) {
      controller = Get.find<UsersController>();
    } else {
      controller = Get.put(UsersController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[UsersScreen] build: Début de la construction');
    
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header uniformisé
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Utilisateurs',
                        style: AppTextStyles.h1.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          GlassButton(
                            label: 'Nouvel utilisateur',
                            icon: Icons.person_add_alt_1,
                            variant: GlassButtonVariant.primary,
                            onPressed: () {
                              print(
                                  '[UsersScreen] Bouton Nouvel utilisateur cliqué');
                              Get.dialog(UserCreateDialog(),
                                  barrierDismissible: false);
                            },
                          ),
                          const SizedBox(width: 8),
                          GlassButton(
                            label: 'Rafraîchir',
                            icon: Icons.refresh,
                            variant: GlassButtonVariant.secondary,
                            size: GlassButtonSize.small,
                            onPressed: () {
                              print('[UsersScreen] Bouton Rafraîchir cliqué');
                              controller.fetchUsers();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Indicateur de filtre actif
            ActiveFilterIndicator(),
            SizedBox(height: 16),
            // Stats cards
            UserStatsGrid(),
            SizedBox(height: 16),
            // Tableau des utilisateurs centralisé
            Expanded(
              child: GetX<UsersController>(
                builder: (controller) {
                  print('[UsersScreen] GetX builder: UsersTable');
                  print('[UsersScreen] Users count: ${controller.users.length}');
                  
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (controller.hasError.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: AppColors.error),
                          SizedBox(height: 16),
                          Text(
                            'Erreur de chargement',
                            style: AppTextStyles.h3,
                          ),
                          SizedBox(height: 8),
                          Text(
                            controller.errorMessage.value,
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchUsers(),
                            child: Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return UsersTable(
                    users: controller.users,
                    onUserSelect: (id) {},
                    onEdit: (id) {},
                    onDelete: (id) {},
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            // Pagination en dehors de l'Expanded
            GetX<UsersController>(
              builder: (controller) {
                print('[UsersScreen] GetX builder: PaginationControls');
                return controller.totalPages.value > 1
                    ? PaginationControls(
                        currentPage: controller.currentPage.value,
                        totalPages: controller.totalPages.value,
                        onPrevious: controller.previousPage,
                        onNext: controller.nextPage,
                        itemCount: controller.users.length,
                        totalItems: controller.totalUsers.value,
                        itemsPerPage: controller.itemsPerPage.value,
                        onItemsPerPageChanged: (itemsPerPage) =>
                            controller.setItemsPerPage(
                                itemsPerPage ?? controller.itemsPerPage.value),
                      )
                    : SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}