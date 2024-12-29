import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/widgets/custom_sidebar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      drawer: const CustomSidebar(),
      body: SafeArea(
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
    );
  }
}
