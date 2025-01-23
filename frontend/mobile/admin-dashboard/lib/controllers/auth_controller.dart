import 'package:get/get.dart';
import '../constants.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../routes/admin_routes.dart';

class AuthController extends GetxController {
  final user = Rxn<User>();
  final isLoading = false.obs;
  final _currentRoute = ''.obs;

  bool get isAuthenticated => user.value != null;

  @override
  void onInit() {
    print('[AuthController] Initializing');
    super.onInit();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      print('[AuthController] Initializing auth state');
      final savedUser = AuthService.currentUser;
      if (savedUser != null) {
        print('[AuthController] Found saved user: ${savedUser.toJson()}');
        user.value = savedUser;
        await checkAuth();
      } else {
        print('[AuthController] No saved user found');
        user.value = null;
      }
    } catch (e) {
      print('[AuthController] Error initializing auth: $e');
      user.value = null;
    }
  }

  Future<void> checkAuth() async {
    print('[AuthController] Checking auth status');
    isLoading.value = true;
    try {
      if (AuthService.token != null) {
        print('[AuthController] Token found, refreshing user data');
        final userData = await AuthService.getCurrentUser();
        if (userData != null) {
          print(
              '[AuthController] User data refreshed successfully: ${userData.toJson()}');
          user.value = userData;
          _handleAuthStateChange();
        } else {
          print('[AuthController] Failed to refresh user data');
          throw 'Failed to refresh user data';
        }
      } else {
        print('[AuthController] No token found, logging out');
        logout();
      }
    } catch (e) {
      print('[AuthController] Auth check error: $e');
      _handleError('Erreur d\'authentification', e);
      logout();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      print('[AuthController] Login attempt for email: $email');
      isLoading.value = true;

      final response = await AuthService.login(email, password);
      print('[AuthController] Login response: $response');

      if (response['success'] == true) {
        final userData = response['data']['user'];
        if (userData != null) {
          try {
            final newUser = User.fromJson(userData);
            print(
                '[AuthController] User created successfully: ${newUser.toJson()}');
            user.value = newUser;

            // Attendre un peu avant de rediriger pour laisser le temps aux animations
            await Future.delayed(Duration(milliseconds: 100));
            _navigateTo(AdminRoutes.dashboard);

            Get.snackbar(
              'Succès',
              'Connexion réussie',
              backgroundColor: AppColors.success,
              colorText: AppColors.textLight,
              snackPosition: SnackPosition.TOP,
              margin: AppSpacing.marginMD,
              duration: Duration(seconds: 3),
            );
          } catch (e) {
            print('[AuthController] Error creating user object: $e');
            throw 'Erreur lors de la création de l\'utilisateur';
          }
        } else {
          throw 'Données utilisateur manquantes';
        }
      } else {
        throw response['message'] ?? 'Erreur de connexion';
      }
    } catch (e) {
      print('[AuthController] Login error: $e');
      _handleError('Erreur de connexion', e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAuthStateChange() {
    print('[AuthController] Handling auth state change');
    print('[AuthController] User: ${user.value?.toJson()}');
    print('[AuthController] Current route: ${Get.currentRoute}');

    // Navigation sûre avec un délai
    Future.delayed(Duration(milliseconds: 100), () {
      if (user.value == null) {
        print('[AuthController] No user, redirecting to login');
        if (Get.currentRoute != AdminRoutes.login) {
          _navigateTo(AdminRoutes.login);
        }
      } else if (Get.currentRoute != AdminRoutes.dashboard) {
        print('[AuthController] User authenticated, redirecting to dashboard');
        _navigateTo(AdminRoutes.dashboard);
      }
    });
  }

  void _navigateTo(String route) {
    try {
      _currentRoute.value = route;
      Get.offAllNamed(route);
    } catch (e) {
      print('[AuthController] Navigation error: $e');
      // En cas d'erreur de navigation, on tente de revenir à la page de login
      if (route != AdminRoutes.login) {
        Get.offAllNamed(AdminRoutes.login);
      }
    }
  }

  void logout() {
    print('[AuthController] Logging out');
    AuthService.clearSession();
    user.value = null;
    _navigateTo(AdminRoutes.login);
  }

  void _handleError(String title, dynamic error) {
    print('[AuthController] Error: $title - $error');
    Get.snackbar(
      title,
      error.toString(),
      backgroundColor: AppColors.error,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.TOP,
      margin: AppSpacing.marginMD,
      duration: Duration(seconds: 4),
    );
  }
}
