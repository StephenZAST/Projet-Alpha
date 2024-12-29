import 'package:flutter/material.dart';
import 'package:prima/layouts/ReductionSection.dart';
import 'package:prima/layouts/ServiceSection.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/home-components/address_section.dart';
import 'package:prima/home-components/recent_orders_section.dart';
import 'package:prima/home-components/services_title.dart';
import 'package:prima/widgets/custom_sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: const SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBarComponent(),
              AddressSectionComponent(),
              SizedBox(height: 16),
              ReductionSection(),
              SizedBox(height: 16),
              ServicesTitleComponent(),
              ServiceSection(),
              RecentOrdersSectionComponent(),
            ],
          ),
        ),
      ),
    );
  }
}
