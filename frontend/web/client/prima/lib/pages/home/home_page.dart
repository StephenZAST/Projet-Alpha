import 'package:flutter/material.dart';
import 'package:prima/layouts/ReductionSection.dart';
import 'package:prima/layouts/ServiceSection.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/home-components/address_section.dart';
import 'package:prima/home-components/recent_orders_section.dart';
import 'package:prima/home-components/services_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBarComponent(
                title: 'Home',
                onMenuPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              const AddressSectionComponent(),
              const SizedBox(height: 16),
              const ReductionSection(),
              const SizedBox(height: 16),
              const ServicesTitleComponent(),
              const ServiceSection(),
              const RecentOrdersSectionComponent(),
            ],
          ),
        ),
      ),
    );
  }
}
