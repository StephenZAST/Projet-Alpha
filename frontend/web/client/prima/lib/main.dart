import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prima/animations/page_transition.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:prima/providers/auth_data_provider.dart';
import 'package:prima/providers/profile_data_provider.dart';
import 'package:prima/services/address_service.dart';
import 'package:prima/widgets/custom_sidebar.dart';
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
import 'package:prima/providers/profile_provider.dart';
import 'package:prima/pages/auth/login_page.dart';
import 'package:prima/pages/auth/register_page.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prima/config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:prima/providers/profile_provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux/store.dart';

import 'pages/auth/reset_password_page.dart';

final navigationProviderProvider =
    ChangeNotifierProvider((ref) => NavigationProvider());
final authProviderProvider = ChangeNotifierProvider((ref) => AuthProvider(
      authDataProvider: AuthDataProviderImpl(
          SharedPreferences.getInstance() as SharedPreferences),
      profileDataProvider: ProfileDataProviderImpl(
          SharedPreferences.getInstance() as SharedPreferences),
      prefs: SharedPreferences.getInstance() as SharedPreferences,
    ));
final profileProviderProvider = ChangeNotifierProvider((ref) => ProfileProvider(
      ref.watch(authProviderProvider),
      SharedPreferences.getInstance() as SharedPreferences,
      useMockData: false,
    ));
final addressProviderProvider = ChangeNotifierProvider(
    (ref) => AddressProvider(ref.watch(authProviderProvider)));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final authDataProvider = AuthDataProviderImpl(prefs);
  final profileDataProvider = ProfileDataProviderImpl(prefs);
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3001',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  final store = createStore(dio, authDataProvider, profileDataProvider);

  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'ZS Laundry',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'SourceSansPro',
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MainNavigationWrapper(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/reset_password': (context) => const ResetPasswordPage(),
        },
      ),
    );
  }
}

class MainNavigationWrapper extends ConsumerStatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  ConsumerState<MainNavigationWrapper> createState() =>
      _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends ConsumerState<MainNavigationWrapper> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final navigationProvider = ref.read(navigationProviderProvider);
    _pageController =
        PageController(initialPage: navigationProvider.currentIndex);
    ref.read(navigationProviderProvider).setPageController(_pageController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final navigationProvider = ref.watch(navigationProviderProvider);
        final authProvider = ref.watch(authProviderProvider);

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
