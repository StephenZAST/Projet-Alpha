import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_profile_controller.dart';
import 'components/profile_header.dart';
import 'components/profile_form.dart';
import 'components/password_change_section.dart';
import 'components/preferences_section.dart';
import '../../constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProfileController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon Profil',
              style: AppTextStyles.h2.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: defaultPadding),
            ProfileHeader(),
            SizedBox(height: defaultPadding),
            ProfileForm(),
            SizedBox(height: defaultPadding * 2),
            PasswordChangeSection(),
            SizedBox(height: defaultPadding * 2),
            PreferencesSection(),
          ],
        ),
      ),
    );
  }
}
