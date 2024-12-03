import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class ServiceSection extends StatelessWidget {
  const ServiceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Repassage', 'icon': Icons.iron},
      {'name': 'Lavage', 'icon': Icons.local_laundry_service},
      {'name': 'Nettoyage\nà sec', 'icon': Icons.dry_cleaning},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.primaryShadow],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [AppColors.primaryShadow],
                  ),
                  child: Icon(
                    services[index]['icon'] as IconData,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  services[index]['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}