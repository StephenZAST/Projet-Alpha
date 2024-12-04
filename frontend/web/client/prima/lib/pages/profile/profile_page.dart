import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/custom_sidebar.dart';
import 'package:prima/widgets/custom_bottom_navigation.dart';
import 'package:prima/widgets/page_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4; // Profile tab is selected

  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
            children: const [
              PageHeader(
                title: 'Profile',
                showAddressSection: true,
              ),
              Center(
                child: Text('Profile Page Content'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationItemSelected,
      ),
    );
  }
}
