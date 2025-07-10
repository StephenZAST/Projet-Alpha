import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import '../../../models/user.dart';
import '../../../models/address.dart';
import '../../../widgets/shared/app_button.dart';
import '../../../controllers/auth_controller.dart';
import 'address_edit_dialog.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final user = controller.selectedUser.value;
      if (user == null) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Détails de l\'utilisateur',
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Get.back(),
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ],
          ),
          Divider(),
          SizedBox(height: AppSpacing.md),
          // Informations de base
          _buildSection(
            'Informations personnelles',
            [
              _buildInfoRow('Nom complet', user.fullName),
              _buildInfoRow('Email', user.email),
              _buildInfoRow('Téléphone', user.phone ?? 'Non renseigné'),
              _buildInfoRow('Rôle', user.role.label),
              _buildInfoRow('Statut', user.isActive ? 'Actif' : 'Inactif'),
              _buildInfoRow(
                'Membre depuis',
                '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
              ),
            ],
            isDark,
          ),
          SizedBox(height: AppSpacing.lg),
          // Points de fidélité
          _buildSection(
            'Programme de fidélité',
            [
              _buildInfoRow('Points actuels', '${user.loyaltyPoints} points'),
            ],
            isDark,
          ),
          if (user.role == UserRole.AFFILIATE) ...[
            SizedBox(height: AppSpacing.lg),
            // Section Affilié
            _buildSection(
              'Programme d\'affiliation',
              [
                _buildInfoRow(
                    'Code d\'affiliation', user.affiliateCode ?? 'N/A'),
                _buildInfoRow(
                  'Commission disponible',
                  user.affiliateBalance != null
                      ? '${user.affiliateBalance!.toStringAsFixed(2)} €'
                      : '0.00 €',
                ),
                _buildInfoRow('Code de parrainage', user.referralCode ?? 'N/A'),
              ],
              isDark,
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          // Section Adresses utilisateur
          _UserAddressesSection(userId: user.id),
          SizedBox(height: AppSpacing.xl),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (user.role == UserRole.AFFILIATE)
                AppButton(
                  label: 'Gérer les commissions',
                  icon: Icons.monetization_on_outlined,
                  variant: AppButtonVariant.teal,
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text('Gestion des commissions'),
                        content: Text('Fonctionnalité à venir'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('Fermer'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              if (user.loyaltyPoints > 0) ...[
                if (user.role == UserRole.AFFILIATE)
                  SizedBox(width: AppSpacing.md),
                AppButton(
                  label: 'Points de fidélité',
                  icon: Icons.star_outline,
                  variant: AppButtonVariant.violet,
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text('Points de fidélité'),
                        content: Text('Fonctionnalité à venir'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('Fermer'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              SizedBox(width: AppSpacing.md),
              AppButton(
                label: user.isActive ? 'Désactiver' : 'Activer',
                icon: user.isActive ? Icons.block : Icons.check_circle_outline,
                variant: user.isActive
                    ? AppButtonVariant.error
                    : AppButtonVariant.success,
                onPressed: () {
                  final authController = Get.find<AuthController>();
                  final currentUser = authController.user.value;
                  // Règle : seul un SUPER_ADMIN peut désactiver un SUPER_ADMIN, un ADMIN ne peut pas désactiver un autre ADMIN
                  if (user.role == UserRole.SUPER_ADMIN &&
                      currentUser?.role != UserRole.SUPER_ADMIN) {
                    controller.showErrorSnackbar('Action non autorisée',
                        'Seul un SUPER ADMIN peut désactiver un SUPER ADMIN.');
                    return;
                  }
                  if (user.role == UserRole.ADMIN &&
                      currentUser?.role != UserRole.SUPER_ADMIN) {
                    controller.showErrorSnackbar('Action non autorisée',
                        'Seul un SUPER ADMIN peut désactiver un ADMIN.');
                    return;
                  }
                  if (!(currentUser?.role == UserRole.ADMIN ||
                      currentUser?.role == UserRole.SUPER_ADMIN)) {
                    controller.showErrorSnackbar('Action non autorisée',
                        'Seuls les ADMIN ou SUPER ADMIN peuvent désactiver un utilisateur.');
                    return;
                  }
                  controller.updateUserStatus(user.id, !user.isActive);
                },
              ),
              if (user.role != UserRole.SUPER_ADMIN) ...[
                SizedBox(width: AppSpacing.md),
                AppButton(
                  label: 'Modifier le rôle',
                  icon: Icons.manage_accounts_outlined,
                  variant: AppButtonVariant.orange,
                  onPressed: () {
                    final authController = Get.find<AuthController>();
                    final currentUser = authController.user.value;
                    // Règle : seul un SUPER_ADMIN peut modifier le rôle d'un SUPER_ADMIN ou d'un ADMIN
                    if (user.role == UserRole.SUPER_ADMIN &&
                        currentUser?.role != UserRole.SUPER_ADMIN) {
                      controller.showErrorSnackbar('Action non autorisée',
                          'Seul un SUPER ADMIN peut modifier le rôle d\'un SUPER ADMIN.');
                      return;
                    }
                    if (user.role == UserRole.ADMIN &&
                        currentUser?.role != UserRole.SUPER_ADMIN) {
                      controller.showErrorSnackbar('Action non autorisée',
                          'Seul un SUPER ADMIN peut modifier le rôle d\'un ADMIN.');
                      return;
                    }
                    if (!(currentUser?.role == UserRole.ADMIN ||
                        currentUser?.role == UserRole.SUPER_ADMIN)) {
                      controller.showErrorSnackbar('Action non autorisée',
                          'Seuls les ADMIN ou SUPER ADMIN peuvent modifier les rôles.');
                      return;
                    }
                    // Ici, ouvrir la modale de modification de rôle (à implémenter)
                    Get.dialog(
                      AlertDialog(
                        title: Text('Modifier le rôle'),
                        content: Text('Fonctionnalité à venir'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('Fermer'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyBold.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.gray800 : AppColors.gray100,
            borderRadius: AppRadius.radiusMD,
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: AppTextStyles.bodyBold,
          ),
        ],
      ),
    );
  }
}

class _UserAddressesSection extends StatefulWidget {
  final String userId;
  const _UserAddressesSection({required this.userId});

  @override
  State<_UserAddressesSection> createState() => _UserAddressesSectionState();
}

class _UserAddressesSectionState extends State<_UserAddressesSection> {
  List<dynamic> addresses = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data =
          await Get.find<UsersController>().getUserAddresses(widget.userId);
      setState(() {
        addresses = data;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des adresses';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildSection(
      'Adresses',
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Adresses', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: Icon(Icons.add_location_alt, color: AppColors.info),
              tooltip: 'Ajouter une adresse',
              onPressed: () async {
                await Get.dialog(AddressEditDialog(
                  userId: widget.userId,
                  onAddressSaved: (address) => _loadAddresses(),
                ));
              },
            ),
          ],
        ),
        if (isLoading) Center(child: CircularProgressIndicator()),
        if (error != null)
          Text(error!, style: TextStyle(color: AppColors.error)),
        if (!isLoading && addresses.isEmpty && error == null)
          Text('Aucune adresse enregistrée'),
        if (!isLoading && addresses.isNotEmpty)
          ...addresses.map((address) => ListTile(
                title: Text(address['name'] ?? ''),
                subtitle: Text(
                    '${address['street'] ?? ''}, ${address['city'] ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColors.primary),
                      tooltip: 'Modifier',
                      onPressed: () async {
                        await Get.dialog(AddressEditDialog(
                          userId: widget.userId,
                          initialAddress: Address.fromJson(address),
                          onAddressSaved: (a) => _loadAddresses(),
                        ));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: AppColors.error),
                      tooltip: 'Supprimer',
                      onPressed: () async {
                        final confirm = await Get.dialog<bool>(
                          AlertDialog(
                            title: Text('Confirmer la suppression'),
                            content: Text(
                                'Voulez-vous vraiment supprimer cette adresse ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: Text('Supprimer',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await Get.find<UsersController>().deleteUserAddress(
                                address['id'], widget.userId);
                            _loadAddresses();
                            Get.rawSnackbar(
                              messageText: Row(
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.white, size: 22),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Adresse supprimée avec succès',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor:
                                  AppColors.success.withOpacity(0.85),
                              borderRadius: 16,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              snackPosition: SnackPosition.TOP,
                              duration: Duration(seconds: 2),
                              boxShadows: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              isDismissible: true,
                              overlayBlur: 2.5,
                            );
                          } catch (e) {
                            Get.rawSnackbar(
                              messageText: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.white, size: 22),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Suppression impossible',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor:
                                  AppColors.error.withOpacity(0.85),
                              borderRadius: 16,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              snackPosition: SnackPosition.TOP,
                              duration: Duration(seconds: 2),
                              boxShadows: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              isDismissible: true,
                              overlayBlur: 2.5,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              )),
      ],
      isDark,
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyBold.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.gray800 : AppColors.gray100,
            borderRadius: AppRadius.radiusMD,
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
