import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class CustomMapMarker extends StatelessWidget {
  const CustomMapMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Stack(
          children: [
            // Cercle externe animé
            Center(
              child: Container(
                width: 60 * value,
                height: 60 * value,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Cercle intermédiaire
            Center(
              child: Container(
                width: 40 * value,
                height: 40 * value,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Marqueur central
            Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
