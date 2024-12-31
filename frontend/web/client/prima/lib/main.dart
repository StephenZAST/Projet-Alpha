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
import 'package:prima/providers/profile_provider.dart';

void main() {
  const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
  final config = {
    'useMockData': env == 'dev',
    'baseUrl': env == 'dev' 
        ? 'http://localhost:3000'
        : 'https://api.example.com',
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            useMockData: config['useMockData'] as bool,
          ),
        ),
      ],
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

    return Scaffold(
      drawer: const CustomSidebar(),
      body: PageView(
        controller: navigationProvider.pageController,
        physics: const BouncingScrollPhysics(), // Réactivation du swipe avec un effet de rebond
        onPageChanged: (index) {
          navigationProvider.setRoute(NavigationProvider.mainRoutes[index]);
        },
        children: [
          const HomePage(),
          const OffersPage(),
          const ServicesPage(),
          const ChatPage(),
          ProfilePage(), // Suppression du const car ProfilePage n'a pas de constructeur const
        ],
      ),
      bottomNavigationBar: navigationProvider.shouldShowBottomNav(navigationProvider.currentRoute)
          ? CustomBottomNavigation(
              selectedIndex: navigationProvider.currentIndex,
              onItemSelected: (index) {
                navigationProvider.pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          : null,
    );
  }
}
