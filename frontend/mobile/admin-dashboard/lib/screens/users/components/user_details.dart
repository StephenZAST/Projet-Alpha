import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import '../../../models/user.dart';
import '../../../widgets/shared/app_button.dart';

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
                onPressed: () =>
                    controller.updateUserStatus(user.id, !user.isActive),
              ),
              if (user.role != UserRole.SUPER_ADMIN) ...[
                SizedBox(width: AppSpacing.md),
                AppButton(
                  label: 'Modifier le rôle',
                  icon: Icons.manage_accounts_outlined,
                  variant: AppButtonVariant.orange,
                  onPressed: () {
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
