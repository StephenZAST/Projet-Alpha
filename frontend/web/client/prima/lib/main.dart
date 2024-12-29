import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/pages/home/home_page.dart';
import 'package:prima/pages/profile/profile_page.dart';
import 'package:prima/pages/offers/offers_page.dart';
import 'package:prima/pages/chat/chat_page.dart';
import 'package:prima/pages/services/services_page.dart';
import 'package:prima/pages/orders/orders_page.dart';
import 'package:prima/pages/referral/referral_page.dart';
import 'package:prima/pages/settings/settings_page.dart';
import 'package:prima/pages/notifications/notifications_page.dart';
import 'package:prima/navigation/navigation_provider.dart';
import 'package:prima/widgets/custom_drawer.dart';
import 'package:prima/widgets/custom_bottom_navigation.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZS Laundry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SourceSansPro',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final pageController = PageController(initialPage: navigationProvider.currentIndex);
    
    final List<Widget> pages = [
      const HomePage(),
      const OffersPage(),
      const ServicesPage(),
      const ChatPage(),
      const ProfilePage(),
      const OrdersPage(),
      const ReferralPage(),
      const SettingsPage(),
      const NotificationsPage(),
    ];

    return Scaffold(
      drawer: const CustomDrawer(),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(), // Désactive le swipe
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: navigationProvider.currentIndex,
        onItemSelected: (index) {
          navigationProvider.setIndex(index);
          pageController.jumpToPage(index);
        },
      ),
    );
  }
}
