import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prima/providers/auth_data_provider.dart';
import 'package:prima/providers/profile_data_provider.dart';
import 'package:prima/redux/actions/navigation_actions.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:prima/redux/states/navigation_state.dart';
import 'package:prima/widgets/custom_sidebar.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/pages/home/home_page.dart';
import 'package:prima/pages/profile/profile_page.dart';
import 'package:prima/pages/offers/offers_page.dart';
import 'package:prima/pages/chat/chat_page.dart';
import 'package:prima/pages/services/services_page.dart';
import 'package:prima/navigation/navigation_provider.dart';
import 'package:prima/widgets/custom_bottom_navigation.dart';
import 'package:prima/pages/auth/login_page.dart';
import 'package:prima/pages/auth/register_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux/store.dart';

import 'pages/auth/reset_password_page.dart';

final navigationProviderProvider =
    ChangeNotifierProvider(create: (context) => NavigationProvider());

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
    validateStatus: (status) {
      return status! < 500;
    },
  ));

  dio.interceptors.addAll([
    LogInterceptor(requestBody: true, responseBody: true),
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await authDataProvider.getStoredToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  ]);

  final store = await initStore(dio, authDataProvider, profileDataProvider);
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
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/reset_password': (context) => const ResetPasswordPage(),
        },
        home: StoreConnector<AppState, bool>(
          converter: (store) => store.state.authState.isAuthenticated,
          builder: (context, isAuthenticated) {
            return isAuthenticated
                ? const MainNavigationWrapper()
                : const LoginPage();
          },
        ),
      ),
    );
  }
}

class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, int>(
      converter: (store) => store.state.navigationState.currentIndex,
      builder: (context, currentIndex) {
        return Scaffold(
          drawer: const CustomSidebar(),
          body: IndexedStack(
            index: currentIndex,
            children: const [
              HomePage(),
              OffersPage(),
              ServicesPage(),
              ChatPage(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: currentIndex,
            onItemSelected: (index) => StoreProvider.of<AppState>(context)
                .dispatch(SetIndexAction(index)),
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final bool isAuthenticated;
  final int currentIndex;
  final String currentRoute;
  final Function(int) onPageChanged;
  final Function(int) animateToPage;
  final Function(int) setRouteFromIndex;
  final bool shouldShowBottomNav;

  _ViewModel({
    required this.isAuthenticated,
    required this.currentIndex,
    required this.currentRoute,
    required this.onPageChanged,
    required this.animateToPage,
    required this.setRouteFromIndex,
    required this.shouldShowBottomNav,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isAuthenticated: store.state.authState.isAuthenticated,
      currentIndex: store.state.navigationState.currentIndex,
      currentRoute: store.state.navigationState.currentRoute,
      shouldShowBottomNav: NavigationState.mainRoutes
          .contains(store.state.navigationState.currentRoute),
      onPageChanged: (index) => store.dispatch(SetIndexAction(index)),
      animateToPage: (index) => store.dispatch(AnimateToPageAction(index)),
      setRouteFromIndex: (index) {
        store.dispatch(SetIndexAction(index));
        store.dispatch(SetRouteAction(NavigationState.mainRoutes[index]));
      },
    );
  }
}
