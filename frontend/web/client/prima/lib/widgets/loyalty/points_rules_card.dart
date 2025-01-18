import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class PointsRulesCard extends StatelessWidget {
  const PointsRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comment gagner des points',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildRuleItem(
              icon: Icons.local_laundry_service,
              title: 'Commandes',
              description: '1 point par tranche de 0.10€ dépensé',
            ),
            const SizedBox(height: 12),
            _buildRuleItem(
              icon: Icons.people,
              title: 'Parrainage',
              description: '1000 points par ami parrainé',
            ),
            const SizedBox(height: 12),
            _buildRuleItem(
              icon: Icons.calendar_month,
              title: 'Commandes récurrentes',
              description: 'Bonus de 500 points par mois',
            ),
            const Divider(height: 24),
            const Text(
              'Utilisation des points',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 12),
            _buildRuleItem(
              icon: Icons.local_offer,
              title: 'Réductions',
              description: '1000 points = 10€ de réduction',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required String title,
    required String description,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
