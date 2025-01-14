import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class QuantityControls extends StatelessWidget {
  final String articleId;
  final int quantity;
  final Function(String, int) onQuantityChanged;

  const QuantityControls({
    Key? key,
    required this.articleId,
    required this.quantity,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: quantity > 0
              ? () => onQuantityChanged(articleId, quantity - 1)
              : null,
          color: quantity > 0 ? AppColors.primary : AppColors.gray400,
        ),
        Text(
          quantity.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onQuantityChanged(articleId, quantity + 1),
          color: AppColors.primary,
        ),
      ],
    );
  }
}
