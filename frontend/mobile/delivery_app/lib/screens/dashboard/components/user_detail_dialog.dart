import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../models/user_search.dart';
import '../../../widgets/shared/glass_container.dart';

/// 👤 Dialog de détails utilisateur pour les livreurs
///
/// Affiche les informations complètes d'un utilisateur
/// avec un design glass cohérent avec l'app
class UserDetailDialog extends StatelessWidget {
  final User user;

  const UserDetailDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassContainer(
        width: 600,
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfoCard(context, isDark),
                    SizedBox(height: AppSpacing.lg),
                    _buildContactCard(context, isDark),
                    SizedBox(height: AppSpacing.lg),
                    _buildMetadataCard(context, isDark),
                    SizedBox(height: AppSpacing.xl),
                    _buildActions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            user.role.color.withOpacity(0.15),
            user.role.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(MobileDimensions.radiusLG),
          topRight: Radius.circular(MobileDimensions.radiusLG),
        ),
      ),
      child: Row(
        children: [
          // Avatar avec icône du rôle
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  user.role.color.withOpacity(0.2),
                  user.role.color.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: user.role.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              user.role.icon,
              size: 35,
              color: user.role.color,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                _buildRoleBadge(),
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

  Widget _buildRoleBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: user.role.color.withOpacity(0.15),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: user.role.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(user.role.icon, color: user.role.color, size: 14),
          SizedBox(width: AppSpacing.xs),
          Text(
            user.role.label,
            style: AppTextStyles.caption.copyWith(
              color: user.role.color,
              fontWeight: FontWeight.w600,
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
          _buildInfoItem(
            context,
            isDark,
            'Prénom',
            user.firstName,
            Icons.person,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoItem(
            context,
            isDark,
            'Nom',
            user.lastName,
            Icons.person,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoItem(
            context,
            isDark,
            'ID Utilisateur',
            user.id,
            Icons.fingerprint,
            copyable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, bool isDark) {
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
                Icons.contact_mail_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Informations de contact',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoItem(
            context,
            isDark,
            'Email',
            user.email,
            Icons.email_outlined,
            copyable: true,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoItem(
            context,
            isDark,
            'Téléphone',
            user.phone ?? 'Non renseigné',
            Icons.phone_outlined,
            copyable: user.phone != null,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(BuildContext context, bool isDark) {
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
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Informations supplémentaires',
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoItem(
            context,
            isDark,
            'Créé le',
            _formatDate(user.createdAt),
            Icons.calendar_today_outlined,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoItem(
            context,
            isDark,
            'Modifié le',
            _formatDate(user.updatedAt),
            Icons.update_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    bool isDark,
    String label,
    String value,
    IconData icon, {
    bool copyable = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
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
            size: 18,
            color: AppColors.primary.withOpacity(0.7),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
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
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.rawSnackbar(
                  messageText: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.white, size: 18),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Copié',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.success.withOpacity(0.85),
                  snackPosition: SnackPosition.BOTTOM,
                  duration: Duration(seconds: 1),
                  borderRadius: 8,
                  margin: EdgeInsets.all(AppSpacing.md),
                );
              },
              child: Tooltip(
                message: 'Copier',
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: AppRadius.radiusSM,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Fermer',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
