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

  Future<void> verifyAuth() async {
    if (AuthService.token != null) {
      await _verifyToken();
    } else {
      _navigateToLogin();
    }
  }

  Future<void> _initializeAuth() async {
    try {
      print('[AuthController] Initializing auth state');
      final savedUser = AuthService.currentUser;
      if (savedUser != null) {
        print('[AuthController] Found saved user: ${savedUser.toJson()}');
        user.value = savedUser;
        if (AuthService.token != null) {
          await _verifyToken();
        } else {
          _navigateToLogin();
        }
      } else {
        print('[AuthController] No saved user found');
        _navigateToLogin();
      }
    } catch (e) {
      print('[AuthController] Error initializing auth: $e');
      _navigateToLogin();
    }
  }

  Future<void> _verifyToken() async {
    print('[AuthController] Verifying token');
    isLoading.value = true;
    try {
      final userData = await AuthService.getCurrentUser();
      if (userData != null) {
        print(
            '[AuthController] Token verified, user data: ${userData.toJson()}');
        user.value = userData;
        _navigateToDashboard();
      } else {
        print('[AuthController] Token invalid');
        _handleLogout();
      }
    } catch (e) {
      print('[AuthController] Token verification error: $e');
      _handleLogout();
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
            // Convertir explicitement en Map<String, dynamic>
            final userMap = Map<String, dynamic>.from(userData);
            final newUser = User.fromJson(userMap);
            print(
                '[AuthController] User created successfully: ${newUser.toJson()}');
            user.value = newUser;
            _navigateToDashboard();

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

  void logout() {
    print('[AuthController] Logging out');
    _handleLogout();
  }

  void _handleLogout() {
    AuthService.clearSession();
    user.value = null;
    _navigateToLogin();
  }

  void _navigateToLogin() {
    if (Get.currentRoute != AdminRoutes.login) {
      _currentRoute.value = AdminRoutes.login;
      Get.offAllNamed(AdminRoutes.login);
    }
  }

  void _navigateToDashboard() {
    if (Get.currentRoute != AdminRoutes.dashboard) {
      _currentRoute.value = AdminRoutes.dashboard;
      Get.offAllNamed(AdminRoutes.dashboard);
    }
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
