import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class OrderStepper extends StatelessWidget {
  final int currentStep;

  const OrderStepper({Key? key, required this.currentStep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStepItem(0, 'Service', Icons.local_laundry_service),
          _buildStepDivider(currentStep > 0),
          _buildStepItem(1, 'Articles', Icons.category),
          _buildStepDivider(currentStep > 1),
          _buildStepItem(2, 'Date', Icons.calendar_today),
          _buildStepDivider(currentStep > 2),
          _buildStepItem(3, 'Résumé', Icons.receipt_long),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, IconData icon) {
    final isCompleted = currentStep > step;
    final isActive = currentStep == step;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryLight.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: isCompleted || isActive
                  ? AppColors.primary
                  : AppColors.gray400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isCompleted || isActive
                    ? AppColors.primary
                    : AppColors.gray400,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDivider(bool isCompleted) {
    return Container(
      width: 30,
      height: 1,
      color: isCompleted ? AppColors.primary : AppColors.gray300,
    );
  }
}
