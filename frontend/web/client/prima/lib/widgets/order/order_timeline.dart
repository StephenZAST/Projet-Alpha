import 'package:flutter/material.dart';
import 'package:prima/models/order.dart';
import 'package:prima/theme/colors.dart';
import 'package:intl/intl.dart';

class OrderTimeline extends StatelessWidget {
  final Order order;

  const OrderTimeline({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suivi de commande',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 24),
          _buildTimelineItems(),
        ],
      ),
    );
  }

  Widget _buildTimelineItems() {
    final steps = _getOrderSteps();
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;
        final isActive = _isStepActive(step.status);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimelinePoint(isActive, isLast),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? AppColors.gray900 : AppColors.gray600,
                    ),
                  ),
                  if (step.date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy - HH:mm', 'fr_FR')
                          .format(step.date!),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                  if (!isLast) const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTimelinePoint(bool isActive, bool isLast) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.gray200,
            shape: BoxShape.circle,
          ),
          child: isActive
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 40,
            color: isActive ? AppColors.primary : AppColors.gray200,
          ),
      ],
    );
  }

  bool _isStepActive(String status) {
    final currentStatusIndex = _getStatusIndex(order.status);
    final stepStatusIndex = _getStatusIndex(status);
    return stepStatusIndex <= currentStatusIndex;
  }

  int _getStatusIndex(String status) {
    final statuses = [
      'PENDING',
      'COLLECTING',
      'COLLECTED',
      'PROCESSING',
      'READY',
      'DELIVERING',
      'DELIVERED'
    ];
    return statuses.indexOf(status);
  }

  List<OrderStep> _getOrderSteps() {
    return [
      OrderStep(
        status: 'PENDING',
        label: 'Commande reçue',
        date: order.createdAt,
      ),
      OrderStep(
        status: 'COLLECTING',
        label: 'En cours de collecte',
        date: order.status == 'COLLECTING' ? DateTime.now() : null,
      ),
      // ... autres étapes
    ];
  }
}

class OrderStep {
  final String status;
  final String label;
  final DateTime? date;

  OrderStep({
    required this.status,
    required this.label,
    this.date,
  });
}
