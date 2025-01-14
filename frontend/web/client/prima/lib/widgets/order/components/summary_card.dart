import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onEdit;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.child,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.gray700,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEdit != null) ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Modifier'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
