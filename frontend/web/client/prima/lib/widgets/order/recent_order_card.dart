import 'package:flutter/material.dart';
import 'package:prima/models/order.dart';
import 'package:prima/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:spring_button/spring_button.dart';

class RecentOrderCard extends StatelessWidget {
  final Order order;

  const RecentOrderCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  bool get isInProgress =>
      order.status == 'PENDING' ||
      order.status == 'COLLECTING' ||
      order.status == 'PROCESSING';

  @override
  Widget build(BuildContext context) {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isInProgress
              ? AppColors.warning.withOpacity(0.1)
              : AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isInProgress ? Icons.access_time : Icons.check_circle,
              color: isInProgress ? AppColors.warning : AppColors.success,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commande #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray800,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy', 'fr_FR').format(order.createdAt),
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _getStatusLabel(order.status),
              style: TextStyle(
                color: isInProgress ? AppColors.warning : AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      onTap: () => Navigator.pushNamed(
        context,
        '/order-details',
        arguments: order,
      ),
      scaleCoefficient: 0.95,
      useCache: false,
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'COLLECTING':
        return 'En collecte';
      case 'PROCESSING':
        return 'En traitement';
      case 'DELIVERED':
        return 'Livrée';
      default:
        return status;
    }
  }
}
