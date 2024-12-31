import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppBarComponent(
              title: 'Offres',
              onMenuPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offres disponibles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.gray800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Liste des offres à implémenter
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
