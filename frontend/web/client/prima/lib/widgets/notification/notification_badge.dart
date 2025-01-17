import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  const NotificationBadge({
    Key? key,
    required this.count,
    this.size = 16,
    this.backgroundColor = AppColors.error,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
