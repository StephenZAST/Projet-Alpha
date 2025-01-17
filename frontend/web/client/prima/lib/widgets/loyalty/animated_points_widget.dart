import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class AnimatedPointsWidget extends StatefulWidget {
  final int points;
  final String label;

  const AnimatedPointsWidget({
    super.key,
    required this.points,
    required this.label,
  });

  @override
  State<AnimatedPointsWidget> createState() => _AnimatedPointsWidgetState();
}

class _AnimatedPointsWidgetState extends State<AnimatedPointsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.points.toDouble())
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            Text(
              _animation.value.toInt().toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              widget.label,
              style: TextStyle(color: AppColors.gray600),
            ),
          ],
        );
      },
    );
  }
}
