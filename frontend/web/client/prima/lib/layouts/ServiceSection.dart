import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

class ServiceSection extends StatelessWidget {
  const ServiceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Repassage', 'image': 'assets/Repassage.png'},
      {'name': 'Lavage', 'image': 'assets/Lavage.png'},
      {'name': 'Nettoyage à sec', 'image': 'assets/Nettoyage_à_sec.png'},
      {'name': 'Pliage', 'image': 'assets/Pliage.png'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: List.generate(services.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SpringButton(
                SpringButtonType.OnlyScale,
                Container(
                  width: 120,
                  height: 180,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        services[index]['image'] as String,
                        width: 75,
                        height: 75,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          services[index]['name'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {},
                scaleCoefficient: 0.95,
                useCache: false,
              ),
            );
          }),
        ),
      ),
    );
  }
}
