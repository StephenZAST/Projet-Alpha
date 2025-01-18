import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prima/models/order.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';
import 'package:prima/models/order_status.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (OrderStatus.values.firstWhere((e) => e.name == order.status)) {
      case OrderStatus.PENDING:
      case OrderStatus.COLLECTING:
        return AppColors.warning;
      case OrderStatus.DELIVERED:
        return AppColors.success;
      case OrderStatus.CANCELLED:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: _buildStatusIcon(),
          title: Text(
            'Commande #${order.id.substring(0, 8)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd MMM yyyy - HH:mm', 'fr_FR')
                    .format(order.createdAt),
                style: const TextStyle(color: AppColors.gray600),
              ),
              Text(
                '${order.items?.length ?? 0} articles',
                style: const TextStyle(color: AppColors.gray600),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getStatusLabel(order.status),
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
      onTap: onTap,
      scaleCoefficient: 0.95,
      useCache: false,
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color iconColor;

    switch (order.status) {
      case 'PENDING':
      case 'COLLECTING':
        iconData = Icons.schedule;
        iconColor = AppColors.warning;
        break;
      case 'DELIVERED':
        iconData = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case 'CANCELLED':
        iconData = Icons.cancel;
        iconColor = AppColors.error;
        break;
      default:
        iconData = Icons.local_shipping;
        iconColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'COLLECTING':
        return 'En collecte';
      case 'COLLECTED':
        return 'Collectée';
      case 'PROCESSING':
        return 'En traitement';
      case 'READY':
        return 'Prête';
      case 'DELIVERING':
        return 'En livraison';
      case 'DELIVERED':
        return 'Livrée';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return status;
    }
  }
}
