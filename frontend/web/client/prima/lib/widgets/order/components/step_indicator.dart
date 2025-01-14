import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class OrderStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final List<IconData> stepIcons;

  const OrderStepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    required this.stepIcons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(child: _buildDivider((index ~/ 2) < currentStep));
          }
          return _buildStep(index ~/ 2);
        }),
      ),
    );
  }

  Widget _buildStep(int step) {
    final isCompleted = step < currentStep;
    final isActive = step == currentStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isCompleted || isActive ? AppColors.primary : AppColors.gray100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : stepIcons[step],
            color: isCompleted || isActive ? Colors.white : AppColors.gray400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stepTitles[step],
          style: TextStyle(
            color:
                isCompleted || isActive ? AppColors.primary : AppColors.gray500,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isCompleted) {
    return Container(
      height: 2,
      color: isCompleted ? AppColors.primary : AppColors.gray200,
    );
  }
}
