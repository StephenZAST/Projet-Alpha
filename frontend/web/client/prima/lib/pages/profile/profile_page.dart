import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/profile_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppBarComponent(
              title: 'Profile',
              onMenuPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Expanded(
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  if (profileProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (profileProvider.error != null) {
                    return Center(child: Text('Error: ${profileProvider.error}'));
                  }

                  final profile = profileProvider.profile;
                  if (profile == null) {
                    return const Center(child: Text('No profile data'));
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildProfileItem('Name', '${profile['first_name']} ${profile['last_name']}'),
                      _buildProfileItem('Email', profile['email']),
                      _buildProfileItem('Phone', profile['phone']),
                      _buildProfileItem('Address', profile['address']),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.gray800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
