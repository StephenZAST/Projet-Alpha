import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class QuantityControl extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;
  final bool mini;

  const QuantityControl({
    Key? key,
    required this.quantity,
    required this.onChanged,
    this.mini = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(mini ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: mini ? 32 : 40,
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: mini ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onPressed: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, VoidCallback? onPressed}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      padding: EdgeInsets.all(mini ? 4 : 8),
      constraints: BoxConstraints(
        minWidth: mini ? 32 : 40,
        minHeight: mini ? 32 : 40,
      ),
      iconSize: mini ? 16 : 20,
      color: onPressed != null ? AppColors.primary : AppColors.gray400,
    );
  }
}
