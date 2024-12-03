import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

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
          IconButton(
            icon: Icon(Icons.menu, color: AppColors.gray700),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
