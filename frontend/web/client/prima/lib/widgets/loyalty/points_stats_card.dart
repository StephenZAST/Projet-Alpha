import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class PointsStatsCard extends StatelessWidget {
  final int pointsThisMonth;
  final int totalOrders;
  final int referrals;

  const PointsStatsCard({
    super.key,
    required this.pointsThisMonth,
    required this.totalOrders,
    required this.referrals,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              icon: Icons.calendar_month,
              title: 'Points ce mois',
              value: pointsThisMonth.toString(),
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              icon: Icons.shopping_bag,
              title: 'Commandes totales',
              value: totalOrders.toString(),
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              icon: Icons.people,
              title: 'Parrainages',
              value: referrals.toString(),
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
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: const TextStyle(color: AppColors.gray600)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.gray800,
          ),
        ),
      ],
    );
  }
}
