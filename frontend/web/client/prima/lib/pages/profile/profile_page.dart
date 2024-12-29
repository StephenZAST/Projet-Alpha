import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                  title: 'Profile',
                  onMenuPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                Center(
                  child: Text('Profile Page Content'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
