import 'package:admin/screens/users/components/users_table.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/users_controller.dart';
import 'components/user_stats_grid.dart';
import 'components/user_filters.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print('[UsersScreen] build: Début de la construction');

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec hauteur flexible
              Flexible(
                flex: 0,
                child: _buildHeader(context, isDark),
              ),
              SizedBox(height: AppSpacing.md),

              // Contenu principal scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistiques
                      UserStatsGrid(),
                      SizedBox(height: AppSpacing.lg),

                      // Filtres et recherche
                      UserFilters(),
                      SizedBox(height: AppSpacing.md),

                      // Table des utilisateurs avec hauteur contrainte
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: GetX<UsersController>(
                          builder: (controller) {
                            print('[UsersScreen] GetX builder: UsersTable');
                            print('[UsersScreen] Users count: ${controller.users.length}');

                            if (controller.isLoading.value) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: AppColors.primary),
                                    SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Chargement des utilisateurs...',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isDark ? AppColors.textLight : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (controller.hasError.value) {
                              return _buildErrorState(context, isDark);
                            }

                            if (controller.users.isEmpty) {
                              return _buildEmptyState(context, isDark);
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

                      // Pagination
                      SizedBox(height: AppSpacing.md),
                      _buildPagination(context, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Utilisateurs',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Obx(() => Text(
                  controller.isLoading.value
                      ? 'Chargement...'
                      : '${controller.totalUsers.value} utilisateur${controller.totalUsers.value > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Exporter',
              icon: Icons.download_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () => _showExportDialog(),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Nouvel utilisateur',
              icon: Icons.person_add_alt_1,
              variant: GlassButtonVariant.primary,
              onPressed: () {
                print('[UsersScreen] Bouton Nouvel utilisateur cliqué');
                Get.dialog(UserCreateDialog(), barrierDismissible: false);
              },
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: () {
                print('[UsersScreen] Bouton Actualiser cliqué');
                controller.fetchUsers();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Erreur de chargement',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            controller.errorMessage.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: 'Réessayer',
            icon: Icons.refresh_outlined,
            variant: GlassButtonVariant.primary,
            onPressed: () => controller.fetchUsers(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.people_outline,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun utilisateur trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            controller.searchQuery.value.isNotEmpty || controller.selectedRole.value != null
                ? 'Aucun utilisateur ne correspond à vos critères de recherche'
                : 'Aucun utilisateur n\'est encore enregistré dans le système',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          if (controller.searchQuery.value.isNotEmpty || controller.selectedRole.value != null)
            GlassButton(
              label: 'Effacer les filtres',
              icon: Icons.clear_all,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                controller.searchQuery.value = '';
                controller.selectedRole.value = null;
                controller.fetchUsers();
              },
            )
          else
            GlassButton(
              label: 'Créer le premier utilisateur',
              icon: Icons.person_add_alt_1,
              variant: GlassButtonVariant.primary,
              onPressed: () => Get.dialog(UserCreateDialog(), barrierDismissible: false),
            ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.totalPages.value <= 1) return SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.gray800.withOpacity(0.5)
              : Colors.white.withOpacity(0.8),
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: isDark
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page ${controller.currentPage.value} sur ${controller.totalPages.value}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                GlassButton(
                  label: '',
                  icon: Icons.chevron_left,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: controller.currentPage.value > 1
                      ? controller.previousPage
                      : null,
                ),
                SizedBox(width: AppSpacing.sm),
                GlassButton(
                  label: '',
                  icon: Icons.chevron_right,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed:
                      controller.currentPage.value < controller.totalPages.value
                          ? controller.nextPage
                          : null,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, size: 48, color: AppColors.primary),
              SizedBox(height: AppSpacing.md),
              Text('Exporter les utilisateurs', style: AppTextStyles.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Fonctionnalité d\'export en cours de développement',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
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
