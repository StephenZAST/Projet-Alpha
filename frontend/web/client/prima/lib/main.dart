import 'package:flutter/material.dart';
import 'package:prima/animations/page_transition.dart';
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
    'baseUrl':
        env == 'dev' ? 'http://localhost:3000' : 'https://api.example.com',
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
      onGenerateRoute: (settings) {
        if (NavigationProvider.secondaryRoutes.contains(settings.name)) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) {
              switch (settings.name) {
                case '/orders':
                  return const OrdersPage();
                case '/notifications':
                  return const NotificationsPage();
                // ... autres routes secondaires
                default:
                  return const SizedBox.shrink();
              }
            },
          );
        }
        return null;
      },
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    _pageController = PageController(
      initialPage: navigationProvider.currentIndex,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        drawer: const CustomSidebar(),
        body: SlidePageView(
          controller: _pageController,
          onPageChanged: (index) {
            navigationProvider.setRoute(NavigationProvider.mainRoutes[index]);
          },
          children: const [
            HomePage(),
            OffersPage(),
            ServicesPage(),
            ChatPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: navigationProvider
                .shouldShowBottomNav(navigationProvider.currentRoute)
            ? CustomBottomNavigation(
                selectedIndex: navigationProvider.currentIndex,
                onItemSelected: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
      ),
    );
  }
}
