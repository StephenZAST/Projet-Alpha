import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/custom_sidebar.dart';
import 'package:prima/widgets/custom_bottom_navigation.dart';
import 'package:prima/widgets/page_header.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _selectedIndex = 0;

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
                title: 'Commandes',
                showAddressSection: true,
              ),
              Padding(
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
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onNavigationItemSelected,
      ),
    );
  }
}
