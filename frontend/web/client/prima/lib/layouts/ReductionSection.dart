import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

class ReductionSection extends StatelessWidget {
  const ReductionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.primaryShadow],
      ),
      child: SizedBox(
        width: 390,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '50% de Réduction',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Text(
                      'Promo Special',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Text(
                      'Sur vos premiers commandes',
                      style: TextStyle(
                        color: AppColors.gray100,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SpringButton(
                      SpringButtonType.OnlyScale,
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [AppColors.primaryShadow],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Commander',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                      onTap: () {},
                      scaleCoefficient: 0.95,
                      useCache: false,
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(
              'assets/promo-img1.png',
              height: 120,
              width: 150,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
