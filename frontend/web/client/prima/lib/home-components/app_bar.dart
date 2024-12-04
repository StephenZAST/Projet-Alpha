import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg package
import 'package:spring_button/spring_button.dart'; // Import spring_button package

class AppBarComponent extends StatelessWidget {
  const AppBarComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SpringButton(
                SpringButtonType.OnlyScale,
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
                onTap: () {},
                scaleCoefficient: 0.9,
                useCache: false,
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
          SpringButton(
            SpringButtonType.OnlyScale,
            SizedBox(
              width: 35, // Set width to match IconButton size
              height: 35, // Set height to match IconButton size
              child: SvgPicture.asset('assets/menu-icon.svg'),
            ),
            onTap: () {},
            scaleCoefficient: 0.9,
            useCache: false,
          ),
        ],
      ),
    );
  }
}
