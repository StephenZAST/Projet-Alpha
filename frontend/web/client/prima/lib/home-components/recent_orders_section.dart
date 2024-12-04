import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

class RecentOrdersSectionComponent extends StatelessWidget {
  const RecentOrdersSectionComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Commandes Récentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('Voir plus'),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
          SpringButton(
            SpringButtonType.OnlyScale,
            _buildOrderItem('Commande #1024', 'Nov 15, 2023', true),
            onTap: () {},
            scaleCoefficient: 0.95,
            useCache: false,
          ),
          SpringButton(
            SpringButtonType.OnlyScale,
            _buildOrderItem('Commande #1024', 'Nov 15, 2023', false),
            onTap: () {},
            scaleCoefficient: 0.95,
            useCache: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String orderNumber, String date, bool isWaiting) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWaiting ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: isWaiting ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Text(
            isWaiting ? 'En attente' : 'Terminée',
            style: TextStyle(
              color: isWaiting ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
