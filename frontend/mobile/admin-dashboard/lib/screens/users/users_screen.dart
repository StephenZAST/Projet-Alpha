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
import 'components/user_details_dialog.dart';
import 'components/user_edit_dialog.dart';
import '../../models/address.dart';
import '../../services/user_service.dart';

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
                  print(
                      '[UsersScreen] Users count: ${controller.users.length}');

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
                          Icon(Icons.error_outline,
                              size: 64, color: AppColors.error),
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
                    onUserSelect: (id) => _showUserDetails(id),
                    onEdit: (id) => _editUser(id),
                    onDelete: (id) => _deleteUser(id),
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

  /// Affiche les détails d'un utilisateur
  Future<void> _showUserDetails(String userId) async {
    try {
      print('[UsersScreen] Affichage des détails pour l\'utilisateur: $userId');

      // Trouver l'utilisateur dans la liste
      final user = controller.users.firstWhereOrNull((u) => u.id == userId);
      if (user == null) {
        Get.rawSnackbar(
          message: 'Utilisateur introuvable',
          backgroundColor: AppColors.error,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Charger les adresses de l'utilisateur
      List<Address> addresses = [];
      try {
        addresses = await UserService.getUserAddresses(userId);
      } catch (e) {
        print('[UsersScreen] Erreur lors du chargement des adresses: $e');
        // Continuer même si les adresses ne se chargent pas
      }

      // Afficher le dialog des détails
      Get.dialog(
        UserDetailsDialog(
          user: user,
          addresses: addresses,
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      print('[UsersScreen] Erreur lors de l\'affichage des détails: $e');
      Get.rawSnackbar(
        message: 'Erreur lors du chargement des détails',
        backgroundColor: AppColors.error,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Ouvre le dialog d'édition d'un utilisateur
  Future<void> _editUser(String userId) async {
    try {
      print('[UsersScreen] Édition de l\'utilisateur: $userId');

      // Trouver l'utilisateur dans la liste
      final user = controller.users.firstWhereOrNull((u) => u.id == userId);
      if (user == null) {
        Get.rawSnackbar(
          message: 'Utilisateur introuvable',
          backgroundColor: AppColors.error,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Vérifier les permissions
      if (!controller.canManageUser(user)) {
        Get.rawSnackbar(
          message:
              'Vous n\'avez pas les permissions pour modifier cet utilisateur',
          backgroundColor: AppColors.error,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Afficher le dialog d'édition
      Get.dialog(
        UserEditDialog(user: user),
        barrierDismissible: false,
      );
    } catch (e) {
      print(
          '[UsersScreen] Erreur lors de l\'ouverture du dialog d\'édition: $e');
      Get.rawSnackbar(
        message: 'Erreur lors de l\'ouverture du dialog d\'édition',
        backgroundColor: AppColors.error,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Supprime un utilisateur
  Future<void> _deleteUser(String userId) async {
    try {
      print('[UsersScreen] Suppression de l\'utilisateur: $userId');

      // Trouver l'utilisateur dans la liste
      final user = controller.users.firstWhereOrNull((u) => u.id == userId);
      if (user == null) {
        Get.rawSnackbar(
          message: 'Utilisateur introuvable',
          backgroundColor: AppColors.error,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Vérifier les permissions
      if (!controller.canManageUser(user)) {
        Get.rawSnackbar(
          message:
              'Vous n\'avez pas les permissions pour supprimer cet utilisateur',
          backgroundColor: AppColors.error,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Utiliser la méthode du contrôleur qui gère déjà la confirmation
      await controller.deleteUser(userId, '${user.firstName} ${user.lastName}');
    } catch (e) {
      print('[UsersScreen] Erreur lors de la suppression: $e');
      Get.rawSnackbar(
        message: 'Erreur lors de la suppression',
        backgroundColor: AppColors.error,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
