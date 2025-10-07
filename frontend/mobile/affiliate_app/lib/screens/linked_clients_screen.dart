import 'package:affiliate_app/models/affiliate_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/affiliate_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/notification_system.dart';

/// 👥 Écran Clients Liés - Alpha Affiliate App
///
/// Affiche la liste des clients liés à l'affilié avec leurs statistiques

class LinkedClientsScreen extends StatefulWidget {
  const LinkedClientsScreen({Key? key}) : super(key: key);

  @override
  State<LinkedClientsScreen> createState() => _LinkedClientsScreenState();
}

class _LinkedClientsScreenState extends State<LinkedClientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AffiliateProvider>().loadLinkedClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () => context.read<AffiliateProvider>().loadLinkedClients(),
        child: Consumer<AffiliateProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingLinkedClients) {
              return _buildLoadingState();
            }

            if (provider.linkedClientsError != null) {
              return _buildErrorState(provider.linkedClientsError!);
            }

            if (provider.linkedClients.isEmpty) {
              return _buildEmptyState();
            }

            return _buildClientsList(provider.linkedClients);
          },
        ),
      ),
    );
  }

  /// 📱 AppBar avec design glass
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Mes Clients',
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary(context),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showInfoDialog(context),
          icon: Icon(
            Icons.info_outline,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  /// 📋 Liste des clients
  Widget _buildClientsList(List<LinkedClient> clients) {
    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: clients.length + 1, // +1 pour les statistiques
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              _buildStatsHeader(clients),
              const SizedBox(height: 24),
              _buildSectionTitle('Clients Liés (${clients.length})'),
              const SizedBox(height: 16),
            ],
          );
        }

        final client = clients[index - 1];
        return _buildClientCard(client);
      },
    );
  }

  /// 📊 En-tête avec statistiques
  Widget _buildStatsHeader(List<LinkedClient> clients) {
    final totalOrders = clients.fold<int>(0, (sum, client) => sum + client.ordersCount);
    final totalCommissions = clients.fold<double>(0, (sum, client) => sum + client.totalCommissions);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Clients',
            '${clients.length}',
            Icons.people,
            AppColors.info,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Commandes',
            '$totalOrders',
            Icons.shopping_bag,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Mes Gains',
            '${formatNumber(totalCommissions)} FCFA',
            Icons.account_balance_wallet,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  /// 📈 Carte de statistique
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 🏷️ Titre de section
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  /// 👤 Carte client
  Widget _buildClientCard(LinkedClient client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    client.client.initials,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Informations client
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.displayName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        client.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: client.link.isActive 
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.gray400.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    client.link.isActive ? 'Actif' : 'Inactif',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: client.link.isActive ? AppColors.success : AppColors.gray400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Statistiques client
            Row(
              children: [
                _buildClientStat(
                  'Commandes',
                  '${client.ordersCount}',
                  Icons.shopping_bag_outlined,
                ),
                const SizedBox(width: 24),
                _buildClientStat(
                  'Mes Gains',
                  '${formatNumber(client.totalCommissions)} FCFA',
                  Icons.monetization_on_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Dates
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textTertiary(context),
                ),
                const SizedBox(width: 6),
                Text(
                  'Lié depuis le ${_formatDate(client.link.startDate)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 Statistique client
  Widget _buildClientStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔄 État de chargement
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            child: Row(
              children: [
                const SkeletonLoader(width: 48, height: 48, borderRadius: BorderRadius.all(Radius.circular(24))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLoader(width: 150, height: 16),
                      const SizedBox(height: 8),
                      const SkeletonLoader(width: 200, height: 14),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SkeletonLoader(width: 80, height: 12),
                          const SizedBox(width: 24),
                          const SkeletonLoader(width: 100, height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ❌ État d'erreur
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PremiumButton(
                text: 'Réessayer',
                icon: Icons.refresh,
                onPressed: () => context.read<AffiliateProvider>().loadLinkedClients(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.textTertiary(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun client lié',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Partagez votre code affilié pour commencer à gagner des commissions',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PremiumButton(
                text: 'Partager mon code',
                icon: Icons.share,
                onPressed: () => _shareAffiliateCode(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📅 Formatage de date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// 📤 Partager le code affilié
  void _shareAffiliateCode(BuildContext context) {
    final provider = context.read<AffiliateProvider>();
    final code = provider.affiliateCode;

    if (code.isNotEmpty) {
      // TODO: Implémenter le partage système
      NotificationManager().showSuccess(
        context,
        title: 'Code Partagé',
        message: 'Votre code affilié $code a été copié',
      );
    }
  }

  /// ℹ️ Dialog d'information
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: AppColors.info,
              ),
              const SizedBox(height: 16),
              Text(
                'À propos des clients liés',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cette liste affiche tous les clients qui ont utilisé votre code affilié. Vous gagnez des commissions sur leurs commandes selon votre niveau d\'affiliation.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PremiumButton(
                text: 'Compris',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}