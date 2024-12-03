import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg package

class AppBarComponent extends StatefulWidget { // Change to StatefulWidget
  const AppBarComponent({Key? key}) : super(key: key);

  @override
  State<AppBarComponent> createState() => _AppBarComponentState();
}

class _AppBarComponentState extends State<AppBarComponent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [AppColors.primaryShadow],
                ),
                child: const Center(
                  child: Text(
                    'ZS',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray800,
                    ),
                  ),
                  Text(
                    'Mr ZAKANE',
                    style: TextStyle(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 35, // Set width to match IconButton size
            height: 35, // Set height to match IconButton size
            child: GestureDetector( // Use GestureDetector for tap events
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) => _controller.reverse(),
              onTapCancel: () => _controller.reverse(),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SvgPicture.asset('assets/menu-icon.svg'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
