import 'package:flutter/material.dart';
import 'package:prima/widgets/custom_sidebar.dart';
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
import 'package:flutter/widgets.dart';

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
      // Suppression de la propriété home et ajout de initialRoute
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationWrapper(),
        '/notifications': (context) => const NotificationsPage(),
        '/orders': (context) => const OrdersPage(),
        '/referral': (context) => const ReferralPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    
    // Create a PageController that listens to the navigationProvider
    final pageController = PageController(initialPage: navigationProvider.currentIndex);

    // Update page when navigationProvider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(navigationProvider.currentIndex);
      }
    });
    
    final List<Widget> pages = [
      const HomePage(),
      const OffersPage(),
      const ServicesPage(),
      const ChatPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      drawer: const CustomSidebar(),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          navigationProvider.setIndex(index);
        },
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: navigationProvider.currentIndex,
        onItemSelected: (index) {
          navigationProvider.setIndex(index);
        },
      ),
    );
  }
}
