import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/affiliate_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_container.dart';

/// 👤 Écran Profil - Alpha Affiliate App
///
/// Profil utilisateur avec informations affilié et paramètres

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: Consumer2<AuthProvider, AffiliateProvider>(
        builder: (context, authProvider, affiliateProvider, child) {
          return SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              children: [
                _buildProfileHeader(context, authProvider, affiliateProvider),
                const SizedBox(height: 24),
                _buildStatsSection(context, affiliateProvider),
                const SizedBox(height: 24),
                _buildMenuSection(context, authProvider),
                const SizedBox(height: 24),
                _buildLogoutButton(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider,
      AffiliateProvider affiliateProvider) {
    return GlassContainer(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              authProvider.initials,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            authProvider.displayName,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authProvider.email ?? '',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          if (affiliateProvider.profile != null)
            StatusBadge(
              text: affiliateProvider.profile!.statusText,
              color: _getStatusColor(affiliateProvider.profile!.status),
              icon: Icons.verified,
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AffiliateProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Niveau',
            provider.currentLevelName,
            Icons.emoji_events,
            AppColors.accent,
            context,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Commission',
            '${provider.profile?.commissionRate ?? 0}%',
            Icons.percent,
            AppColors.primary,
            context,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      BuildContext context) {
    return GlassContainer(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          'Informations Personnelles',
          Icons.person_outline,
          () => _showComingSoon(context),
        ),
        _buildMenuItem(
          context,
          'Paramètres de Notification',
          Icons.notifications_outlined,
          () => _showComingSoon(context),
        ),
        _buildMenuItem(
          context,
          'Historique des Niveaux',
          Icons.timeline,
          () => _showComingSoon(context),
        ),
        _buildMenuItem(
          context,
          'Support & Aide',
          Icons.help_outline,
          () => _showComingSoon(context),
        ),
        _buildMenuItem(
          context,
          'À Propos',
          Icons.info_outline,
          () => _showAbout(context),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: PremiumButton(
        text: 'Se Déconnecter',
        icon: Icons.logout,
        color: AppColors.error,
        onPressed: () => _showLogoutDialog(context, authProvider),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité bientôt disponible'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLG,
        ),
        title: Text(
          'À Propos',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alpha Affiliate',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Application mobile pour les affiliés d\'Alpha Laundry. Gérez vos commissions, suivez vos filleuls et demandez vos retraits en toute simplicité.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
        actions: [
          PremiumButton(
            text: 'Fermer',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLG,
        ),
        title: Text(
          'Déconnexion',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          PremiumButton(
            text: 'Déconnecter',
            color: AppColors.error,
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              context.read<AffiliateProvider>().logout();
              // TODO: Naviguer vers l'écran de login
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AffiliateStatus status) {
    switch (status) {
      case AffiliateStatus.active:
        return AppColors.success;
      case AffiliateStatus.pending:
        return AppColors.warning;
      case AffiliateStatus.suspended:
        return AppColors.error;
    }
  }
}
