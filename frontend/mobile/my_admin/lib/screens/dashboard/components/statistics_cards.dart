import 'package:flutter/material.dart';
import '../../../constants.dart';

class StatisticsCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatisticsCard(
            title: "Total Orders",
            value: "1,234",
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          child: StatisticsCard(
            title: "Total Revenue",
            value: "\$12,345",
            color: AppColors.success,
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          child: StatisticsCard(
            title: "Total Customers",
            value: "567",
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatisticsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: defaultPadding),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
