import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prima/animations/page_transition.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:prima/services/address_service.dart';
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
import 'package:prima/widgets/custom_bottom_navigation.dart';
import 'package:flutter/widgets.dart';
import 'package:prima/pages/auth/login_page.dart';
import 'package:prima/pages/auth/register_page.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prima/config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/auth/reset_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Créer une seule instance de Dio
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3001',
    contentType: 'application/json',
  ));

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          title: 'ZS Laundry',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'SourceSansPro',
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
          ),
          initialRoute: authProvider.isAuthenticated ? '/' : '/login',
          routes: {
            '/': (context) => const MainNavigationWrapper(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/reset_password': (context) => const ResetPasswordPage(),
          },
          onGenerateRoute: (settings) {
            // Protection des routes qui nécessitent une authentification
            if (!authProvider.isAuthenticated &&
                settings.name != '/login' &&
                settings.name != '/register') {
              return MaterialPageRoute(
                builder: (_) => const LoginPage(),
              );
            }

            // Routes principales et secondaires
            switch (settings.name) {
              case '/notifications':
                return MaterialPageRoute(
                    builder: (_) => const NotificationsPage());
              case '/orders':
                return MaterialPageRoute(builder: (_) => const OrdersPage());
              case '/referral':
                return MaterialPageRoute(builder: (_) => const ReferralPage());
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsPage());
              default:
                return MaterialPageRoute(
                    builder: (_) => const MainNavigationWrapper());
            }
          },
        );
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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    _pageController =
        PageController(initialPage: navigationProvider.currentIndex);
    navigationProvider.setPageController(_pageController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, AuthProvider>(
      builder: (context, navigationProvider, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const LoginPage();
        }

        return WillPopScope(
          onWillPop: () async {
            if (navigationProvider.currentIndex != 0) {
              navigationProvider.setRouteFromIndex(0);
              return false;
            }
            return true;
          },
          child: Scaffold(
            drawer: const CustomSidebar(),
            body: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                navigationProvider.setRouteFromIndex(index);
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
                      navigationProvider.animateToPage(index);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
