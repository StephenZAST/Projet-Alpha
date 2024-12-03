import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

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
        width: 350,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0), // Padding for the group
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '50% de Réduction',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2), // Spacing between children
                    const Text(
                      'Promo Special',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2), // Spacing between children
                    const Text(
                      'Sur vos premiers commandes',
                      style: TextStyle(
                        color: AppColors.gray100,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16), // Spacing between children
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [AppColors.primaryShadow],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(
              'assets/promo-img1.png',
              height: 120,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
