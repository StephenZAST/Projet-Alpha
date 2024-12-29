import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: Builder(
        builder: (BuildContext context) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBarComponent(
                  title: 'Offres',
                  onMenuPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                Center(
                  child: Text('Offers Page Content'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
