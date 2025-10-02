import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'screens/home_page.dart';
import 'shared/widgets/main_navigation.dart';
import 'theme/theme_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/flash_order_provider.dart';
import 'shared/providers/address_provider.dart';
import 'shared/providers/user_profile_provider.dart';
import 'shared/providers/notification_provider.dart';
import 'shared/providers/order_draft_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'core/utils/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser le service de stockage
  await StorageService.init();
  
  runApp(const AlphaCustomerApp());
}

/// 🚀 Alpha Customer App - Premium Pressing Experience
class AlphaCustomerApp extends StatelessWidget {
  const AlphaCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => FlashOrderProvider()),
        ChangeNotifierProvider(create: (context) => OrderDraftProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Alpha Pressing',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
            routes: {
              '/home': (context) => const HomePage(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}

/// 🔐 Wrapper d'Authentification
/// Détermine quelle page afficher selon l'état d'authentification
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialiser l'authentification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Afficher un écran de chargement pendant l'initialisation
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        // Rediriger selon l'état d'authentification
        if (authProvider.isAuthenticated) {
          return const MainNavigation();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

/// 🌟 Écran de Chargement Initial
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Alpha
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: AppShadows.glassPrimary,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/Frame 95.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.local_laundry_service,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              'Alpha Pressing',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Excellence & Innovation',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 48),
            
            // Indicateur de chargement
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
