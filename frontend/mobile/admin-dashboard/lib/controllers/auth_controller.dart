import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../routes/admin_routes.dart';

class AuthController extends GetxController {
  final user = Rxn<User>();
  final isLoading = false.obs;
  final storage = GetStorage();

  bool get isAuthenticated => user.value != null;

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  Future<void> checkAuth() async {
    isLoading.value = true;
    try {
      final token = storage.read('token');
      if (token != null && !isTokenExpired()) {
        final userData = await AuthService.getCurrentUser();
        user.value = userData;
      }
    } catch (e) {
      logout();
    } finally {
      isLoading.value = false;
    }
  }

  bool isTokenExpired() {
    final expiry = storage.read('tokenExpiry');
    if (expiry == null) return true;
    return DateTime.parse(expiry).isBefore(DateTime.now());
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await AuthService.login(email, password);

      // Vérifier la structure de la réponse
      if (response['success'] == true && response['data'] != null) {
        // Stocker le token
        storage.write('token', response['data']['token']);
        // Stocker les informations utilisateur
        storage.write('user', response['data']['user']);

        // Rediriger vers le dashboard
        AdminRoutes.goToDashboard();
      } else {
        throw 'Invalid response format';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    storage.remove('token');
    storage.remove('tokenExpiry');
    user.value = null;
    Get.offAllNamed('/login');
  }
}
