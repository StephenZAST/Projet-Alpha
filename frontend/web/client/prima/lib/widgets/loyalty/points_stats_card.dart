import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class PointsStatsCard extends StatelessWidget {
  final int pointsThisMonth;
  final int totalOrders;
  final int referrals;

  const PointsStatsCard({
    Key? key,
    required this.pointsThisMonth,
    required this.totalOrders,
    required this.referrals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vos statistiques',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.calendar_month,
                  title: 'Ce mois',
                  value: '$pointsThisMonth pts',
                  color: AppColors.primary,
                ),
                _buildStatItem(
                  icon: Icons.shopping_bag,
                  title: 'Commandes',
                  value: '$totalOrders',
                  color: AppColors.success,
                ),
                _buildStatItem(
                  icon: Icons.people,
                  title: 'Parrainages',
                  value: '$referrals',
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.gray600,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
