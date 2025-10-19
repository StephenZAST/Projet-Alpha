import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class OrderProgressStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps = ['Service', 'Articles', 'Dates', 'Confirmation'];

  OrderProgressStepper({Key? key, required this.currentStep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            return Expanded(
              child: _buildStep(stepIndex),
            );
          }
          return _buildLine(index ~/ 2);
        }),
      ),
    );
  }

  Widget _buildStep(int index) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isCurrent
                ? AppColors.primary
                : AppColors.gray300,
            border: Border.all(
              color: isCurrent ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.lens,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          steps[index],
          style: TextStyle(
            color: isCompleted || isCurrent
                ? AppColors.primary
                : AppColors.gray500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int index) {
    return Expanded(
      child: Container(
        height: 2,
        color: index < currentStep ? AppColors.primary : AppColors.gray300,
      ),
    );
  }
}
