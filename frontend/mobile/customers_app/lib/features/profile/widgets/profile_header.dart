import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/user_profile_provider.dart';

/// 👤 En-tête de Profil - Alpha Client App
///
/// Widget pour afficher les informations principales de l'utilisateur
/// avec avatar, nom et informations de base.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;

        return GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar et informations principales
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        provider.userInitials,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Informations utilisateur
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.userDisplayName,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (user?.email != null)
                          Text(
                            user!.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(provider),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Informations supplémentaires
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      'Membre depuis',
                      _formatMemberSince(user?.createdAt),
                      Icons.calendar_today_outlined,
                      AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      'Téléphone',
                      user?.phone ?? 'Non renseigné',
                      Icons.phone_outlined,
                      AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🏷️ Badge de statut utilisateur
  Widget _buildStatusBadge(UserProfileProvider provider) {
    final loyaltyInfo = provider.loyaltyInfo;
    final tier = loyaltyInfo['tier'] as String;

    Color badgeColor;
    IconData badgeIcon;

    switch (tier.toLowerCase()) {
      case 'gold':
        badgeColor = const Color(0xFFFFD700);
        badgeIcon = Icons.star;
        break;
      case 'silver':
        badgeColor = const Color(0xFFC0C0C0);
        badgeIcon = Icons.star_half;
        break;
      case 'vip':
        badgeColor = const Color(0xFF8B5CF6);
        badgeIcon = Icons.diamond;
        break;
      default:
        badgeColor = const Color(0xFFCD7F32);
        badgeIcon = Icons.star_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            color: badgeColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            tier.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 Carte d'information
  Widget _buildInfoCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 📅 Formater la date d'inscription
  String _formatMemberSince(DateTime? createdAt) {
    if (createdAt == null) return 'Récemment';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 30) {
      return 'Ce mois-ci';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years an${years > 1 ? 's' : ''}';
    }
  }

  /// 🎨 Obtenir la couleur du niveau de fidélité
  Color _getLoyaltyTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'platine':
        return const Color(0xFFE5E7EB); // Platine
      case 'or':
        return const Color(0xFFFCD34D); // Or
      case 'argent':
        return const Color(0xFFD1D5DB); // Argent
      case 'bronze':
      default:
        return const Color(0xFFF59E0B); // Bronze
    }
  }
}
