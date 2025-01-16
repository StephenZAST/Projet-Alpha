import 'package:flutter/material.dart';
import 'package:prima/layouts/ReductionSection.dart';
import 'package:prima/layouts/ServiceSection.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/home-components/address_section.dart';
import 'package:prima/home-components/recent_orders_section.dart';
import 'package:prima/home-components/services_title.dart';
import 'package:prima/widgets/animated_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<OrderProvider>().loadOrders(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      child: Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: const ValueKey<String>('home_content'),
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
        ),
      ),
    );
  }
}
