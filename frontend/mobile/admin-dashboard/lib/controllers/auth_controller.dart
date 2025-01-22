import 'package:get/get.dart';
import '../constants.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../routes/admin_routes.dart';

class AuthController extends GetxController {
  final user = Rxn<User>();
  final isLoading = false.obs;

  bool get isAuthenticated => user.value != null;

  @override
  void onInit() {
    super.onInit();
    ever(user, (_) => _handleAuthStateChange());
    checkAuth();
  }

  void _handleAuthStateChange() {
    if (user.value == null) {
      Get.offAllNamed(AdminRoutes.login);
    }
  }

  Future<void> checkAuth() async {
    isLoading.value = true;
    try {
      // Utiliser le token stocké dans AuthService
      if (AuthService.token != null) {
        await _refreshUserData();
      } else {
        logout();
      }
    } catch (e) {
      _handleError('Erreur d\'authentification', e);
      logout();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshUserData() async {
    try {
      final userData = await AuthService.getCurrentUser();
      if (userData != null) {
        user.value = userData;
      } else {
        throw 'Données utilisateur invalides';
      }
    } catch (e) {
      throw 'Impossible de récupérer les données utilisateur: $e';
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await AuthService.login(email, password);

      if (!response['success']) {
        throw response['message'] ?? 'Erreur de connexion';
      }

      if (response['data'] == null) {
        throw 'Données de réponse invalides';
      }

      // Le token est déjà géré par AuthService
      await _refreshUserData();
      Get.offAllNamed(AdminRoutes.dashboard);

      Get.snackbar(
        'Succès',
        'Connexion réussie',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        padding: AppSpacing.paddingMD,
        margin: AppSpacing.marginMD,
        borderRadius: AppRadius.sm,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      _handleError('Erreur de connexion', e);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    AuthService.clearSession();
    user.value = null;
  }

  void _handleError(String title, dynamic error) {
    Get.snackbar(
      title,
      error.toString(),
      backgroundColor: AppColors.error,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.TOP,
      padding: AppSpacing.paddingMD,
      margin: AppSpacing.marginMD,
      borderRadius: AppRadius.sm,
      duration: Duration(seconds: 4),
    );
  }
}
