import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../models/user.dart';
import '../../../models/address.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import '../../../widgets/shared/glass_button.dart';
import 'user_edit_dialog.dart';

class UserDetailsDialog extends StatelessWidget {
  final User user;
  final List<Address> addresses;

  const UserDetailsDialog({
    Key? key,
    required this.user,
    required this.addresses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<UsersController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 700,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusLG,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLG,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.gray900.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: AppRadius.radiusLG,
                border: Border.all(
                  color: isDark 
                      ? AppColors.gray700.withOpacity(0.5)
                      : AppColors.gray200.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isDark),
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserInfoCard(context, isDark),
                          SizedBox(height: AppSpacing.lg),
                          _buildAddressesCard(context, isDark),
                          SizedBox(height: AppSpacing.lg),
                          _buildSubscriptionsCard(context, isDark),
                          SizedBox(height: AppSpacing.xl),
                          _buildActions(context, controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getRoleColor(user.role).withOpacity(0.1),
            _getRoleColor(user.role).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getRoleColor(user.role).withOpacity(0.2),
                  _getRoleColor(user.role).withOpacity(0.1),
                ],
              ),
              borderRadius: AppRadius.radiusLG,
              border: Border.all(
                color: _getRoleColor(user.role).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getRoleIcon(user.role),
              size: 40,
              color: _getRoleColor(user.role),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                _buildRoleBadge(user.role),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      user.isActive ? Icons.check_circle : Icons.cancel,
                      color: user.isActive ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      user.isActive ? 'Actif' : 'Inactif',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: user.isActive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark 
                  ? AppColors.gray800.withOpacity(0.5)
                  : AppColors.gray100.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Informations personnelles',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoGrid(context, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, bool isDark) {
    final infoItems = [
      {'label': 'ID', 'value': user.id, 'icon': Icons.fingerprint},
      {'label': 'Email', 'value': user.email, 'icon': Icons.email_outlined},
      {'label': 'Téléphone', 'value': user.phone ?? 'Non renseigné', 'icon': Icons.phone_outlined},
      {'label': 'Code de parrainage', 'value': user.referralCode ?? 'Aucun', 'icon': Icons.share_outlined},
      {'label': 'Points de fidélité', 'value': '${user.loyaltyPoints} pts', 'icon': Icons.stars_outlined},
      {'label': 'Créé le', 'value': _formatDate(user.createdAt), 'icon': Icons.calendar_today_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: infoItems.length,
      itemBuilder: (context, index) {
        final item = infoItems[index];
        return _buildInfoItem(
          context,
          isDark,
          item['label'] as String,
          item['value'] as String,
          item['icon'] as IconData,
        );
      },
    );
  }

  Widget _buildInfoItem(BuildContext context, bool isDark, String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray900.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: isDark 
              ? AppColors.gray600.withOpacity(0.2)
              : AppColors.gray300.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary.withOpacity(0.7),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Adresses (${addresses.length})',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (addresses.isEmpty)
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.gray900.withOpacity(0.3)
                    : Colors.white.withOpacity(0.6),
                borderRadius: AppRadius.radiusSM,
                border: Border.all(
                  color: isDark 
                      ? AppColors.gray600.withOpacity(0.2)
                      : AppColors.gray300.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    color: AppColors.textMuted,
                    size: 24,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Aucune adresse enregistrée',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: addresses.map((address) => _buildAddressItem(context, isDark, address)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, bool isDark, Address address) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray900.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: address.isDefault 
              ? AppColors.primary.withOpacity(0.3)
              : (isDark 
                  ? AppColors.gray600.withOpacity(0.2)
                  : AppColors.gray300.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: address.isDefault 
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.accent.withOpacity(0.1),
              borderRadius: AppRadius.radiusXS,
            ),
            child: Icon(
              address.isDefault ? Icons.home : Icons.location_on,
              color: address.isDefault ? AppColors.primary : AppColors.accent,
              size: 16,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.name != null && address.name!.isNotEmpty) ...[
                  Text(
                    address.name!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                ],
                Text(
                  address.fullAddress,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (address.isDefault)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusXS,
              ),
              child: Text(
                'Défaut',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: AppColors.orange,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Offres & Abonnements',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.gray900.withOpacity(0.3)
                  : Colors.white.withOpacity(0.6),
              borderRadius: AppRadius.radiusSM,
              border: Border.all(
                color: isDark 
                    ? AppColors.gray600.withOpacity(0.2)
                    : AppColors.gray300.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Aucune offre ou abonnement actif pour le moment.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, UsersController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GlassButton(
          label: 'Fermer',
          icon: Icons.close,
          variant: GlassButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        if (controller.canManageUser(user)) ...[
          SizedBox(width: AppSpacing.md),
          GlassButton(
            label: 'Éditer',
            icon: Icons.edit_outlined,
            variant: GlassButtonVariant.info,
            onPressed: () {
              Navigator.of(context).pop();
              Get.dialog(
                UserEditDialog(user: user),
                barrierDismissible: false,
              );
            },
          ),
          SizedBox(width: AppSpacing.md),
          GlassButton(
            label: 'Supprimer',
            icon: Icons.delete_outline,
            variant: GlassButtonVariant.error,
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteUser(user.id, '${user.firstName} ${user.lastName}');
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final color = _getRoleColor(role);
    final icon = _getRoleIcon(role);
    final label = _getRoleLabel(role);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return AppColors.violet;
      case UserRole.ADMIN:
        return AppColors.primary;
      case UserRole.AFFILIATE:
        return AppColors.orange;
      case UserRole.CLIENT:
        return AppColors.success;
      case UserRole.DELIVERY:
        return AppColors.teal;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return Icons.security;
      case UserRole.ADMIN:
        return Icons.admin_panel_settings;
      case UserRole.AFFILIATE:
        return Icons.handshake_outlined;
      case UserRole.CLIENT:
        return Icons.person_outline;
      case UserRole.DELIVERY:
        return Icons.delivery_dining_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return 'Super Admin';
      case UserRole.ADMIN:
        return 'Admin';
      case UserRole.AFFILIATE:
        return 'Affilié';
      case UserRole.CLIENT:
        return 'Client';
      case UserRole.DELIVERY:
        return 'Livreur';
      default:
        return 'Inconnu';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}