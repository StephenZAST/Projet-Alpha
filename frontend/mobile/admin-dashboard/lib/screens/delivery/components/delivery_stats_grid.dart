import 'package:flutter/material.dart';
import '../../../constants.dart';

class DeliveryStatsGrid extends StatelessWidget {
  const DeliveryStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(3, (i) => _buildCard(context, 'Stat ${i + 1}')),
    );
  }

  Widget _buildCard(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          SizedBox(height: AppSpacing.sm),
          Text('0', style: AppTextStyles.h2),
        ],
      ),
    );
  }
}
