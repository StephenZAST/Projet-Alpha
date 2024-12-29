import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/widgets/custom_sidebar.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      drawer: const CustomSidebar(),
      body: Builder(
        builder: (BuildContext context) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBarComponent(
                  title: 'Parrainage',
                  onMenuPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Programme de Parrainage',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Invitez vos amis et gagnez des réductions',
                        style: TextStyle(
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Votre code de parrainage',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'ZSLAUNDRY2024',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: AppColors.primary),
                                    onPressed: () {
                                      // TODO: Implement copy to clipboard
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // TODO: Add referral statistics and history
              ],
            ),
          ),
        ),
      ),
    );
  }
}
