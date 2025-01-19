import 'package:flutter/material.dart';
import '../../../constants.dart';

class StatisticsCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        return StatCard(
          title: _getTitle(index),
          value: _getValue(index),
          icon: _getIcon(index),
          color: _getColor(index),
        );
      },
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return "Total Orders";
      case 1:
        return "Total Revenue";
      case 2:
        return "Active Users";
      case 3:
        return "Pending Orders";
      default:
        return "";
    }
  }

  String _getValue(int index) {
    // Placeholder values, replace with actual data
    switch (index) {
      case 0:
        return "1,234";
      case 1:
        return "\$12,345";
      case 2:
        return "567";
      case 3:
        return "89";
      default:
        return "";
    }
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.shopping_cart;
      case 1:
        return Icons.attach_money;
      case 2:
        return Icons.people;
      case 3:
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  Color _getColor(int index) {
    switch (index) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryBg,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 36),
            Spacer(),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
