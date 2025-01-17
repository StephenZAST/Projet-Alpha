import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/providers/auth_data_provider.dart';
import 'package:prima/providers/order_provider.dart';
import 'package:prima/providers/profile_data_provider.dart';
import 'package:prima/providers/service_provider.dart';
import 'package:prima/routes/app_routes.dart';
import 'package:prima/services/order_cache_service.dart';
import 'package:prima/services/order_service.dart';
import 'package:prima/services/websocket_service.dart';
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
import 'package:prima/widgets/custom_bottom_navigation.dart';
import 'package:prima/providers/profile_provider.dart';
import 'package:prima/pages/auth/login_page.dart';
import 'package:prima/pages/auth/register_page.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prima/services/article_service.dart';
import 'package:prima/services/service_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prima/services/offer_service.dart';
import 'package:prima/providers/offer_provider.dart';

import 'pages/auth/reset_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiser les données de localisation française
  await initializeDateFormatting('fr_FR', null);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authDataProvider: AuthDataProviderImpl(prefs),
            profileDataProvider: ProfileDataProviderImpl(prefs),
            prefs: prefs,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AddressProvider>(
          create: (context) => AddressProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) =>
              AddressProvider(auth)..loadAddresses(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (context) => ProfileProvider(
            Provider.of<AuthProvider>(context, listen: false),
            prefs,
            useMockData: false,
          ),
          update: (context, auth, previous) =>
              ProfileProvider(auth, prefs, useMockData: false),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ArticleProvider>(
          create: (context) => ArticleProvider(
            ArticleService(
                Provider.of<AuthProvider>(context, listen: false).dio),
          )..loadData(),
          update: (context, auth, previous) => ArticleProvider(
            ArticleService(auth.dio),
          )..loadData(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ServiceProvider>(
          create: (context) => ServiceProvider(
            Provider.of<AuthProvider>(context, listen: false).dio,
          ),
          update: (context, auth, previous) => ServiceProvider(auth.dio),
        ),
        Provider<OrderCacheService>(
          create: (_) => OrderCacheService(prefs),
        ),
        Provider<WebSocketService>(
          create: (context) => WebSocketService(
            Provider.of<AuthProvider>(context, listen: false).token ?? '',
          ),
        ),
        ChangeNotifierProxyProvider3<AuthProvider, OrderCacheService,
            WebSocketService, OrderProvider>(
          create: (context) => OrderProvider(
            OrderService(Provider.of<AuthProvider>(context, listen: false).dio),
            Provider.of<WebSocketService>(context, listen: false),
          ),
          update: (context, auth, cache, ws, previous) => OrderProvider(
            OrderService(auth.dio),
            ws,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OfferProvider>(
          create: (context) => OfferProvider(
            OfferService(Provider.of<AuthProvider>(context, listen: false).dio),
            prefs,
          )..loadOffers(),
          update: (context, auth, previous) => OfferProvider(
            OfferService(auth.dio),
            prefs,
          )..loadOffers(),
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final prefs =
                Provider.of<SharedPreferences>(context, listen: false);
            return ProfileProvider(authProvider, prefs, useMockData: false);
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final dio = Dio(BaseOptions(
              baseUrl: 'http://localhost:3001',
              contentType: 'application/json',
              headers: {
                'Accept': 'application/json',
              },
            ));

            // Ajouter l'intercepteur pour le token
            dio.interceptors.add(InterceptorsWrapper(
              onRequest: (options, handler) {
                final token = authProvider.token;
                if (token != null) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                return handler.next(options);
              },
            ));

            // ...existing interceptors...

            return AddressProvider(authProvider);
          },
        ),
      ],
      child: Consumer<AuthProvider>(
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
                  return MaterialPageRoute(
                      builder: (_) => const ReferralPage());
                case '/settings':
                  return MaterialPageRoute(
                      builder: (_) => const SettingsPage());
                default:
                  return MaterialPageRoute(
                      builder: (_) => const MainNavigationWrapper());
              }
            },
          );
        },
      ),
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
