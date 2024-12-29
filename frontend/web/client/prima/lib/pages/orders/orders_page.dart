import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/home-components/address_section.dart';
import 'package:prima/widgets/custom_sidebar.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      ),
      drawer: const CustomSidebar(),
      body: Builder(
        builder: (BuildContext context) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AppBarComponent(
                      title: 'Commandes',
                      onMenuPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    const AddressSectionComponent(),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Mes Commandes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray800,
                    ),
                  ),
                ),
                // TODO: Add orders list here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
