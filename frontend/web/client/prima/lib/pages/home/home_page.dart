import 'package:flutter/material.dart';
import 'package:prima/layouts/ReductionSection.dart';
import 'package:prima/layouts/ServiceSection.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/home-components/address_section.dart';
import 'package:prima/home-components/recent_orders_section.dart';
import 'package:prima/home-components/services_title.dart';
import 'package:prima/widgets/custom_sidebar.dart';
import 'package:spring_button/spring_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      drawer: const CustomSidebar(),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.gray500,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            items: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.local_offer_rounded, 'Offres', 1),
              const BottomNavigationBarItem(icon: SizedBox(width: 30), label: ''),
              _buildNavItem(Icons.chat_bubble_rounded, 'Chat', 3),
              _buildNavItem(Icons.person_rounded, 'Profile', 4),
            ],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              switch (index) {
                case 0: // Home
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 1: // Offers
                  Navigator.pushReplacementNamed(context, '/offers');
                  break;
                case 2: // Add (center button)
                  // TODO: Implement add order functionality
                  break;
                case 3: // Chat
                  Navigator.pushReplacementNamed(context, '/chat');
                  break;
                case 4: // Profile
                  Navigator.pushReplacementNamed(context, '/profile');
                  break;
              }
            },
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        child: SpringButton(
          SpringButtonType.OnlyScale,
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: AppColors.white),
          ),
          onTap: () {},
          scaleCoefficient: 0.9,
          useCache: false,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(_selectedIndex == index ? 12 : 8),
        decoration: BoxDecoration(
          color: _selectedIndex == index 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
