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

    return WillPopScope(
      onWillPop: () async {
        // Si nous sommes sur une route principale, permettre la sortie de l'app
        if (navigationProvider.currentRoute == '/home') {
          return true;
        }
        // Sinon, retourner à home
        navigationProvider.setRoute('/home');
        return false;
      },
      child: Scaffold(
        drawer: const CustomSidebar(),
        body: IndexedStack(
          index: navigationProvider.currentIndex,
          children: const [
            HomePage(),
            OffersPage(),
            ServicesPage(),
            ChatPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: navigationProvider.shouldShowBottomNav(navigationProvider.currentRoute)
            ? CustomBottomNavigation(
                selectedIndex: navigationProvider.currentIndex,
                onItemSelected: (index) {
                  navigationProvider.setRoute(NavigationProvider.mainRoutes[index]);
                },
              )
            : null,
      ),
    );
  }
}
