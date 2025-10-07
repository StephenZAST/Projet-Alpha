import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/user_profile_provider.dart';

/// 📊 Carte de Statistiques de Profil - Alpha Client App
///
/// Widget pour afficher les statistiques utilisateur
/// avec commandes, dépenses et points de fidélité.
class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        final stats = provider.userStats;
        final loyaltyInfo = provider.loyaltyInfo;

        if (stats == null) return const SizedBox.shrink();

        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mes Statistiques',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Grille de statistiques
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                  final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
                  final itemHeight = itemWidth * 0.9; // Ratio plus adaptatif
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: itemWidth / itemHeight,
                    children: [
                      _buildStatCard(
                        context,
                        'Commandes',
                        '${stats.totalOrders}',
                        Icons.shopping_bag_outlined,
                        AppColors.primary,
                        'Total passées',
                      ),
                      _buildStatCard(
                        context,
                        'Dépensé',
                        '€${stats.totalSpent.toStringAsFixed(0)}',
                        Icons.euro_outlined,
                        AppColors.success,
                        'Montant total',
                      ),
                      _buildStatCard(
                        context,
                        'Points',
                        '${loyaltyInfo['points']}',
                        Icons.stars_outlined,
                        AppColors.warning,
                        'Fidélité',
                      ),
                      _buildStatCard(
                        context,
                        'Adresses',
                        '${stats.addressesCount}',
                        Icons.location_on_outlined,
                        AppColors.info,
                        'Configurées',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Informations supplémentaires
              if (stats.lastOrderDate != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        color: AppColors.textSecondary(context),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dernière commande: ${_formatLastOrderDate(stats.lastOrderDate!)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (stats.favoriteService != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Service préféré: ${stats.favoriteService}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 📊 Carte de statistique individuelle
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📅 Formater la date de dernière commande
  String _formatLastOrderDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
