import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../constants.dart';

Widget buildOrderHeader(Order order) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${order.id}',
                style: AppTextStyles.h3,
              ),
              _buildStatusChip(order.status),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Créée le ${order.formattedDate}',
            style: AppTextStyles.bodySmallSecondary,
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatusChip(String status) {
  return Chip(
    label: Text(status),
    backgroundColor: Colors.blue.shade100,
    labelStyle: TextStyle(color: Colors.blue.shade900),
  );
}
