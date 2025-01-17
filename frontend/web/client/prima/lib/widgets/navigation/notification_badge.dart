import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final double size;

  const NotificationBadge({
    Key? key,
    required this.count,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
